part of dartflash;

class Matrix
{
  num _a, _b, _c, _d, _tx, _ty;
  num _det;

  Matrix(num a, num b, num c, num d, num tx, num ty) :
    _a = a, _b = b, _c = c, _d = d, _tx = tx, _ty = ty, _det = a * d - b * c;

  Matrix.fromIdentity() :
    _a = 1.0, _b = 0.0, _c = 0.0, _d = 1.0, _tx = 0.0, _ty = 0.0, _det = 1.0;

  //-------------------------------------------------------------------------------------------------

  Matrix clone()
  {
    return new Matrix(_a, _b, _c, _d, _tx, _ty);
  }

  Matrix cloneInvert()
  {
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

  Point transformPoint(Point p)
  {
    return new Point(p.x * _a + p.y * _c + _tx, p.x * _b + p.y * _d + _ty);
  }

  Point deltaTransformPoint(Point p)
  {
    return new Point(p.x * _a + p.y * _c, p.x * _b + p.y * _d);
  }

  //-------------------------------------------------------------------------------------------------

  void concat(Matrix matrix)
  {
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

    _a =   (a1 * a2 + b1 * c2);
    _b =   (a1 * b2 + b1 * d2);
    _c =   (c1 * a2 + d1 * c2);
    _d =   (c1 * b2 + d1 * d2);
    _tx =  (tx1 * a2 + ty1 * c2 + tx2);
    _ty =  (tx1 * b2 + ty1 * d2 + ty2);
    _det = (det1 * det2);
  }

  //-------------------------------------------------------------------------------------------------

  Matrix createBox(num scaleX, num scaleY, [num rotation = 0.0, num translationX = 0.0, num translationY = 0.0])
  {
    Matrix matrix = new Matrix.fromIdentity();
    matrix.scale(scaleX, scaleY);
    matrix.rotate(rotation);
    matrix.translate(translationX, translationY);

    return matrix;
  }

  //-------------------------------------------------------------------------------------------------

  void identity()
  {
    _a =   1.0;
    _b =   0.0;
    _c =   0.0;
    _d =   1.0;
    _tx =  0.0;
    _ty =  0.0;
    _det = 1.0;
  }

  //-------------------------------------------------------------------------------------------------

  void invert()
  {
    num a =   _a;
    num b =   _b;
    num c =   _c;
    num d =   _d;
    num tx =  _tx;
    num ty =  _ty;
    num det = _det;

    _a =    (d / det);
    _b =  - (b / det);
    _c =  - (c / det);
    _d =    (a / det);
    _tx = - (_a * tx + _c * ty);
    _ty = - (_b * tx + _d * ty);
    _det =  (1.0 / det);
  }

  //-------------------------------------------------------------------------------------------------

  void rotate(num rotation)
  {
    num cosR = cos(rotation);
    num sinR = sin(rotation);

    num a =  _a;
    num b =  _b;
    num c =  _c;
    num d =  _d;
    num tx = _tx;
    num ty = _ty;

    _a =  (a * cosR - b * sinR);
    _b =  (a * sinR + b * cosR);
    _c =  (c * cosR - d * sinR);
    _d =  (c * sinR + d * cosR);
    _tx = (tx * cosR - ty * sinR);
    _ty = (tx * sinR + ty * cosR);
  }

  //-------------------------------------------------------------------------------------------------

  void skew(num skewX, num skewY)
  {
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
    
    _a =   (a * cosY - b * sinX);
    _b =   (a * sinY + b * cosX);
    _c =   (c * cosY - d * sinX);
    _d =   (c * sinY + d * cosX);
    _tx =  (tx * cosY - ty * sinX);
    _ty =  (tx * sinY + ty * cosX);
    _det = (_a * _d - _b * _c);
  }

  //-------------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY)
  {
    _a   *= scaleX;
    _b   *= scaleY;
    _c   *= scaleX;
    _d   *= scaleY;
    _tx  *= scaleX;
    _ty  *= scaleY;
    _det *= scaleX * scaleY;
  }

  //-------------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY)
  {
    _tx += translationX;
    _ty += translationY;
  }

  //-------------------------------------------------------------------------------------------------

  void setTo(num a, num b, num c, num d, num tx, num ty)
  {
    _a =   a;
    _b =   b;
    _c =   c;
    _d =   d;
    _tx =  tx;
    _ty =  ty;
    _det = (a * d - b * c);
  }

  //-------------------------------------------------------------------------------------------------

  void copyFrom(Matrix matrix)
  {
    _a =   matrix.a;
    _b =   matrix.b;
    _c =   matrix.c;
    _d =   matrix.d;
    _tx =  matrix.tx;
    _ty =  matrix.ty;
    _det = matrix.det;
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndConcat(Matrix copyMatrix, Matrix concatMatrix)
  {
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

    _a =   (a1 * a2 + b1 * c2);
    _b =   (a1 * b2 + b1 * d2);
    _c =   (c1 * a2 + d1 * c2);
    _d =   (c1 * b2 + d1 * d2);
    _tx =  (tx1 * a2 + ty1 * c2 + tx2);
    _ty =  (tx1 * b2 + ty1 * d2 + ty2);
    _det = (det1 * det2);
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndInvert(Matrix matrix)
  {
    num a =   matrix.a;
    num b =   matrix.b;
    num c =   matrix.c;
    num d =   matrix.d;
    num tx =  matrix.tx;
    num ty =  matrix.ty;
    num det = matrix.det;

    _a =    (d / det);
    _b =  - (b / det);
    _c =  - (c / det);
    _d =    (a / det);
    _tx = - (_a * tx + _c * ty);
    _ty = - (_b * tx + _d * ty);
    _det =  (1.0 / det);
  }

}
