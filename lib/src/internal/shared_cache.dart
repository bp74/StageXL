library stagexl.internal.shared_cache;

import '../events.dart';

class ObjectReleaseEvent<E> extends Event {
  final E object;
  ObjectReleaseEvent(this.object) : super("objectRelease", false);
}

class SharedCacheNode<E> {
  E _cachedObject;
  int _shareCount = 1;
  SharedCacheNode(this._cachedObject);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class SharedCache<K, E> extends EventDispatcher {

  Map<K, SharedCacheNode<E>> _cachedObjects = new Map<K, SharedCacheNode<E>>();
  bool _autoReleaseUnusedObjects = true;

  SharedCache([bool autoReleaseUnusedObjects = true]) {
    _autoReleaseUnusedObjects = autoReleaseUnusedObjects;
  }

  EventStream<ObjectReleaseEvent<E>> get onObjectReleased {
    return this.on<ObjectReleaseEvent<E>>("objectRelease");
  }

  //----------------------------------------------------------------------------

  bool get autoReleaseUnusedObjects => _autoReleaseUnusedObjects;

  set autoReleaseUnusedObjects(bool value) {
    if (_autoReleaseUnusedObjects != value) {
      _autoReleaseUnusedObjects = value;
      if (_autoReleaseUnusedObjects) {
        releaseUnusedObjects();
      }
    }
  }

  void releaseUnusedObjects() {

    // no unused objects should exist when auto-releasing
    if (_autoReleaseUnusedObjects) return;

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

  void addObject(K key, E value) {
    if (!containsObject(key)) {
      _cachedObjects[key] = new SharedCacheNode<E>(value);
    } else {
      throw new ArgumentError("key-value already in cache!");
    }
  }

  E getObject(K key) {
    var node = _cachedObjects[key];
    if (node != null) {
      node._shareCount += 1;
      return node._cachedObject;
    }
    return null;
  }

  void releaseObject(K key) {
    var node = _cachedObjects[key];
    if (node != null) {
      node._shareCount -= 1;
      if (node._shareCount == 0 && _autoReleaseUnusedObjects) {
        _cachedObjects.remove(key);
        _finalReleaseObject(node._cachedObject);
      }
    }
  }

  void _releaseNode(K key) {
    var node = _cachedObjects[key];
    _cachedObjects.remove(key);
    if (node != null) {
      _finalReleaseObject(node._cachedObject);
    }
  }

  void _finalReleaseObject(E object) {
    dispatchEvent(new ObjectReleaseEvent<E>(object));
  }
}
