part of stagexl.display;

/// This class is returned by the [DisplayObjectParent.children] getter.
///
/// It implements an [Iterable] of display objects and therefore allows
/// an easy iteration over the children of a [DisplayObjectParent].

class DisplayObjectChildren<T extends DisplayObject> extends IterableBase<T> {
  final DisplayObjectParent parent;
  final List<T> _children;

  DisplayObjectChildren._(this.parent, this._children);

  //---------------------------------------------------------------------------

  void clear() {
    this.parent.removeChildren();
  }

  void add(T displayObject) {
    this.parent.addChild(displayObject);
  }

  void addAll(Iterable<T> displayObjects) {
    for (var displayObject in displayObjects) {
      this.parent.addChild(displayObject);
    }
  }

  int indexOf(T displayObject) {
    return _children.indexOf(displayObject);
  }

  void insert(int index, T displayObject) {
    this.parent.addChildAt(displayObject, index);
  }

  void insertAll(int index, Iterable<T> displayObjects) {
    for (var displayObject in displayObjects) {
      this.parent.addChildAt(displayObject, index++);
    }
  }

  bool remove(T displayObject) {
    var index = _children.indexOf(displayObject);
    if (index >= 0) this.parent.removeChildAt(index);
    return index >= 0;
  }

  T removeAt(int index) {
    var displayObject = _children[index];
    this.parent.removeChildAt(index);
    return displayObject;
  }

  T removeLast() {
    return removeAt(_children.length - 1);
  }

  void removeRange(int start, int end) {
    return this.parent.removeChildren(start, end);
  }

  T operator [](int index) {
    return _children[index];
  }

  void operator []=(int index, T displayObject) {
    this.parent.replaceChildAt(displayObject, index);
  }

  Iterable<T> get reversed {
    return _children.reversed;
  }

  //---------------------------------------------------------------------------

  @override
  Iterator<T> get iterator {
    return _children.iterator;
  }
}
