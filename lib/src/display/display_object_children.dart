part of stagexl.display;

/// This class is returned by the [DisplayObjectParent.children] getter.
///
/// It implements an [Iterable] of display objects and therefore allows
/// an easy iteration over the children of a [DisplayObjectParent].

class DisplayObjectChildren implements Iterable<DisplayObject> {

  // TODO: We could also implement List<DisplayObject>. It would be easy to use
  // the ListMixin, but the performance wouldn't be great. Therefore we make it
  // an read-only Iterable<DisplayObject> for now.

  final DisplayObjectParent parent;
  final List<DisplayObject> _children;

  DisplayObjectChildren._(this.parent, this._children);

  //---------------------------------------------------------------------------

  @override
  bool any(bool test(DisplayObject element)) {
    return _children.any(test);
  }

  @override
  bool contains(DisplayObject element) {
    return _children.contains(element);
  }

  @override
  DisplayObject elementAt(int index) {
    return _children[index];
  }

  @override
  bool every(bool test(DisplayObject element)) {
    return _children.every(test);
  }

  @override
  Iterable expand(Iterable f(DisplayObject element)) {
    return _children.expand(f);
  }

  @override
  DisplayObject get first {
    return _children.first;
  }

  @override
  DisplayObject firstWhere(bool test(DisplayObject element), {DisplayObject orElse()}) {
    return _children.firstWhere(test, orElse: orElse);
  }

  @override
  fold(initialValue, combine(previousValue, DisplayObject element)) {
    _children.fold(initialValue, combine);
  }

  @override
  void forEach(void f(DisplayObject element)) {
    _children.forEach(f);
  }

  @override
  bool get isEmpty {
    return _children.isEmpty;
  }

  @override
  bool get isNotEmpty {
    return _children.isNotEmpty;
  }

  @override
  Iterator<DisplayObject> get iterator {
    return _children.iterator;
  }

  @override
  String join([String separator = ""]) {
    return _children.join(separator);
  }

  @override
  DisplayObject get last {
    return _children.last;
  }

  @override
  DisplayObject lastWhere(bool test(DisplayObject element), {DisplayObject orElse()}) {
    return _children.lastWhere(test, orElse: orElse);
  }

  @override
  int get length {
    return _children.length;
  }

  @override
  Iterable map(f(DisplayObject element)) {
    return _children.map(f);
  }

  @override
  DisplayObject reduce(DisplayObject combine(DisplayObject value, DisplayObject element)) {
    return _children.reduce(combine);
  }

  @override
  DisplayObject get single {
    return _children.single;
  }

  @override
  DisplayObject singleWhere(bool test(DisplayObject element)) {
    return _children.singleWhere(test);
  }

  @override
  Iterable<DisplayObject> skip(int count) {
    return _children.skip(count);
  }

  @override
  Iterable<DisplayObject> skipWhile(bool test(DisplayObject value)) {
    return _children.skipWhile(test);
  }

  @override
  Iterable<DisplayObject> take(int count) {
    return _children.take(count);
  }

  @override
  Iterable<DisplayObject> takeWhile(bool test(DisplayObject value)) {
    return _children.takeWhile(test);
  }

  @override
  List<DisplayObject> toList({bool growable: true}) {
    return _children.toList(growable: growable);
  }

  @override
  Set<DisplayObject> toSet() {
    return _children.toSet();
  }

  @override
  Iterable<DisplayObject> where(bool test(DisplayObject element)) {
    return _children.where(test);
  }
}