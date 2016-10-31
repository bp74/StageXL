library stagexl.geom.point;

import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;

import '../internal/jenkins_hash.dart';

class Point<T extends num> implements math.Point<T> {

  @override
  T x;

  @override
  T y;

  Point(this.x, this.y);

  Point.from(math.Point<T> p) : this(p.x, p.y);

  Point<T> clone() => new Point<T>(x, y);

  @override
  String toString() => "Point<$T> [x=$x, y=$y]";

  //---------------------------------------------------------------------------

  static num distance(math.Point<num> p1, math.Point<num> p2) =>
    p1.distanceTo(p2);

  static Point<num> interpolate(math.Point<num> p1, math.Point<num> p2, num f) =>
    new Point<num>(p2.x + (p1.x - p2.x) * f, p2.y + (p1.y - p2.y) * f);

  static Point<num> polar(num len, num angle) =>
    new Point<num>(len * cos(angle), len * sin(angle));

  //---------------------------------------------------------------------------

  /// A `Point` is only equal to another `Point` with the same coordinates.
  ///
  /// This point is equal to `other` if, and only if, `other` is a `Point`
  /// with [x] equal to `other.x` and [y] equal to `other.y`.

  @override
  bool operator ==(Object other) {
    return other is math.Point && this.x == other.x && this.y == other.y;
  }

  @override
  int get hashCode {
    int a = this.x.hashCode;
    int b = this.y.hashCode;
    return JenkinsHash.hash2(a, b);
  }

  /// Add [other] to `this`, as if both points were vectors.
  ///
  /// Returns the resulting "vector" as a Point.

  @override
  Point<T> operator +(math.Point<T> other) {
    return new Point<T>(x + other.x, y + other.y);
  }

  /// Subtract [other] from `this`, as if both points were vectors.
  ///
  /// Returns the resulting "vector" as a Point.

  @override
  Point<T> operator -(math.Point<T> other) {
    return new Point<T>(x - other.x, y - other.y);
  }

  /// Scale this point by [factor] as if it were a vector.
  ///
  /// *Important* *Note*: This function accepts a `num` as its argument only
  /// so that you can scale Point<double> objects by an `int` factor. Because
  /// the star operator always returns the same type of Point that originally
  /// called it, passing in a double [factor] on a `Point<int>` _causes_ _a_
  /// _runtime_ _error_ in checked mode.

  @override
  Point<T> operator *(num/*T|int*/ factor) {
    return new Point<T>(x * factor as T, y * factor as T);
  }

  //-------------------------------------------------------------------------------------------------

  /// Get the straight line (Euclidean) distance between the
  /// origin (0, 0) and this point.

  @override
  double get magnitude => sqrt(x * x + y * y);

  //-------------------------------------------------------------------------------------------------

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

  /// Returns the distance between `this` and [other].

  @override
  double distanceTo(math.Point<T> other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Returns the squared distance between `this` and [other].
  ///
  /// Squared distances can be used for comparisons when the actual
  /// value is not required.

  @override
  T squaredDistanceTo(math.Point<T> other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return dx * dx + dy * dy;
  }
}
