library stagexl.geom.matrix_3d;

import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;
import 'dart:typed_data';

import 'matrix.dart';

class Matrix3D {

  final Float32List _data = new Float32List(16);

  Matrix3D.fromIdentity() {
    this.setIdentity();
  }

  Matrix3D.fromZero() {
    this.setZero();
  }

  Matrix3D.fromMatrix2D(Matrix matrix) {
    this.copyFromMatrix2D(matrix);
  }

  Matrix3D.fromMatrix3D(Matrix3D matrix) {
    this.copyFromMatrix3D(matrix);
  }

  Matrix3D clone() => new Matrix3D.fromMatrix3D(this);

  //-----------------------------------------------------------------------------------------------

  Float32List get data => _data;

  num get m00 => _data[00];
  num get m01 => _data[04];
  num get m02 => _data[08];
  num get m03 => _data[12];

  num get m10 => _data[01];
  num get m11 => _data[05];
  num get m12 => _data[09];
  num get m13 => _data[13];

  num get m20 => _data[02];
  num get m21 => _data[06];
  num get m22 => _data[10];
  num get m23 => _data[14];

  num get m30 => _data[03];
  num get m31 => _data[07];
  num get m32 => _data[11];
  num get m33 => _data[15];

  //-----------------------------------------------------------------------------------------------

  void setIdentity() {
    _data[00] = 1.0; _data[01] = 0.0; _data[02] = 0.0; _data[03] = 0.0;
    _data[04] = 0.0; _data[05] = 1.0; _data[06] = 0.0; _data[07] = 0.0;
    _data[08] = 0.0; _data[09] = 0.0; _data[10] = 1.0; _data[11] = 0.0;
    _data[12] = 0.0; _data[13] = 0.0; _data[14] = 0.0; _data[15] = 1.0;
  }

  void setZero() {
    _data[00] = 0.0; _data[01] = 0.0; _data[02] = 0.0; _data[03] = 0.0;
    _data[04] = 0.0; _data[05] = 0.0; _data[06] = 0.0; _data[07] = 0.0;
    _data[08] = 0.0; _data[09] = 0.0; _data[10] = 0.0; _data[11] = 0.0;
    _data[12] = 0.0; _data[13] = 0.0; _data[14] = 0.0; _data[15] = 0.0;
  }

  //-----------------------------------------------------------------------------------------------

  void scale(num scaleX, num scaleY, num scaleZ) {

    _data[00] *= scaleX;
    _data[01] *= scaleX;
    _data[02] *= scaleX;
    _data[03] *= scaleX;

    _data[04] *= scaleY;
    _data[05] *= scaleY;
    _data[06] *= scaleY;
    _data[07] *= scaleY;

    _data[08] *= scaleZ;
    _data[09] *= scaleZ;
    _data[10] *= scaleZ;
    _data[11] *= scaleZ;
  }

  //-----------------------------------------------------------------------------------------------

  void translate(num translationX, num translationY, num translationZ) {

    _data[03] += translationX;
    _data[07] += translationY;
    _data[11] += translationZ;
  }

  //-----------------------------------------------------------------------------------------------

  void rotateX(num angle) {

    num cos = math.cos(angle);
    num sin = math.sin(angle);
    num m01 = this.m01;
    num m11 = this.m11;
    num m21 = this.m21;
    num m31 = this.m31;
    num m02 = this.m02;
    num m12 = this.m12;
    num m22 = this.m22;
    num m32 = this.m32;

    _data[04] = m01 * cos + m02 * sin;
    _data[05] = m11 * cos + m12 * sin;
    _data[06] = m21 * cos + m22 * sin;
    _data[07] = m31 * cos + m32 * sin;
    _data[08] = m02 * cos - m01 * sin;
    _data[09] = m12 * cos - m11 * sin;
    _data[10] = m22 * cos - m21 * sin;
    _data[11] = m32 * cos - m31 * sin;
}

  void rotateY(num angle) {

    num cos = math.cos(angle);
    num sin = math.sin(angle);
    num m00 = this.m00;
    num m10 = this.m10;
    num m20 = this.m20;
    num m30 = this.m30;
    num m02 = this.m02;
    num m12 = this.m12;
    num m22 = this.m22;
    num m32 = this.m32;

    _data[00] = m00 * cos + m02 * sin;
    _data[01] = m10 * cos + m12 * sin;
    _data[02] = m20 * cos + m22 * sin;
    _data[03] = m30 * cos + m32 * sin;
    _data[08] = m02 * cos - m00 * sin;
    _data[09] = m12 * cos - m10 * sin;
    _data[10] = m22 * cos - m20 * sin;
    _data[11] = m32 * cos - m30 * sin;
  }

