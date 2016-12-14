part of stagexl.display;

/// This class is returned by the [DisplayObjectParent.children] getter.
///
/// It implements an [Iterable] of display objects and therefore allows
/// an easy iteration over the children of a [DisplayObjectParent].

class DisplayObjectChildren<T extends DisplayObject> implements Iterable<T> {

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
  bool any(bool test(T element)) {
    return _children.any(test);
  }

  @override
  bool contains(Object element) {
    return _children.contains(element);
  }

  @override
  T elementAt(int index) {
    return _children[index];
  }

  @override
  bool every(bool test(T element)) {
    return _children.every(test);
  }

  @override
  Iterable<S> expand<S>(Iterable<S> f(T element)) => _children.expand(f);

  @override
  T get first {
    return _children.first;
  }

  @override
  T firstWhere(bool test(T element), {T orElse()}) {
    return _children.firstWhere(test, orElse: orElse);
  }

  @override
  S fold<S>(S initialValue, S combine(S previousValue, T element)) {
    return _children.fold(initialValue, combine);
  }

  @override
  void forEach(void f(T element)) {
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
  Iterator<T> get iterator {
    return _children.iterator;
  }

  @override
  String join([String separator = ""]) {
    return _children.join(separator);
  }

  @override
  T get last {
    return _children.last;
  }

  @override
  T lastWhere(bool test(T element), {T orElse()}) {
    return _children.lastWhere(test, orElse: orElse);
  }

  @override
  int get length {
    return _children.length;
  }

  @override
  Iterable<S> map<S>(S f(T e)) {
    return _children.map(f);
  }

  @override
  T reduce(T combine(T value, T element)) {
    return _children.reduce(combine);
  }

  @override
  T get single {
    return _children.single;
  }

  @override
  T singleWhere(bool test(T element)) {
    return _children.singleWhere(test);
  }

  @override
  Iterable<T> skip(int count) {
    return _children.skip(count);
  }

  @override
  Iterable<T> skipWhile(bool test(T value)) {
    return _children.skipWhile(test);
  }

  @override
  Iterable<T> take(int count) {
    return _children.take(count);
  }

  @override
  Iterable<T> takeWhile(bool test(T value)) {
    return _children.takeWhile(test);
  }

  @override
  List<T> toList({bool growable: true}) {
    return _children.toList(growable: growable);
  }

  @override
  Set<T> toSet() {
    return _children.toSet();
  }

  @override
  Iterable<T> where(bool test(T element)) {
    return _children.where(test);
  }
}
