part of stagexl;

class Point<T extends num> {

  T x;
  T y;

  Point(this.x, this.y);

  Point.from(Point<T> p) : this(p.x, p.y);

  Point<T> clone() => new Point<T>(x, y);

  String toString() => "Point<$T> [x=${x}, y=${y}]";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static num distance(Point<num> p1, Point<num> p2) => p1.distanceTo(p2);

  static Point<num> interpolate(Point<num> p1, Point<num> p2, num f) =>
    new Point<num>(p2.x + (p1.x - p2.x) * f, p2.y + (p1.y - p2.y) * f);

  static Point<num> polar(num len, num angle) =>
    new Point<num>(len * cos(angle), len * sin(angle));

  //-------------------------------------------------------------------------------------------------

  /// The length/distance from the origin (0, 0) coordinates to this Point.

  num get length => sqrt(x * x + y * y);

  Point<T> operator +(Point<T> point) => add(point);
  Point<T> operator -(Point<T> point) => subtract(point);

  //-------------------------------------------------------------------------------------------------

  /// Adds the coordinates of another Point to the coordinates of this Point
  /// and returns a new Point.

  Point<T> add(Point<T> point) => new Point<T>(x + point.x, y + point.y);

  /// Subtracts the coordinates of another Point from the coordinates of this
  /// Point to returns a new Point.

  Point<T> subtract(Point<T> point) => new Point<T>(x - point.x, y - point.y);

  /// Determines whether another points are equal this Point.

  bool equals(Point point) => x == point.x && y == point.y;

  /// Copies the coordinates from another Point into this Point.

  void copyFrom(Point<T> point) => setTo(point.x, point.y);

  /// Sets the coordinates of this Point to the specified values.

  void setTo(T px, T py) {
    x = px;
    y = py;
  }

  /// Offsets this Point by the specified amount.

  void offset(T dx, T dy) {
    x += dx;
    y += dy;
  }

  /// Calculates the distance from this Point to another Point.

  num distanceTo(Point<num> point) {
    num dx = x - point.x;
    num dy = y - point.y;
    return sqrt(dx * dx + dy * dy);
  }

  //-------------------------------------------------------------------------------------------------

  /// Normalizes the current Point to the specified length. Think of the
  /// current Point as a vector which is scaled. This method is not safe
  /// if this Point is a Point<int> because the new coordinates may
  /// likely be double values.

  void normalize(num length) {
    num currentLength = this.length;
    x = x * length / currentLength;
    y = y * length / currentLength;
  }

  /// Transforms this Point with the specified matrix. This method is not
  /// safe if this Point is a Point<int> because the new coordinates may
  /// likely be double values.

  void transform(Matrix matrix) {
    num currentX = x;
    num currentY = y;
    x = currentX * matrix.a + currentY * matrix.c + matrix.tx;
    y = currentX * matrix.b + currentY * matrix.d + matrix.ty;
  }

  /// Copies the coordinates of another Point into this Point and transforms
  /// this Point with the specified matrix. This method is not safe if this
  /// Point is a Point<int> because the new coordinates may likely be double
  /// values.

  void copyFromAndTransfrom(Point p, Matrix matrix) {
    x = p.x * matrix.a + p.y * matrix.c + matrix.tx;
    y = p.x * matrix.b + p.y * matrix.d + matrix.ty;
  }

}
