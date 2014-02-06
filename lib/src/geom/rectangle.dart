part of stagexl;

class Rectangle {
  num x;
  num y;
  num width;
  num height;

  Rectangle(this.x, this.y, this.width, this.height);

  Rectangle.zero() : this(0, 0, 0, 0);

  Rectangle.from(Rectangle r) : this(r.x, r.y, r.width, r.height);

  Rectangle clone() => new Rectangle(x, y, width, height);

  String toString() => "Rectangle [x=${x}, y=${y}, width=${width}, height=${height}]";

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  num get left => x;
      set left(num value) { x = value; }

  num get top => y;
      set top(num value) { y = value; }

  num get right => x + width;
      set right(num value) { width = value - x; }

  num get bottom => y + height;
      set bottom(num value) { height = value - y; }

  Point get topLeft => new Point(x, y);
        set topLeft(Point point) {
          width = width + x - point.x;
          height = height + y - point.y;
          x = point.x;
          y = point.y;
        }

  Point get bottomRight => new Point(x + width, y + height);
        set bottomRight(Point point) {
          width = point.x - x;
          height = point.y - y;
        }

  Point get size => new Point(width, height);
        set size(Point point) {
          width = point.x;
          height = point.y;
        }

  Point get center => new Point(x + width / 2, y + height / 2);

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {
    return x <= px && y <= py && right > px && bottom > py;
  }

  bool containsPoint(Point p) {
    return contains(p.x, p.y);
  }

  bool containsRect(Rectangle r) {
    return x <= r.x && y <= r.y && x + width >= r.right && y + height >= r.bottom;
  }

  bool equals(Rectangle r) {
    return x == r.x && y == r.y && width == r.width && height == r.height;
  }

  bool intersects(Rectangle r) {
    return this.left < r.right && this.right > r.left && this.top < r.bottom && this.bottom > r.top;
  }

  bool get isEmpty {
    return width == 0 && height == 0;
  }

  //-----------------------------------------------------------------------------------------------

  void copyFrom(Rectangle r) {
    setTo(r.x, r.y, r.width, r.height);
  }

  void inflate(num dx, num dy) {
    width += dx;
    height += dy;
  }

  void inflatePoint(Point p) {
    inflate(p.x, p.y);
  }

  void offset(num dx, num dy) {
    x += dx;
    y += dy;
  }

  void offsetPoint(Point p) {
    offset(p.x, p.y);
  }

  void setEmpty() {
    setTo(0, 0, 0, 0);
  }

  void setTo(num rx, num ry, num rwidth, num rheight) {
    x = rx;
    y = ry;
    width = rwidth;
    height = rheight;
  }

  Rectangle intersection(Rectangle rect) {
    if (!intersects(rect))
      return new Rectangle.zero();

    num rLeft = max(left, rect.left);
    num rTop = max(top, rect.top);
    num rRight = min(right, rect.right);
    num rBottom = min(bottom, rect.bottom);

    return new Rectangle(rLeft, rRight, rRight - rLeft, rBottom - rTop);
  }

  Rectangle union(Rectangle rect) {
    num rLeft = min(left, rect.left);
    num rTop = min(top, rect.top);
    num rRight = max(right, rect.right);
    num rBottom = max(bottom, rect.bottom);

    return new Rectangle(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }

  Rectangle align() {
    int rLeft = left.floor();
    int rTop = top.floor();
    int rRight = right.ceil();
    int rBottom = bottom.ceil();

    return new Rectangle(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }
}