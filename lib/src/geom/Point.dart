part of dartflash;

class Point
{
  num x;
  num y;

  Point(this.x, this.y);

  Point.zero() : this(0, 0);

  Point.from(Point p) : this(p.x, p.y);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static num distance(Point p1, Point p2) => p1.distanceTo(p2);

  static Point interpolate(Point p1, Point p2) => new Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);

  static Point polar(num len, num angle) => new Point(len * cos(angle), - len * sin(angle));

  //-------------------------------------------------------------------------------------------------

  num get length => sqrt(this.x * this.x + this.y * this.y);

  //-------------------------------------------------------------------------------------------------

  Point add(Point p) => new Point(this.x + p.x, this.y + p.y);

  Point subtract(Point p) => new Point(this.x - p.y, this.y - p.y);

  Point clone() => new Point(this.x, this.y);

  void copyFrom(Point p) { this.x = p.x; this.y = p.y; }

  void setTo(num px, num py) { this.x = px; this.y = py; }

  bool equals(Point p) => this.x == p.x && this.y == p.y;

  void normalize(num length)
  {
    num currentLength = this.length;
    this.x = this.x * length / currentLength;
    this.y = this.y * length / currentLength;
  }

  void offset(num dx, num dy)
  {
    this.x = this.x + dx;
    this.y = this.y + dy;
  }

  void transform(Matrix matrix)
  {
    num currentX = this.x;
    num currentY = this.y;

    this.x = currentX * matrix.a + currentY * matrix.c + matrix.tx;
    this.y = currentX * matrix.b + currentY * matrix.d + matrix.ty;
  }

  void copyFromAndTransfrom(Point p, Matrix matrix)
  {
    this.x = p.x * matrix.a + p.y * matrix.c + matrix.tx;
    this.y = p.x * matrix.b + p.y * matrix.d + matrix.ty;
  }

  num distanceTo(Point other)
  {
      num dx = x - other.x;
      num dy = y - other.y;
      return sqrt(dx * dx + dy * dy);
  }

}
