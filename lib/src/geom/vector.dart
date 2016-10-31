library stagexl.geom.vector;

import 'dart:math' hide Point, Rectangle;
import '../internal/jenkins_hash.dart';

class Vector {

  static const num Epsilon = 0.0000001;
  static const num EpsilonSqr = Epsilon * Epsilon;

  final num x;
  final num y;

  Vector(num x, num y) : x = x.toDouble(), y = y.toDouble();
  const Vector.zero() : x = 0.0, y = 0.0;
  Vector.polar(num len, num angle) : x = (len * cos(angle)).toDouble(), y = (len * sin(angle)).toDouble();

  Vector clone() => new Vector(x, y);

  @override
  String toString() => "Vector [x=$x, y=$y]";

  //-----------------------------------------------------------------------------------------------
  // Operators

  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => new Vector(x - other.x, y - other.y);
  Vector operator *(Vector other) => new Vector(x * other.x, y * other.y);
  Vector operator /(Vector other) => new Vector(x / other.x, y / other.y);

  Vector operator -() => new Vector(-x, -y);

  @override
  bool operator ==(Object other) {
    return other is Vector && this.x == other.x && this.y == other.y;
  }

  @override
  int get hashCode {
    int a = this.x.hashCode;
    int b = this.y.hashCode;
    return JenkinsHash.hash2(a, b);
  }

  bool equalsXY(num x, num y) => this.x == x && this.y == y;

  //-----------------------------------------------------------------------------------------------
  // Queries

  bool get isNormalized => ((x * x + y * y) - 1).abs() < EpsilonSqr;
  bool get isZero => (x == 0 && y == 0);
  bool get isValid => (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) == false;

  bool isNear(Vector other) => distanceSqr(other) < EpsilonSqr;
  bool isNearXY(num x, num y) => distanceXYSqr(x, y) < EpsilonSqr;
  bool isWithin(Vector other, num epsilon) => distanceSqr(other) < epsilon * epsilon;
  bool isWithinXY(num x, num y, num epsilon) => distanceXYSqr(x, y) < epsilon * epsilon;

  num get degrees => atan2(y, x) * 180 / PI;
  num get rads => atan2(y, x);

  //-----------------------------------------------------------------------------------------------
  // Scale

  Vector scale(num scale) {
    return new Vector(x * scale, y * scale);
  }

  Vector scaleLength(num value) {
    var scale = value / length;
    return new Vector(x * scale, y * scale);
  }

  Vector normalize() {
    num nf = 1 / length;
    return new Vector(x * nf, y * nf);
  }

  //-----------------------------------------------------------------------------------------------
  // Distance

  num get length => sqrt(x * x + y * y);
  num get lengthSqr => x * x + y * y;

  num distance(Vector vec) {
    num xd = x - vec.x;
    num yd = y - vec.y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceXY(num x, num y) {
    num xd = this.x - x;
    num yd = this.y - y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceSqr(Vector vec) {
    num xd = x - vec.x;
    num yd = y - vec.y;
    return xd * xd + yd * yd;
  }

  num distanceXYSqr(num x, num y) {
    num xd = this.x - x;
    num yd = this.y - y;
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
    num s = sin(rads);
    num c = cos(rads);
    return new Vector(x * c - y * s, x * s + y * c);
  }

  Vector normalRight() {
    return new Vector(-y, x);
  }

  Vector normalLeft() {
    return new Vector(y, -x);
  }

  Vector negate() {
    return new Vector(-x, -y);
  }

  //-----------------------------------------------------------------------------------------------
  // Spinor rotation

  Vector rotateSpinor(Vector vec) {
    return new Vector(x * vec.x - y * vec.y, x * vec.y + y * vec.x);
  }

  Vector spinorBetween(Vector vec) {
    num d = this.lengthSqr;
    num r = (vec.x * x + vec.y * y) / d;
    num i = (vec.y * x - vec.x * y) / d;
    return new Vector(r, i);
  }

  //-----------------------------------------------------------------------------------------------
  // Lerp / slerp

  Vector lerp(Vector to, num t) {
    return new Vector(x + t * (to.x - x), y + t * (to.y - y));
  }

  Vector slerp(Vector vec, num t) {
    num cosTheta = this.dot(vec);
    num theta = acos(cosTheta);
    num sinTheta = sin(theta);

    if (sinTheta <= Epsilon)
      return vec.clone();

    num w1 = sin((1 - t) * theta) / sinTheta;
    num w2 = sin(t * theta) / sinTheta;
    return this.scale(w1) + vec.scale(w2);
  }

  //-----------------------------------------------------------------------------------------------
  // Reflect

  Vector reflect(Vector normal) {
    num d = 2 * (x * normal.x + y * normal.y);
    return new Vector(x - d * normal.x, y - d * normal.y);
  }

}
