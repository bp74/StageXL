part of stagexl;

class Matrix {

  double _a, _b, _c, _d, _tx, _ty;
  double _det;

  Matrix(num a, num b, num c, num d, num tx, num ty) :
    _a = a.toDouble(),
    _b = b.toDouble(),
    _c = c.toDouble(),
    _d = d.toDouble(),
    _tx = tx.toDouble(),
    _ty = ty.toDouble(),
    _det = (a * d - b * c).toDouble();

  Matrix.fromIdentity() :
    _a = 1.0,
    _b = 0.0,
    _c = 0.0,
    _d = 1.0,
    _tx = 0.0,
    _ty = 0.0,
    _det = 1.0;

  //-------------------------------------------------------------------------------------------------

  String toString() => "Matrix [a=$_a, b=$_b, c=$_c, d=$_d, tx=$_tx, ty=$_ty]";

  Matrix clone() => new Matrix(_a, _b, _c, _d, _tx, _ty);

  Matrix cloneInvert() {

    num a =    (_d / _det);
    num b =  - (_b / _det);
    num c =  - (_c / _det);
    num d =    (_a / _det);
    num tx = - (a * _tx + c * _ty);
    num ty = - (b * _tx + d * _ty);

    return new Matrix(a, b, c, d, tx, ty);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get a => _a;
  num get b => _b;
  num get c => _c;
  num get d => _d;
  num get tx => _tx;
  num get ty => _ty;
  num get det => _det;

  //-------------------------------------------------------------------------------------------------

  Point transformPoint(Point p) {
    var x = p.x.toDouble();
    var y = p.y.toDouble();
    return new Point(x * _a + y * _c + _tx, x * _b + y * _d + _ty);
  }

  Vector transformVector(Vector v) {
    var x = v.x.toDouble();
    var y = v.y.toDouble();
    return new Vector(x * _a + y * _c + _tx, x * _b + y * _d + _ty);
  }

  Point deltaTransformPoint(Point p) {
    var x = p.x.toDouble();
    var y = p.y.toDouble();
    return new Point(x * _a + y * _c, x * _b + y * _d);
  }

  Point _transformHtmlPoint(html.Point p) {
    var x = p.x.toDouble();
    var y = p.y.toDouble();
    return new Point(x * _a + y * _c + _tx, x * _b + y * _d + _ty);
  }

  //-------------------------------------------------------------------------------------------------

  void concat(Matrix matrix) {
    num a1 =   _a;
    num b1 =   _b;
    num c1 =   _c;
    num d1 =   _d;
    num tx1 =  _tx;
    num ty1 =  _ty;
    num det1 = _det;

    num a2 =   matrix.a;
    num b2 =   matrix.b;
    num c2 =   matrix.c;
    num d2 =   matrix.d;
    num tx2 =  matrix.tx;
    num ty2 =  matrix.ty;
    num det2 = matrix.det;

    _a =   (a1 * a2 + b1 * c2).toDouble();
    _b =   (a1 * b2 + b1 * d2).toDouble();
    _c =   (c1 * a2 + d1 * c2).toDouble();
    _d =   (c1 * b2 + d1 * d2).toDouble();
    _tx =  (tx1 * a2 + ty1 * c2 + tx2).toDouble();
    _ty =  (tx1 * b2 + ty1 * d2 + ty2).toDouble();
    _det = (det1 * det2).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void prepend(Matrix matrix) {
    num a1 =   _a;
    num b1 =   _b;
    num c1 =   _c;
    num d1 =   _d;
    num tx1 =  _tx;
    num ty1 =  _ty;
    num det1 = _det;

    num a2 =   matrix.a;
    num b2 =   matrix.b;
    num c2 =   matrix.c;
    num d2 =   matrix.d;
    num tx2 =  matrix.tx;
    num ty2 =  matrix.ty;
    num det2 = matrix.det;

    _a =   (a1 * a2 + c1 * b2).toDouble();
    _b =   (b1 * a2 + d1 * b2).toDouble();
    _c =   (a1 * c2 + c1 * d2).toDouble();
    _d =   (b1 * c2 + d1 * d2).toDouble();
    _tx =  (tx2 * a1 + ty2 * c1 + tx1).toDouble();
    _ty =  (tx2 * b1 + ty2 * d1 + ty1).toDouble();
    _det = (det1 * det2).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  Matrix createBox(num scaleX, num scaleY, [num rotation = 0.0, num translationX = 0.0, num translationY = 0.0]) {

    Matrix matrix = new Matrix.fromIdentity();
    matrix.scale(scaleX, scaleY);
    matrix.rotate(rotation);
    matrix.translate(translationX, translationY);

    return matrix;
  }

  //-------------------------------------------------------------------------------------------------

  void identity() {

    _a =   1.0;
    _b =   0.0;
    _c =   0.0;
    _d =   1.0;
    _tx =  0.0;
    _ty =  0.0;
    _det = 1.0;
  }

  //-------------------------------------------------------------------------------------------------

  void invert() {

    num a =   _a;
    num b =   _b;
    num c =   _c;
    num d =   _d;
    num tx =  _tx;
    num ty =  _ty;
    num det = _det;

    _a =    (d / det).toDouble();
    _b =  - (b / det).toDouble();
    _c =  - (c / det).toDouble();
    _d =    (a / det).toDouble();
    _tx = - (_a * tx + _c * ty).toDouble();
    _ty = - (_b * tx + _d * ty).toDouble();
    _det =  (1.0 / det).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void rotate(num rotation) {

    num cosR = cos(rotation);
    num sinR = sin(rotation);

    num a =  _a;
    num b =  _b;
    num c =  _c;
    num d =  _d;
    num tx = _tx;
    num ty = _ty;

    _a =  (a * cosR - b * sinR).toDouble();
    _b =  (a * sinR + b * cosR).toDouble();
    _c =  (c * cosR - d * sinR).toDouble();
    _d =  (c * sinR + d * cosR).toDouble();
    _tx = (tx * cosR - ty * sinR).toDouble();
    _ty = (tx * sinR + ty * cosR).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void skew(num skewX, num skewY) {

    num sinX = sin(skewX);
    num cosX = cos(skewX);
    num sinY = sin(skewY);
    num cosY = cos(skewY);

    num a =  _a;
    num b =  _b;
    num c =  _c;
    num d =  _d;
    num tx = _tx;
    num ty = _ty;

    _a =   (a * cosY - b * sinX).toDouble();
    _b =   (a * sinY + b * cosX).toDouble();
    _c =   (c * cosY - d * sinX).toDouble();
    _d =   (c * sinY + d * cosX).toDouble();
    _tx =  (tx * cosY - ty * sinX).toDouble();
    _ty =  (tx * sinY + ty * cosX).toDouble();
    _det = (_a * _d - _b * _c).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY) {

    _a   = (  _a * scaleX).toDouble();
    _b   = (  _b * scaleY).toDouble();
    _c   = (  _c * scaleX).toDouble();
    _d   = (  _d * scaleY).toDouble();
    _tx  = ( _tx * scaleX).toDouble();;
    _ty  = ( _ty * scaleY).toDouble();;
    _det = (_det * scaleX * scaleY).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY) {

    _tx = (_tx + translationX).toDouble();;
    _ty = (_ty + translationY).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void setTo(num a, num b, num c, num d, num tx, num ty) {

    _a =   a.toDouble();
    _b =   b.toDouble();
    _c =   c.toDouble();
    _d =   d.toDouble();
    _tx =  tx.toDouble();
    _ty =  ty.toDouble();
    _det = (_a * _d - _b * _c).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void copyFrom(Matrix matrix) {

    _a =   matrix.a.toDouble();
    _b =   matrix.b.toDouble();
    _c =   matrix.c.toDouble();
    _d =   matrix.d.toDouble();
    _tx =  matrix.tx.toDouble();
    _ty =  matrix.ty.toDouble();
    _det = matrix.det.toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndConcat(Matrix copyMatrix, Matrix concatMatrix) {

    num a1 =   copyMatrix.a;
    num b1 =   copyMatrix.b;
    num c1 =   copyMatrix.c;
    num d1 =   copyMatrix.d;
    num tx1 =  copyMatrix.tx;
    num ty1 =  copyMatrix.ty;
    num det1 = copyMatrix.det;

    num a2 =   concatMatrix.a;
    num b2 =   concatMatrix.b;
    num c2 =   concatMatrix.c;
    num d2 =   concatMatrix.d;
    num tx2 =  concatMatrix.tx;
    num ty2 =  concatMatrix.ty;
    num det2 = concatMatrix.det;

    _a =   (a1 * a2 + b1 * c2).toDouble();
    _b =   (a1 * b2 + b1 * d2).toDouble();
    _c =   (c1 * a2 + d1 * c2).toDouble();
    _d =   (c1 * b2 + d1 * d2).toDouble();
    _tx =  (tx1 * a2 + ty1 * c2 + tx2).toDouble();
    _ty =  (tx1 * b2 + ty1 * d2 + ty2).toDouble();
    _det = (det1 * det2).toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndInvert(Matrix matrix) {

    num a =   matrix.a;
    num b =   matrix.b;
    num c =   matrix.c;
    num d =   matrix.d;
    num tx =  matrix.tx;
    num ty =  matrix.ty;
    num det = matrix.det;

    _a =    (d / det).toDouble();
    _b =  - (b / det).toDouble();
    _c =  - (c / det).toDouble();
    _d =    (a / det).toDouble();
    _tx = - (_a * tx + _c * ty).toDouble();
    _ty = - (_b * tx + _d * ty).toDouble();
    _det =  (1.0 / det).toDouble();
  }

}
