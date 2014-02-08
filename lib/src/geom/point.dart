part of stagexl;

class Point {
  num x;
  num y;

  Point(this.x, this.y);

  Point.zero() : this(0, 0);

  Point.from(Point p) : this(p.x, p.y);

  Point clone() => new Point(x, y);

  String toString() => "Point [x=${x}, y=${y}]";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static num distance(Point p1, Point p2) => p1.distanceTo(p2);

  static Point interpolate(Point p1, Point p2, num f) =>
    new Point(p2.x + (p1.x - p2.x) * f, p2.y + (p1.y - p2.y) * f);

  static Point polar(num len, num angle) =>
    new Point(len * cos(angle), len * sin(angle));

  //-------------------------------------------------------------------------------------------------

  num get length => sqrt(x * x + y * y);

  //-------------------------------------------------------------------------------------------------

  Point add(Point p) {
    return new Point(x + p.x, y + p.y);
  }

  Point subtract(Point p) {
    return new Point(x - p.x, y - p.y);
  }

  copyFrom(Point p) {
    setTo(p.x, p.y);
  }

  setTo(num px, num py) {
    x = px;
    y = py;
  }

  bool equals(Point p) {
    return x == p.x && y == p.y;
  }

  normalize(num length) {
    num currentLength = this.length;
    x = x * length / currentLength;
    y = y * length / currentLength;
  }

  offset(num dx, num dy) {
    x += dx;
    y += dy;
  }

  transform(Matrix matrix) {
    num currentX = x;
    num currentY = y;

    x = currentX * matrix.a + currentY * matrix.c + matrix.tx;
    y = currentX * matrix.b + currentY * matrix.d + matrix.ty;
  }

  copyFromAndTransfrom(Point p, Matrix matrix) {
    x = p.x * matrix.a + p.y * matrix.c + matrix.tx;
    y = p.x * matrix.b + p.y * matrix.d + matrix.ty;
  }

  num distanceTo(Point other) {
    num dx = x - other.x;
    num dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}