  void rotateZ(num angle) {

    num cos = math.cos(angle);
    num sin = math.sin(angle);
    num m00 = this.m00;
    num m10 = this.m10;
    num m20 = this.m20;
    num m30 = this.m30;
    num m01 = this.m01;
    num m11 = this.m11;
    num m21 = this.m21;
    num m31 = this.m31;

    _data[00] = m00 * cos - m01 * sin;
    _data[01] = m10 * cos - m11 * sin;
    _data[02] = m20 * cos - m21 * sin;
    _data[03] = m30 * cos - m31 * sin;
    _data[04] = m01 * cos + m00 * sin;
    _data[05] = m11 * cos + m10 * sin;
    _data[06] = m21 * cos + m20 * sin;
    _data[07] = m31 * cos + m30 * sin;
  }

  //-------------------------------------------------------------------------------------------------

  void copyFromMatrix2D(Matrix matrix) {

    _data[00] = matrix.a;
    _data[01] = matrix.c;
    _data[02] = 0.0;
    _data[03] = matrix.tx;

    _data[04] = matrix.b;
    _data[05] = matrix.d;
    _data[06] = 0.0;
    _data[07] = matrix.ty;

    _data[08] = 0.0;
    _data[09] = 0.0;
    _data[10] = 1.0;
    _data[11] = 0.0;

    _data[12] = 0.0;
    _data[13] = 0.0;
    _data[14] = 0.0;
    _data[15] = 1.0;
  }

  void copyFromMatrix3D(Matrix3D matrix) {

    _data[00] = matrix.m00;
    _data[01] = matrix.m10;
    _data[02] = matrix.m20;
    _data[03] = matrix.m30;
    _data[04] = matrix.m01;
    _data[05] = matrix.m11;
    _data[06] = matrix.m21;
    _data[07] = matrix.m31;
    _data[08] = matrix.m02;
    _data[09] = matrix.m12;
    _data[10] = matrix.m22;
    _data[11] = matrix.m32;
    _data[12] = matrix.m03;
    _data[13] = matrix.m13;
    _data[14] = matrix.m23;
    _data[15] = matrix.m33;
  }

  //-----------------------------------------------------------------------------------------------

  void concat(Matrix3D matrix) => copyFromAndConcat(this, matrix);

  void copyFromAndConcat(Matrix3D copyMatrix, Matrix3D concatMatrix) {

    num m00 = copyMatrix.m00;
    num m01 = copyMatrix.m01;
    num m02 = copyMatrix.m02;
    num m03 = copyMatrix.m03;
    num m10 = copyMatrix.m10;
    num m11 = copyMatrix.m11;
    num m12 = copyMatrix.m12;
    num m13 = copyMatrix.m13;
    num m20 = copyMatrix.m20;
    num m21 = copyMatrix.m21;
    num m22 = copyMatrix.m22;
    num m23 = copyMatrix.m23;
    num m30 = copyMatrix.m30;
    num m31 = copyMatrix.m31;
    num m32 = copyMatrix.m32;
    num m33 = copyMatrix.m33;

    num n00 = concatMatrix.m00;
    num n01 = concatMatrix.m01;
    num n02 = concatMatrix.m02;
    num n03 = concatMatrix.m03;
    num n10 = concatMatrix.m10;
    num n11 = concatMatrix.m11;
    num n12 = concatMatrix.m12;
    num n13 = concatMatrix.m13;
    num n20 = concatMatrix.m20;
    num n21 = concatMatrix.m21;
    num n22 = concatMatrix.m22;
    num n23 = concatMatrix.m23;
    num n30 = concatMatrix.m30;
    num n31 = concatMatrix.m31;
    num n32 = concatMatrix.m32;
    num n33 = concatMatrix.m33;

    _data[00] = m00 * n00 + m01 * n10 + m02 * n20 + m03 * n30;
    _data[01] = m10 * n00 + m11 * n10 + m12 * n20 + m13 * n30;
    _data[02] = m20 * n00 + m21 * n10 + m22 * n20 + m23 * n30;
    _data[03] = m30 * n00 + m31 * n10 + m32 * n20 + m33 * n30;
    _data[04] = m00 * n01 + m01 * n11 + m02 * n21 + m03 * n31;
    _data[05] = m10 * n01 + m11 * n11 + m12 * n21 + m13 * n31;
    _data[06] = m20 * n01 + m21 * n11 + m22 * n21 + m23 * n31;
    _data[07] = m30 * n01 + m31 * n11 + m32 * n21 + m33 * n31;
    _data[08] = m00 * n02 + m01 * n12 + m02 * n22 + m03 * n32;
    _data[09] = m10 * n02 + m11 * n12 + m12 * n22 + m13 * n32;
    _data[10] = m20 * n02 + m21 * n12 + m22 * n22 + m23 * n32;
    _data[11] = m30 * n02 + m31 * n12 + m32 * n22 + m33 * n32;
    _data[12] = m00 * n03 + m01 * n13 + m02 * n23 + m03 * n33;
    _data[13] = m10 * n03 + m11 * n13 + m12 * n23 + m13 * n33;
    _data[14] = m20 * n03 + m21 * n13 + m22 * n23 + m23 * n33;
    _data[15] = m30 * n03 + m31 * n13 + m32 * n23 + m33 * n33;
  }

}