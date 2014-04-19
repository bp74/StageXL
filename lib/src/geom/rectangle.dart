part of stagexl;

class Rectangle<T extends num> implements math.MutableRectangle<T> {

  T left;
  T top;
  T width;
  T height;

  Rectangle(this.left, this.top, this.width, this.height);

  Rectangle.from(math.Rectangle<T> r) : this(r.left, r.top, r.width, r.height);

  Rectangle<T> clone() => new Rectangle<T>(left, top, width, height);

  String toString() => "Rectangle<$T> [left=${left}, top=${top}, width=${width}, height=${height}]";

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  /// Use [left] instead.
  @deprecated
  T get x => left;

  /// Use [left] instead.
  @deprecated
  void set x(T value) {
    left = value;
  }

  /// Use [top] instead.
  @deprecated
  T get y => top;

  /// Use [top] instead.
  @deprecated
  void set y(T value) {
    top = value;
  }

  T get right => left + width;
  void set right(T value) { width = value - left; }

  T get bottom => top + height;
  void set bottom(T value) { height = value - top; }

  Point<T> get topLeft => new Point<T>(left, top);
  void set topLeft(Point<T> point) {
    width = width + left - point.x;
    height = height + top - point.y;
    left = point.x;
    top = point.y;
  }

  Point<T> get topRight => new Point<T>(this.left + this.width, this.top);

  Point<T> get bottomRight => new Point<T>(left + width, top + height);
  void set bottomRight(Point<T> point) {
    width = point.x - left;
    height = point.y - top;
  }

  Point<T> get bottomLeft => new Point<T>(this.left,
      this.top + this.height);

  Point<T> get size => new Point<T>(width, height);
  void set size(Point<T> point) {
    width = point.x;
    height = point.y;
  }

  Point<num> get center => new Point<num>(left + width / 2, top + height / 2);

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {
    return left <= px && top <= py && right > px && bottom > py;
  }

  bool containsPoint(math.Point<num> p) {
    return contains(p.x, p.y);
  }

  /// Use [containsRectangle] instead.
  @deprecated
  bool containsRect(math.Rectangle<num> r) => containsRectangle(r);

  bool equals(math.Rectangle<num> r) {
    return left == r.left && top == r.top && width == r.width && height == r.height;
  }

  bool intersects(math.Rectangle<num> r) {
    return this.left < r.right && this.right > r.left && this.top < r.bottom && this.bottom > r.top;
  }

  bool get isEmpty {
    return width <= 0 || height <= 0;
  }

  /**
   * Returns a new rectangle which completely contains `this` and [other].
   */
  Rectangle<T> boundingBox(math.Rectangle<T> other) => union(other);

  /**
   * Tests whether `this` entirely contains [another].
   */
  bool containsRectangle(math.Rectangle<num> r) {
    return left <= r.left && top <= r.top && left + width >= r.right &&
        top + height >= r.bottom;
  }

  //-----------------------------------------------------------------------------------------------

  void copyFrom(math.Rectangle<T> r) {
    setTo(r.left, r.top, r.width, r.height);
  }

  void inflate(T dx, T dy) {
    width += dx;
    height += dy;
  }

  void inflatePoint(math.Point<T> p) {
    inflate(p.x, p.y);
  }

  void offset(T dx, T dy) {
    left += dx;
    top += dy;
  }

  void offsetPoint(Point<T> p) {
    offset(p.x, p.y);
  }

  void setTo(T rx, T ry, T rwidth, T rheight) {
    left = rx;
    top = ry;
    width = rwidth;
    height = rheight;
  }

  Rectangle<T> intersection(math.Rectangle<T> rect) {
    T rLeft = max(left, rect.left);
    T rTop = max(top, rect.top);
    T rRight = min(right, rect.right);
    T rBottom = min(bottom, rect.bottom);
    return new Rectangle<T>(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }

  // TODO: Consider deprecating this method in favor of the dart:core `boundingBox`
  Rectangle<T> union(math.Rectangle<T> rect) {
    T rLeft = min(left, rect.left);
    T rTop = min(top, rect.top);
    T rRight = max(right, rect.right);
    T rBottom = max(bottom, rect.bottom);
    return new Rectangle<T>(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }

  Rectangle<int> align() {
    int rLeft = left.floor();
    int rTop = top.floor();
    int rRight = right.ceil();
    int rBottom = bottom.ceil();
    return new Rectangle<int>(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }
}