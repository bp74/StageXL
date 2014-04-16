part of stagexl;

class Rectangle<T extends num> {

  T x;
  T y;
  T width;
  T height;

  Rectangle(this.x, this.y, this.width, this.height);

  Rectangle.from(Rectangle<T> r) : this(r.x, r.y, r.width, r.height);

  Rectangle<T> clone() => new Rectangle<T>(x, y, width, height);

  String toString() => "Rectangle<$T> [x=${x}, y=${y}, width=${width}, height=${height}]";

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  T get left => x;
  set left(T value) { x = value; }

  T get top => y;
  set top(T value) { y = value; }

  T get right => x + width;
  set right(T value) { width = value - x; }

  T get bottom => y + height;
  set bottom(T value) { height = value - y; }

  Point<T> get topLeft => new Point<T>(x, y);
  set topLeft(Point<T> point) {
    width = width + x - point.x;
    height = height + y - point.y;
    x = point.x;
    y = point.y;
  }

  Point<T> get bottomRight => new Point<T>(x + width, y + height);
  set bottomRight(Point<T> point) {
    width = point.x - x;
    height = point.y - y;
  }

  Point<T> get size => new Point<T>(width, height);
  set size(Point<T> point) {
    width = point.x;
    height = point.y;
  }

  Point<num> get center => new Point<num>(x + width / 2, y + height / 2);

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {
    return x <= px && y <= py && right > px && bottom > py;
  }

  bool containsPoint(Point<num> p) {
    return contains(p.x, p.y);
  }

  bool containsRect(Rectangle<num> r) {
    return x <= r.x && y <= r.y && x + width >= r.right && y + height >= r.bottom;
  }

  bool equals(Rectangle<num> r) {
    return x == r.x && y == r.y && width == r.width && height == r.height;
  }

  bool intersects(Rectangle<num> r) {
    return this.left < r.right && this.right > r.left && this.top < r.bottom && this.bottom > r.top;
  }

  bool get isEmpty {
    return width <= 0 || height <= 0;
  }

  //-----------------------------------------------------------------------------------------------

  void copyFrom(Rectangle<T> r) {
    setTo(r.x, r.y, r.width, r.height);
  }

  void inflate(T dx, T dy) {
    width += dx;
    height += dy;
  }

  void inflatePoint(Point<T> p) {
    inflate(p.x, p.y);
  }

  void offset(T dx, T dy) {
    x += dx;
    y += dy;
  }

  void offsetPoint(Point<T> p) {
    offset(p.x, p.y);
  }

  void setTo(T rx, T ry, T rwidth, T rheight) {
    x = rx;
    y = ry;
    width = rwidth;
    height = rheight;
  }

  Rectangle<T> intersection(Rectangle<T> rect) {
    T rLeft = max(left, rect.left);
    T rTop = max(top, rect.top);
    T rRight = min(right, rect.right);
    T rBottom = min(bottom, rect.bottom);
    return new Rectangle<T>(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }

  Rectangle<T> union(Rectangle<T> rect) {
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