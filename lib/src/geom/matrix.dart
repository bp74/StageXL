library stagexl.geom.matrix;

import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;
import 'dart:typed_data';

import 'point.dart';
import 'vector.dart';
import 'rectangle.dart';

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
    var det = this.det;
    var a = this.d / det;
    var b = -this.b / det;
    var c = -this.c / det;
    var d = this.a / det;
    num tx = -this.tx * a - this.ty * c;
    num ty = -this.tx * b - this.ty * d;

    return Matrix(a, b, c, d, tx, ty);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get a => _data[0];

  set a(num n) {
    _data[0] = n.toDouble();
  }

  num get b => _data[1];

  set b(num n) {
    _data[1] = n.toDouble();
  }

  num get c => _data[2];

  set c(num n) {
    _data[2] = n.toDouble();
  }

  num get d => _data[3];

  set d(num n) {
    _data[3] = n.toDouble();
  }

  num get tx => _data[4];

  set tx(num n) {
    _data[4] = n.toDouble();
  }

  num get ty => _data[5];

  set ty(num n) {
    _data[5] = n.toDouble();
  }

  num get det => a * d - b * c;

  //-------------------------------------------------------------------------------------------------

  Vector transformVector(Vector vector) {
    var vx = vector.x.toDouble();
    var vy = vector.y.toDouble();
    var tx = vx * a + vy * c + this.tx;
    var ty = vx * b + vy * d + this.ty;

    return Vector(tx, ty);
  }

  Point<num> deltaTransformPoint(math.Point<num> point,
      [Point<num>? returnPoint]) {
    var px = point.x.toDouble();
    var py = point.y.toDouble();
    var tx = px * a + py * c;
    var ty = px * b + py * d;

    if (returnPoint is Point) {
      returnPoint.setTo(tx, ty);
      return returnPoint;
    } else {
      return Point<num>(tx, ty);
    }
  }

  //-------------------------------------------------------------------------------------------------

  Point<num> transformPoint(math.Point<num> point, [Point<num>? returnPoint]) {
    var px = point.x.toDouble();
    var py = point.y.toDouble();
    var tx = px * a + py * c + this.tx;
    var ty = px * b + py * d + this.ty;

    if (returnPoint is Point) {
      returnPoint.setTo(tx, ty);
      return returnPoint;
    } else {
      return Point<num>(tx, ty);
    }
  }

  Point<num> transformPointInverse(math.Point<num> point,
      [Point<num>? returnPoint]) {
    var px = point.x.toDouble();
    var py = point.y.toDouble();
    var tx = (d * (px - this.tx) - c * (py - this.ty)) / det;
    var ty = (a * (py - this.ty) - b * (px - this.tx)) / det;

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
    num rl = rectangle.left.toDouble();
    num rr = rectangle.right.toDouble();
    num rt = rectangle.top.toDouble();
    num rb = rectangle.bottom.toDouble();

    // transform rectangle corners

    var x1 = rl * a + rt * c;
    var y1 = rl * b + rt * d;
    var x2 = rr * a + rt * c;
    var y2 = rr * b + rt * d;
    var x3 = rr * a + rb * c;
    var y3 = rr * b + rb * d;
    var x4 = rl * a + rb * c;
    var y4 = rl * b + rb * d;

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

    var width = right - left;
    var heigth = bottom - top;

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
    var a = this.a;
    var b = this.b;
    var c = this.c;
    var d = this.d;
    var tx = this.tx;
    var ty = this.ty;
    var det = this.det;

    _data[0] = d / det;
    _data[1] = -b / det;
    _data[2] = -c / det;
    _data[3] = a / det;
    _data[4] = -tx * _data[0] - ty * _data[2];
    _data[5] = -tx * _data[1] - ty * _data[3];
  }

  //-------------------------------------------------------------------------------------------------

  void rotate(num rotation) {
    var cosR = cos(rotation);
    var sinR = sin(rotation);

    var a = this.a;
    var b = this.b;
    var c = this.c;
    var d = this.d;
    var tx = this.tx;
    var ty = this.ty;

    _data[0] = a * cosR - b * sinR;
    _data[1] = a * sinR + b * cosR;
    _data[2] = c * cosR - d * sinR;
    _data[3] = c * sinR + d * cosR;
    _data[4] = tx * cosR - ty * sinR;
    _data[5] = tx * sinR + ty * cosR;
  }

  //-------------------------------------------------------------------------------------------------

  void skew(num skewX, num skewY) {
    var sinX = sin(skewX);
    var cosX = cos(skewX);
    var sinY = sin(skewY);
    var cosY = cos(skewY);

    var a = this.a;
    var b = this.b;
    var c = this.c;
    var d = this.d;
    var tx = this.tx;
    var ty = this.ty;

    _data[0] = a * cosY - b * sinX;
    _data[1] = a * sinY + b * cosX;
    _data[2] = c * cosY - d * sinX;
    _data[3] = c * sinY + d * cosX;
    _data[4] = tx * cosY - ty * sinX;
    _data[5] = tx * sinY + ty * cosX;
  }

  //-------------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY) {
    _data[0] = a * (scaleX as double);
    _data[1] = b * (scaleY as double);
    _data[2] = c * scaleX;
    _data[3] = d * scaleY;
    _data[4] = tx * scaleX;
    _data[5] = ty * scaleY;
  }

  //-------------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY) {
    _data[4] = tx + (translationX as double);
    _data[5] = ty + (translationY as double);
  }

  void prependTranslation(num translationX, num translationY) {
    _data[4] = translationX * a + translationY * c + (tx as double);
    _data[5] = translationX * b + translationY * d + (ty as double);
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
    _data[0] = matrix.a as double;
    _data[1] = matrix.b as double;
    _data[2] = matrix.c as double;
    _data[3] = matrix.d as double;
    _data[4] = matrix.tx as double;
    _data[5] = matrix.ty as double;
  }

  //-------------------------------------------------------------------------------------------------

  void concat(Matrix matrix) {
    copyFromAndConcat(this, matrix);
  }

  void prepend(Matrix matrix) {
    copyFromAndConcat(matrix, this);
  }

  void copyFromAndConcat(Matrix copyMatrix, Matrix concatMatrix) {
    var a1 = copyMatrix.a;
    var b1 = copyMatrix.b;
    var c1 = copyMatrix.c;
    var d1 = copyMatrix.d;
    var tx1 = copyMatrix.tx;
    var ty1 = copyMatrix.ty;

    var a2 = concatMatrix.a;
    var b2 = concatMatrix.b;
    var c2 = concatMatrix.c;
    var d2 = concatMatrix.d;
    var tx2 = concatMatrix.tx;
    var ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * (c2 as double);
    _data[1] = a1 * b2 + b1 * (d2 as double);
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + tx2;
    _data[5] = tx1 * b2 + ty1 * d2 + ty2;
  }

  //-------------------------------------------------------------------------------------------------

  void invertAndConcat(Matrix concatMatrix) {
    var det = this.det;
    var a1 = d / det;
    var b1 = -b / det;
    var c1 = -c / det;
    var d1 = a / det;
    num tx1 = -tx * a1 - ty * c1;
    num ty1 = -tx * b1 - ty * d1;

    var a2 = concatMatrix.a;
    var b2 = concatMatrix.b;
    var c2 = concatMatrix.c;
    var d2 = concatMatrix.d;
    var tx2 = concatMatrix.tx;
    var ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * c2;
    _data[1] = a1 * b2 + b1 * d2;
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + (tx2 as double);
    _data[5] = tx1 * b2 + ty1 * d2 + (ty2 as double);
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromAndInvert(Matrix matrix) {
    var a = matrix.a;
    var b = matrix.b;
    var c = matrix.c;
    var d = matrix.d;
    var tx = matrix.tx;
    var ty = matrix.ty;
    var det = matrix.det;

    _data[0] = d / det;
    _data[1] = -b / det;
    _data[2] = -c / det;
    _data[3] = a / det;
    _data[4] = -tx * _data[0] - ty * _data[2];
    _data[5] = -tx * _data[1] - ty * _data[3];
  }
}
