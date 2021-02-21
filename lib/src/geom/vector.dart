library stagexl.geom.vector;

import 'dart:math' hide Point, Rectangle;
import '../internal/jenkins_hash.dart';

class Vector {
  static const num Epsilon = 0.0000001;
  static const num EpsilonSqr = Epsilon * Epsilon;

  final num x;
  final num y;

  Vector(num x, num y)
      : x = x.toDouble(),
        y = y.toDouble();
  const Vector.zero()
      : x = 0.0,
        y = 0.0;
  Vector.polar(num len, num angle)
      : x = (len * cos(angle)).toDouble(),
        y = (len * sin(angle)).toDouble();

  Vector clone() => Vector(x, y);

  @override
  String toString() => 'Vector [x=$x, y=$y]';

  //-----------------------------------------------------------------------------------------------
  // Operators

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => Vector(x - other.x, y - other.y);
  Vector operator *(Vector other) => Vector(x * other.x, y * other.y);
  Vector operator /(Vector other) => Vector(x / other.x, y / other.y);

  Vector operator -() => Vector(-x, -y);

  @override
  bool operator ==(Object other) =>
      other is Vector && x == other.x && y == other.y;

  @override
  int get hashCode {
    final a = x.hashCode;
    final b = y.hashCode;
    return JenkinsHash.hash2(a, b);
  }

  bool equalsXY(num x, num y) => this.x == x && this.y == y;

  //-----------------------------------------------------------------------------------------------
  // Queries

  bool get isNormalized => ((x * x + y * y) - 1).abs() < EpsilonSqr;
  bool get isZero => x == 0 && y == 0;
  bool get isValid =>
      (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) == false;

  bool isNear(Vector other) => distanceSqr(other) < EpsilonSqr;
  bool isNearXY(num x, num y) => distanceXYSqr(x, y) < EpsilonSqr;
  bool isWithin(Vector other, num epsilon) =>
      distanceSqr(other) < epsilon * epsilon;
  bool isWithinXY(num x, num y, num epsilon) =>
      distanceXYSqr(x, y) < epsilon * epsilon;

  num get degrees => atan2(y, x) * 180 / pi;
  num get rads => atan2(y, x);

  //-----------------------------------------------------------------------------------------------
  // Scale

  Vector scale(num scale) => Vector(x * scale, y * scale);

  Vector scaleLength(num value) {
    final scale = value / length;
    return Vector(x * scale, y * scale);
  }

  Vector normalize() {
    final num nf = 1 / length;
    return Vector(x * nf, y * nf);
  }

  //-----------------------------------------------------------------------------------------------
  // Distance

  num get length => sqrt(x * x + y * y);
  num get lengthSqr => x * x + y * y;

  num distance(Vector vec) {
    final xd = x - vec.x;
    final yd = y - vec.y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceXY(num x, num y) {
    final xd = this.x - x;
    final yd = this.y - y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceSqr(Vector vec) {
    final xd = x - vec.x;
    final yd = y - vec.y;
    return xd * xd + yd * yd;
  }

  num distanceXYSqr(num x, num y) {
    final xd = this.x - x;
    final yd = this.y - y;
    return xd * xd + yd * yd;
  }

  //-----------------------------------------------------------------------------------------------
  // Dot product

  num dot(Vector vec) => x * vec.x + y * vec.y;
  num dotXY(num x, num y) => this.x * x + this.y * y;

  //-----------------------------------------------------------------------------------------------
  // Cross determinant

  num crossDet(Vector vec) => x * vec.y - y * vec.x;
  num crossDetXY(num x, num y) => this.x * y - this.y * x;

  //-----------------------------------------------------------------------------------------------
  // Rotate

  Vector rotate(num rads) {
    final num s = sin(rads);
    final num c = cos(rads);
    return Vector(x * c - y * s, x * s + y * c);
  }

  Vector normalRight() => Vector(-y, x);

  Vector normalLeft() => Vector(y, -x);

  Vector negate() => Vector(-x, -y);

  //-----------------------------------------------------------------------------------------------
  // Spinor rotation

  Vector rotateSpinor(Vector vec) =>
      Vector(x * vec.x - y * vec.y, x * vec.y + y * vec.x);

  Vector spinorBetween(Vector vec) {
    final d = lengthSqr;
    final r = (vec.x * x + vec.y * y) / d;
    final i = (vec.y * x - vec.x * y) / d;
    return Vector(r, i);
  }

  //-----------------------------------------------------------------------------------------------
  // Lerp / slerp

  Vector lerp(Vector to, num t) =>
      Vector(x + t * (to.x - x), y + t * (to.y - y));

  Vector slerp(Vector vec, num t) {
    final cosTheta = dot(vec);
    final theta = acos(cosTheta);
    final sinTheta = sin(theta);

    if (sinTheta <= Epsilon) return vec.clone();

    final w1 = sin((1 - t) * theta) / sinTheta;
    final w2 = sin(t * theta) / sinTheta;
    return scale(w1) + vec.scale(w2);
  }

  //-----------------------------------------------------------------------------------------------
  // Reflect

  Vector reflect(Vector normal) {
    final d = 2 * (x * normal.x + y * normal.y);
    return Vector(x - d * normal.x, y - d * normal.y);
  }
}
