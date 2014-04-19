part of stagexl;

class Point<T extends num> implements math.Point<T> {

  T x;
  T y;

  Point(this.x, this.y);

  Point.from(math.Point<T> p) : this(p.x, p.y);

  Point<T> clone() => new Point<T>(x, y);

  String toString() => "Point<$T> [x=${x}, y=${y}]";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static num distance(math.Point<num> p1, math.Point<num> p2) => p1.distanceTo(p2);

  static Point<num> interpolate(math.Point<num> p1, math.Point<num> p2, num f) =>
    new Point<num>(p2.x + (p1.x - p2.x) * f, p2.y + (p1.y - p2.y) * f);

  static Point<num> polar(num len, num angle) =>
    new Point<num>(len * cos(angle), len * sin(angle));

  //-------------------------------------------------------------------------------------------------

  /// The distance from the origin (0, 0) coordinates to this Point.
  ///
  /// This property is deprecated. Use [magnitude] instead.
  @deprecated
  num get length => magnitude;

  /**
   * Get the straight line (Euclidean) distance between the origin (0, 0) and
   * this point.
   */
  double get magnitude => sqrt(x * x + y * y);

  Point<T> operator +(math.Point<T> point) => add(point);
  Point<T> operator -(math.Point<T> point) => subtract(point);

  /**
   * Scale this point by [factor] as if it were a vector.
   *
   * *Important* *Note*: This function accepts a `num` as its argument only so
   * that you can scale Point<double> objects by an `int` factor. Because the
   * star operator always returns the same type of Point that originally called
   * it, passing in a double [factor] on a `Point<int>` _causes_ _a_
   * _runtime_ _error_ in checked mode.
   */
  Point<T> operator *(num factor) {
    return new Point<T>(x * factor, y * factor);
  }

  //-------------------------------------------------------------------------------------------------

  /// Adds the coordinates of another Point to the coordinates of this Point
  /// and returns a new Point.
  Point<T> add(math.Point<T> point) => new Point<T>(x + point.x, y + point.y);

  /// Subtracts the coordinates of another Point from the coordinates of this
  /// Point to returns a new Point.
  Point<T> subtract(math.Point<T> point) => new Point<T>(x - point.x, y - point.y);

  /// Determines whether another points are equal this Point.

  bool equals(Point point) => x == point.x && y == point.y;

  /// Copies the coordinates from another Point into this Point.
  void copyFrom(math.Point<T> point) {
    x = point.x;
    y = point.y;
  }

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

  num distanceTo(math.Point<num> point) {
    return sqrt(squaredDistanceTo(point));
  }

  /**
   * Returns the squared distance between `this` and [other].
   *
   * Squared distances can be used for comparisons when the actual value is not
   * required.
   */
  T squaredDistanceTo(math.Point<T> other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return dx * dx + dy * dy;
  }
}
