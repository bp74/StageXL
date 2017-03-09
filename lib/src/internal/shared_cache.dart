library stagexl.internal.shared_cache;

import '../events.dart';
import 'jenkins_hash.dart';


class ObjectReleaseEvent extends Event {
  static const String OBJECT_RELEASE = "objectRelease";
  final dynamic object;
  /// Creates a new [ObjectReleaseEvent].
  ObjectReleaseEvent(String type, bool bubbles, this.object) : super(type, bubbles);
}


class SharedCacheNode<E>
{
  E   _cachedObject;
  int _shareCount;

  SharedCacheNode(this._cachedObject):_shareCount=1;
}


class SharedCache<K,E> extends EventDispatcher
{
  Map<K,SharedCacheNode<E>>  _cachedObjects = new Map<K,SharedCacheNode<E>>();
  bool _autoReleaseUnusedObjects;

  static const EventStreamProvider<ObjectReleaseEvent> releaseObjectEvent = const EventStreamProvider<ObjectReleaseEvent>(ObjectReleaseEvent.OBJECT_RELEASE);
  EventStream<ObjectReleaseEvent> get onObjectReleased => SharedCache.releaseObjectEvent.forTarget(this);

  SharedCache( [bool autoReleaseUnusedObjects = true] ): _autoReleaseUnusedObjects=autoReleaseUnusedObjects;

  void onObjectReleasedListen(Function listener) {
    onObjectReleased.listen(listener);
  }

  bool get autoReleaseUnusedObjects => _autoReleaseUnusedObjects;
  void set autoReleaseUnusedObjects(bool value) {
    if ( _autoReleaseUnusedObjects != value ) {
      _autoReleaseUnusedObjects = value;
      if ( _autoReleaseUnusedObjects ) {
        releaseUnusedObjects();
      }
    }
  }
  void releaseUnusedObjects() {
    if ( _autoReleaseUnusedObjects ) return;// no unused objects should exist when auto-releasing

    // copy the keys that map to unused nodes and then remove them from the map
    _cachedObjects.keys
        .where((k) => _cachedObjects[k]._shareCount <= 0)
        .toList()
        .forEach(_releaseNode);
  }

  void forceReleaseAllObjects() {
    // copy the keys and then remove them all from the map
    _cachedObjects.keys.toList().forEach(_releaseNode);
  }

  bool containsObject(K key) {
    return _cachedObjects.containsKey(key);
  }

  void  addObject(K key, E value) {
    if ( !containsObject(key) ) {
      _cachedObjects[key] = new SharedCacheNode<E>(value);
    } else {
      throw ArgumentError("key-value already in cache!");
    }
  }

  E getObject(K key) {
    SharedCacheNode<E> node = _cachedObjects[key];
    if ( node != null ) {
      ++node._shareCount;
      return node._cachedObject;
    }

    return null;
  }

  void releaseObject(K key) {
    SharedCacheNode<E> node = _cachedObjects[key];
    if ( node != null ) {
      --node._shareCount;
      if ( node._shareCount == 0 && _autoReleaseUnusedObjects ) {
        _cachedObjects.remove(key);
        _finalReleaseObject(node._cachedObject);
      }
    }
  }

  void _releaseNode(K key) {
    SharedCacheNode<E> node = _cachedObjects[key];
    _cachedObjects.remove(key);
    if ( node != null ) {
        _finalReleaseObject(node._cachedObject);
    }
  }

  void  _finalReleaseObject(E object) {
    dispatchEvent(new ObjectReleaseEvent(ObjectReleaseEvent.OBJECT_RELEASE, false, object));
  }

}