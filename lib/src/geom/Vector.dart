part of stagexl;

class Vector {

  static const num Epsilon = 0.0000001;
  static const num EpsilonSqr = Epsilon * Epsilon;

  final num _x;
  final num _y;

  Vector(num x, num y) : _x = x.toDouble(), _y = y.toDouble();
  Vector.zero() : _x = 0.0, _y = 0.0;
  Vector.polar(num len, num angle) : _x = (len * cos(angle)).toDouble(), _y = (len * sin(angle)).toDouble();

  Vector clone() => new Vector(_x, _y);

  num get x => _x;
  num get y => _y;

  String toString() => "Vector [x=${_x}, y=${_y}]";

  //-----------------------------------------------------------------------------------------------
  // Operators

  Vector operator +(Vector other) => new Vector(_x + other._x, _y + other._y);
  Vector operator -(Vector other) => new Vector(_x - other._x, _y - other._y);
  Vector operator *(Vector other) => new Vector(_x * other._x, _y * other._y);
  Vector operator /(Vector other) => new Vector(_x / other._x, _y / other._y);

  Vector operator -() => new Vector(-_x, -_y);
  bool operator ==(Vector other) => _x == other._x && _y == other._y;

  // ToDo: http://dartbug.com/11617
  int get hashCode => _x.hashCode + _y.hashCode * 7;

  bool equalsXY(num x, num y) => _x == x && _y == y;

  //-----------------------------------------------------------------------------------------------
  // Queries

  bool get isNormalized => ((_x * _x + _y * _y) - 1).abs() < EpsilonSqr;
  bool get isZero => (_x == 0 && _y == 0);
  bool get isValid => (_x.isNaN || _y.isNaN || _x.isInfinite || _y.isInfinite) == false;

  bool isNear(Vector other) => distanceSqr(other) < EpsilonSqr;
  bool isNearXY(num x, num y) => distanceXYSqr(x, y) < EpsilonSqr;
  bool isWithin(Vector other, num epsilon) => distanceSqr(other) < epsilon * epsilon;
  bool isWithinXY(num x, num y, num epsilon) => distanceXYSqr(x, y) < epsilon * epsilon;

  num get degrees => atan2(_y, _x) * 180 / PI;
  num get rads => atan2(_y, _x);

  //-----------------------------------------------------------------------------------------------
  // Scale

  Vector scale(num scale) {
    return new Vector(_x * scale, _y * scale);
  }

  Vector scaleLength(num value) {
    var scale = value / length;
    return new Vector(_x * scale, _y * scale);
  }

  Vector normalize() {
    num nf = 1 / length;
    return new Vector(_x * nf, _y * nf);
  }

  //-----------------------------------------------------------------------------------------------
  // Distance

  num get length => sqrt(_x * _x + _y * _y);
  num get lengthSqr => _x * _x + _y * _y;

  num distance(Vector vec) {
    num xd = _x - vec._x;
    num yd = _y - vec._y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceXY(num x, num y) {
    num xd = _x - x;
    num yd = _y - y;
    return sqrt(xd * xd + yd * yd);
  }

  num distanceSqr(Vector vec) {
    num xd = _x - vec._x;
    num yd = _y - vec._y;
    return xd * xd + yd * yd;
  }

  num distanceXYSqr(num x, num y) {
    num xd = _x - x;
    num yd = _y - y;
    return xd * xd + yd * yd;
  }

  //-----------------------------------------------------------------------------------------------
  // Dot product

  num dot(Vector vec) => _x * vec._x + _y * vec._y;
  num dotXY(num x, num y) => _x * x + _y * y;

  //-----------------------------------------------------------------------------------------------
  // Cross determinant

  num crossDet(Vector vec) => _x * vec._y - _y * vec._x;
  num crossDetXY(num x, num y) => _x * y - _y * x;

  //-----------------------------------------------------------------------------------------------
  // Rotate

  Vector rotate(num rads) {
    num s = sin(rads);
    num c = cos(rads);
    return new Vector(_x * c - _y * s, _x * s + _y * c);
  }

  Vector normalRight() {
    return new Vector(-_y, _x);
  }

  Vector normalLeft() {
    return new Vector(_y, -_x);
  }

  Vector negate() {
    return new Vector(-_x, -_y);
  }

  //-----------------------------------------------------------------------------------------------
  // Spinor rotation

  Vector rotateSpinor(Vector vec) {
    return new Vector(_x * vec._x - _y * vec._y, _x * vec._y + _y * vec._x);
  }

  Vector spinorBetween(Vector vec) {
    num d = this.lengthSqr;
    num r = (vec._x * _x + vec._y * _y) / d;
    num i = (vec._y * _x - vec._x * _y) / d;
    return new Vector(r, i);
  }

  //-----------------------------------------------------------------------------------------------
  // Lerp / slerp

  Vector lerp(Vector to, num t) {
    return new Vector(_x + t * (to._x - _x), _y + t * (to._y - _y));
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
    num d = 2 * (_x * normal._x + _y * normal._y);
    return new Vector(_x - d * normal._x, _y - d * normal._y);
  }

}
