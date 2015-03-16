part of stagexl.display;

/// This class is returned by the [DisplayObjectParent.children] getter.
///
/// It implements an [Iterable] of display objects and therefore allows
/// an easy iteration over the children of a [DisplayObjectParent].

class DisplayObjectChildren implements Iterable<DisplayObject> {

  final DisplayObjectParent parent;
  final List<DisplayObject> _children;

  DisplayObjectChildren._(this.parent, this._children);

  //---------------------------------------------------------------------------

  // TODO: Implement the rest of the List<DisplayObject> interface.

  void clear() {
    this.parent.removeChildren();
  }

  void add(DisplayObject displayObject) {
    this.parent.addChild(displayObject);
  }

  void addAll(Iterable<DisplayObject> displayObjects) {
    for(var displayObject in displayObjects){
      this.parent.addChild(displayObject);
    }
  }

  int indexOf(DisplayObject displayObject) {
    return _children.indexOf(displayObject);
  }

  void insert(int index, DisplayObject displayObject) {
    this.parent.addChildAt(displayObject, index);
  }

  void insertAll(int index, Iterable<DisplayObject> displayObjects) {
    for(var displayObject in displayObjects) {
      this.parent.addChildAt(displayObject, index++);
    }
  }

  bool remove(DisplayObject displayObject) {
    var index = _children.indexOf(displayObject);
    if (index >= 0) this.parent.removeChildAt(index);
    return index >= 0;
  }

  DisplayObject removeAt(int index) {
    var displayObject = _children[index];
    this.parent.removeChildAt(index);
    return displayObject;
  }

  DisplayObject removeLast() {
    return removeAt(_children.length - 1);
  }

  void removeRange(int start, int end) {
    return this.parent.removeChildren(start, end);
  }

  DisplayObject operator[](int index) {
    return _children[index];
  }

  void operator[]=(int index, DisplayObject displayObject) {
    this.parent.replaceChildAt(displayObject, index);
  }

  Iterable<DisplayObject> get reversed {
    return _children.reversed;
  }

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