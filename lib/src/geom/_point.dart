part of stagexl;

class Point {

  num _x;
  num _y;

  Point(num x, num y) : _x = x, _y = y;

  Point.zero() : this(0, 0);

  Point.from(Point p) : this(p.x, p.y);

  Point clone() => new Point(_x, _y);

  String toString() => "Point [x=${_x}, y=${_y}]";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static num distance(Point p1, Point p2) => p1.distanceTo(p2);

  static Point interpolate(Point p1, Point p2, num f) =>
    new Point(p2.x + (p1.x - p2.x) * f, p2.y + (p1.y - p2.y) * f);

  static Point polar(num len, num angle) =>
    new Point(len * cos(angle), len * sin(angle));

  //-------------------------------------------------------------------------------------------------

  num get x => _x;
  num get y => _y;

  num get length => sqrt(_x * _x + _y * _y);

  set x(num value) {
    _x = value;
  }

  set y(num value) {
    _y = value;
  }

  //-------------------------------------------------------------------------------------------------

  Point add(Point p) {
    return new Point(_x + p.x, _y + p.y);
  }

  Point subtract(Point p) {
    return new Point(_x - p.x, _y - p.y);
  }

  copyFrom(Point p) {
    _x = p.x;
    _y = p.y;
  }

  setTo(num px, num py) {
    _x = px;
    _y = py;
  }

  bool equals(Point p) {
    return _x == p.x && _y == p.y;
  }

  normalize(num length) {
    num currentLength = this.length;
    _x = _x * length / currentLength;
    _y = _y * length / currentLength;
  }

  offset(num dx, num dy) {
    _x = _x + dx;
    _y = _y + dy;
  }

  transform(Matrix matrix) {
    num currentX = _x;
    num currentY = _y;

    _x = currentX * matrix.a + currentY * matrix.c + matrix.tx;
    _y = currentX * matrix.b + currentY * matrix.d + matrix.ty;
  }

  copyFromAndTransfrom(Point p, Matrix matrix) {
    _x = p.x * matrix.a + p.y * matrix.c + matrix.tx;
    _y = p.x * matrix.b + p.y * matrix.d + matrix.ty;
  }

  num distanceTo(Point other) {
    num dx = x - other.x;
    num dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

}
