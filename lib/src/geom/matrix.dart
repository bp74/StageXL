library stagexl.geom.matrix;

import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;
import 'dart:typed_data';

import 'point.dart';
import 'vector.dart';

class Matrix {

  final Float32List _data = new Float32List(6);

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

  String toString() => "Matrix [a=$a, b=$b, c=$c, d=$d, tx=$tx, ty=$ty]";

  Matrix clone() => new Matrix(a, b, c, d, tx, ty);

  Matrix cloneInvert() {

    num det =  this.det;
    num a =    this.d / det;
    num b =  - this.b / det;
    num c =  - this.c / det;
    num d =    this.a / det;
    num tx = - this.tx * a - this.ty * c;
    num ty = - this.tx * b - this.ty * d;

    return new Matrix(a, b, c, d, tx, ty);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get a =>  _data[0];
  void set a (num n){
    _data[0] = n.toDouble();
  }
  num get b =>  _data[1];
  void set b (num n){
    _data[1] = n.toDouble();
  }
  num get c =>  _data[2];
  void set c (num n){
    _data[2] = n.toDouble();
  }
  num get d =>  _data[3];
  void set d (num n){
    _data[3] = n.toDouble();
  }
  num get tx => _data[4];
  void set tx (num n){
    _data[4] = n.toDouble();
  }
  num get ty => _data[5];
  void set ty (num n){
    _data[5] = n.toDouble();
  }

  num get det => a * d - b * c;

  //-------------------------------------------------------------------------------------------------

  Point<num> deltaTransformPoint(math.Point<num> p) {
    var x = p.x.toDouble();
    var y = p.y.toDouble();
    return new Point<num>(x * this.a + y * this.c, x * this.b + y * this.d);
  }

  Point<num> transformPoint(math.Point<num> p) {
    var x = p.x.toDouble();
    var y = p.y.toDouble();
    return new Point<num>(x * this.a + y * this.c + this.tx, x * this.b + y * this.d + this.ty);
  }

  Vector transformVector(Vector v) {
    var x = v.x.toDouble();
    var y = v.y.toDouble();
    return new Vector(x * this.a + y * this.c + this.tx, x * this.b + y * this.d + this.ty);
  }

  //-------------------------------------------------------------------------------------------------

  void createBox(num scaleX, num scaleY, [
    num rotation = 0.0, num translationX = 0.0, num translationY = 0.0]) {

    this.identity();
    this.scale(scaleX, scaleY);
    this.rotate(rotation);
    this.translate(translationX, translationY);
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

    num a =   this.a;
    num b =   this.b;
    num c =   this.c;
    num d =   this.d;
    num tx =  this.tx;
    num ty =  this.ty;
    num det = this.det;

    _data[0] =   d / det;
    _data[1] = - b / det;
    _data[2] = - c / det;
    _data[3] =   a / det;
    _data[4] = - tx * _data[0] - ty * _data[2];
    _data[5] = - tx * _data[1] - ty * _data[3];
  }

  //-------------------------------------------------------------------------------------------------

  void rotate(num rotation) {

    num cosR = cos(rotation);
    num sinR = sin(rotation);

    num a =  this.a;
    num b =  this.b;
    num c =  this.c;
    num d =  this.d;
    num tx = this.tx;
    num ty = this.ty;

    _data[0] = a * cosR - b * sinR;
    _data[1] = a * sinR + b * cosR;
    _data[2] = c * cosR - d * sinR;
    _data[3] = c * sinR + d * cosR;
    _data[4] = tx * cosR - ty * sinR;
    _data[5] = tx * sinR + ty * cosR;
  }

  //-------------------------------------------------------------------------------------------------

  void skew(num skewX, num skewY) {

    num sinX = sin(skewX);
    num cosX = cos(skewX);
    num sinY = sin(skewY);
    num cosY = cos(skewY);

    num a =  this.a;
    num b =  this.b;
    num c =  this.c;
    num d =  this.d;
    num tx = this.tx;
    num ty = this.ty;

    _data[0] = a * cosY - b * sinX;
    _data[1] = a * sinY + b * cosX;
    _data[2] = c * cosY - d * sinX;
    _data[3] = c * sinY + d * cosX;
    _data[4] = tx * cosY - ty * sinX;
    _data[5] = tx * sinY + ty * cosX;
  }

  //-------------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY) {
    _data[0] = this.a * scaleX;
    _data[1] = this.b * scaleY;
    _data[2] = this.c * scaleX;
    _data[3] = this.d * scaleY;
    _data[4] = this.tx * scaleX;
    _data[5] = this.ty * scaleY;
  }

  //-------------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY) {
    _data[4] = this.tx + translationX;
    _data[5] = this.ty + translationY;
  }

  void prependTranslation(num translationX, num translationY) {
    _data[4] = translationX * this.a + translationY * this.c + this.tx;
    _data[5] = translationX * this.b + translationY * this.d + this.ty;
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
    this.copyFromAndConcat(this, matrix);
  }

  void prepend(Matrix matrix) {
    this.copyFromAndConcat(matrix, this);
  }

  void copyFromAndConcat(Matrix copyMatrix, Matrix concatMatrix) {

    num a1 =  copyMatrix.a;
    num b1 =  copyMatrix.b;
    num c1 =  copyMatrix.c;
    num d1 =  copyMatrix.d;
    num tx1 = copyMatrix.tx;
    num ty1 = copyMatrix.ty;

    num a2 =  concatMatrix.a;
    num b2 =  concatMatrix.b;
    num c2 =  concatMatrix.c;
    num d2 =  concatMatrix.d;
    num tx2 = concatMatrix.tx;
    num ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * c2;
    _data[1] = a1 * b2 + b1 * d2;
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + tx2;
    _data[5] = tx1 * b2 + ty1 * d2 + ty2;
  }

  //-------------------------------------------------------------------------------------------------

  void invertAndConcat(Matrix concatMatrix) {

    num det =   this.det;
    num a1 =    this.d / det;
    num b1 =  - this.b / det;
    num c1 =  - this.c / det;
    num d1 =    this.a / det;
    num tx1 = - this.tx * a1 - this.ty * c1;
    num ty1 = - this.tx * b1 - this.ty * d1;

    num a2 =  concatMatrix.a;
    num b2 =  concatMatrix.b;
    num c2 =  concatMatrix.c;
    num d2 =  concatMatrix.d;
    num tx2 = concatMatrix.tx;
    num ty2 = concatMatrix.ty;

    _data[0] = a1 * a2 + b1 * c2;
    _data[1] = a1 * b2 + b1 * d2;
    _data[2] = c1 * a2 + d1 * c2;
    _data[3] = c1 * b2 + d1 * d2;
    _data[4] = tx1 * a2 + ty1 * c2 + tx2;
    _data[5] = tx1 * b2 + ty1 * d2 + ty2;
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

    _data[0] =   d / det;
    _data[1] = - b / det;
    _data[2] = - c / det;
    _data[3] =   a / det;
    _data[4] = - tx * _data[0] - ty * _data[2];
    _data[5] = - tx * _data[1] - ty * _data[3];
  }

}
