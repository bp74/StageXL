import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;
import 'dart:typed_data';

import 'point.dart';
import 'rectangle.dart';
import 'vector.dart';

class Matrix {
  final Float32List _data = Float32List(6);

  Matrix(num a, num b, num c, num d, num tx, num ty) {
    _data[0] = a.toDouble();
    _data[1] = b.toDouble();
    _data[2] = c.toDouble();
    _data[3] = d.toDouble();
    _data[4] = tx.toDouble();
    _data[5] = ty.toDouble();
  }

  Matrix.fromIdentity() {
    _data[0] = 1.0;
    _data[1] = 0.0;
    _data[2] = 0.0;
    _data[3] = 1.0;
    _data[4] = 0.0;
    _data[5] = 0.0;
  }

  //-------------------------------------------------------------------------------------------------

  @override
  String toString() => 'Matrix [a=$a, b=$b, c=$c, d=$d, tx=$tx, ty=$ty]';

  Matrix clone() => Matrix(a, b, c, d, tx, ty);

  Matrix cloneInvert() {
    final det = this.det;
    final a = this.d / det;
    final b = -this.b / det;
    final c = -this.c / det;
    final d = this.a / det;
    final tx = -this.tx * a - this.ty * c;
    final ty = -this.tx * b - this.ty * d;

    return Matrix(a, b, c, d, tx, ty);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  double get a => _data[0];

  set a(num n) {
    _data[0] = n.toDouble();
  }

  double get b => _data[1];

  set b(num n) {
    _data[1] = n.toDouble();
  }

  double get c => _data[2];

  set c(num n) {
    _data[2] = n.toDouble();
  }

  double get d => _data[3];

  set d(num n) {
    _data[3] = n.toDouble();
  }

  double get tx => _data[4];

  set tx(num n) {
    _data[4] = n.toDouble();
  }

  double get ty => _data[5];

  set ty(num n) {
    _data[5] = n.toDouble();
  }

  double get det => a * d - b * c;

  //-------------------------------------------------------------------------------------------------

  Vector transformVector(Vector vector) {
    final vx = vector.x.toDouble();
    final vy = vector.y.toDouble();
    final tx = vx * a + vy * c + this.tx;
    final ty = vx * b + vy * d + this.ty;

    return Vector(tx, ty);
  }

  Point<num> deltaTransformPoint(math.Point<num> point,
      [Point<num>? returnPoint]) {
    final px = point.x.toDouble();
    final py = point.y.toDouble();
    final tx = px * a + py * c;
    final ty = px * b + py * d;

    if (returnPoint is Point) {
      returnPoint.setTo(tx, ty);
      return returnPoint;
    } else {
      return Point<num>(tx, ty);
    }
  }

  //-------------------------------------------------------------------------------------------------

  Point<num> transformPoint(math.Point<num> point, [Point<num>? returnPoint]) {
    final px = point.x.toDouble();
    final py = point.y.toDouble();
    final tx = px * a + py * c + this.tx;
    final ty = px * b + py * d + this.ty;

    if (returnPoint is Point) {
      returnPoint.setTo(tx, ty);
      return returnPoint;
    } else {
      return Point<num>(tx, ty);
    }
  }

  Point<num> transformPointInverse(math.Point<num> point,
      [Point<num>? returnPoint]) {
    final px = point.x.toDouble();
    final py = point.y.toDouble();
    final tx = (d * (px - this.tx) - c * (py - this.ty)) / det;
    final ty = (a * (py - this.ty) - b * (px - this.tx)) / det;

    if (returnPoint is Point) {
      returnPoint.setTo(tx, ty);
      return returnPoint;
    } else {
      return Point<num>(tx, ty);
    }
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle<num> transformRectangle(math.Rectangle<num> rectangle,
      [Rectangle<num>? returnRectangle]) {
    final num rl = rectangle.left.toDouble();
    final num rr = rectangle.right.toDouble();
    final num rt = rectangle.top.toDouble();
    final num rb = rectangle.bottom.toDouble();

    // transform rectangle corners

    final x1 = rl * a + rt * c;
    final y1 = rl * b + rt * d;
    final x2 = rr * a + rt * c;
    final y2 = rr * b + rt * d;
    final x3 = rr * a + rb * c;
    final y3 = rr * b + rb * d;
    final x4 = rl * a + rb * c;
    final y4 = rl * b + rb * d;

    // find minima and maxima

    var left = x1;
    if (left > x2) left = x2;
    if (left > x3) left = x3;
    if (left > x4) left = x4;

    var top = y1;
    if (top > y2) top = y2;
    if (top > y3) top = y3;
    if (top > y4) top = y4;

    var right = x1;
    if (right < x2) right = x2;
    if (right < x3) right = x3;
    if (right < x4) right = x4;

    var bottom = y1;
    if (bottom < y2) bottom = y2;
    if (bottom < y3) bottom = y3;
    if (bottom < y4) bottom = y4;

    final width = right - left;
    final heigth = bottom - top;

    if (returnRectangle is Rectangle) {
      returnRectangle.setTo(tx + left, ty + top, width, heigth);
      return returnRectangle;
    } else {
      return Rectangle<num>(tx + left, ty + top, width, heigth);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void createBox(num scaleX, num scaleY,
      [num rotation = 0.0, num translationX = 0.0, num translationY = 0.0]) {
    identity();
    scale(scaleX, scaleY);
    rotate(rotation);
    translate(translationX, translationY);
  }

  //-------------------------------------------------------------------------------------------------

  void identity() {
    _data[0] = 1.0;
    _data[1] = 0.0;
    _data[2] = 0.0;
    _data[3] = 1.0;
    _data[4] = 0.0;
    _data[5] = 0.0;
  }

  //-------------------------------------------------------------------------------------------------

  void invert() {
    final a = this.a;
    final b = this.b;
    final c = this.c;
    final d = this.d;
    final tx = this.tx;
    final ty = this.ty;
    final det = this.det;

    _data[0] = d / det;
    _data[1] = -b / det;
    _data[2] = -c / det;
    _data[3] = a / det;
    _data[4] = -tx * _data[0] - ty * _data[2];
    _data[5] = -tx * _data[1] - ty * _data[3];
  }

  //-------------------------------------------------------------------------------------------------

  void rotate(num rotation) {
    final cosR = cos(rotation);
    final sinR = sin(rotation);

    final a = this.a;
    final b = this.b;
    final c = this.c;
    final d = this.d;
    final tx = this.tx;
    final ty = this.ty;

    _data[0] = a * cosR - b * sinR;
    _data[1] = a * sinR + b * cosR;
    _data[2] = c * cosR - d * sinR;
    _data[3] = c * sinR + d * cosR;
    _data[4] = tx * cosR - ty * sinR;
    _data[5] = tx * sinR + ty * cosR;
  }

  //-------------------------------------------------------------------------------------------------

  void skew(num skewX, num skewY) {
    final sinX = sin(skewX);
    final cosX = cos(skewX);
    final sinY = sin(skewY);
    final cosY = cos(skewY);

    final a = this.a;
    final b = this.b;
    final c = this.c;
    final d = this.d;
    final tx = this.tx;
    final ty = this.ty;

    _data[0] = a * cosY - b * sinX;
    _data[1] = a * sinY + b * cosX;
    _data[2] = c * cosY - d * sinX;
    _data[3] = c * sinY + d * cosX;
    _data[4] = tx * cosY - ty * sinX;
    _data[5] = tx * sinY + ty * cosX;
  }

  //-------------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY) {
    _data[0] = a * scaleX;
    _data[1] = b * scaleY;
    _data[2] = c * scaleX;
    _data[3] = d * scaleY;
    _data[4] = tx * scaleX;
    _data[5] = ty * scaleY;
  }

  //-------------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY) {
    _data[4] = tx + translationX;
    _data[5] = ty + translationY;
  }

  void prependTranslation(num translationX, num translationY) {
    _data[4] = translationX * a + translationY * c + tx;
    _data[5] = translationX * b + translationY * d + ty;
  }

  //-------------------------------------------------------------------------------------------------

  void setTo(num a, num b, num c, num d, num tx, num ty) {
    _data[0] = a.toDouble();
    _data[1] = b.toDouble();
    _data[2] = c.toDouble();
    _data[3] = d.toDouble();
    _data[4] = tx.toDouble();
    _data[5] = ty.toDouble();
  }

  //-------------------------------------------------------------------------------------------------

  void copyFrom(Matrix matrix) {
    _data[0] = matrix.a;
    _data[1] = matrix.b;
    _data[2] = matrix.c;
    _data[3] = matrix.d;
    _data[4] = matrix.tx;
    _data[5] = matrix.ty;
  }

  //-------------------------------------------------------------------------------------------------

  void concat(Matrix matrix) {
    copyFromAndConcat(this, matrix);
  }

  void prepend(Matrix matrix) {
    copyFromAndConcat(matrix, this);
  }

  void copyFromAndConcat(Matrix copyMatrix, Matrix concatMatrix) {
    final a1 = copyMatrix.a;
    final b1 = copyMatrix.b;
    final c1 = copyMatrix.c;
    final d1 = copyMatrix.d;
    final tx1 = copyMatrix.tx;
    final ty1 = copyMatrix.ty;

    final a2 = concatMatrix.a;
    final b2 = concatMatrix.b;
    final c2 = concatMatrix.c;
    final d2 = concatMatrix.d;
    final tx2 = concatMatrix.tx;
    final ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * c2;
    _data[1] = a1 * b2 + b1 * d2;
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + tx2;
    _data[5] = tx1 * b2 + ty1 * d2 + ty2;
  }

  //-------------------------------------------------------------------------------------------------

  void invertAndConcat(Matrix concatMatrix) {
    final det = this.det;
    final a1 = d / det;
    final b1 = -b / det;
    final c1 = -c / det;
    final d1 = a / det;
    final tx1 = -tx * a1 - ty * c1;
    final ty1 = -tx * b1 - ty * d1;

    final a2 = concatMatrix.a;
    final b2 = concatMatrix.b;
    final c2 = concatMatrix.c;
    final d2 = concatMatrix.d;
    final tx2 = concatMatrix.tx;
    final ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * c2;
    _data[1] = a1 * b2 + b1 * d2;
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + tx2;
    _data[5] = tx1 * b2 + ty1 * d2 + ty2;
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndInvert(Matrix matrix) {
    final a = matrix.a;
    final b = matrix.b;
    final c = matrix.c;
    final d = matrix.d;
    final tx = matrix.tx;
    final ty = matrix.ty;
    final det = matrix.det;

    _data[0] = d / det;
    _data[1] = -b / det;
    _data[2] = -c / det;
    _data[3] = a / det;
    _data[4] = -tx * _data[0] - ty * _data[2];
    _data[5] = -tx * _data[1] - ty * _data[3];
  }
}
