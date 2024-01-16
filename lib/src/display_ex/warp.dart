part of '../display_ex.dart';

/// A display object with custom 2D transformation matrix.
///
/// The 2D transformation matrix of the [Warp] class is not calculated based on
/// the standard [DisplayObject] properties like x, y or rotation. In fact all
/// changes to those properties are ignored. Instead you can change the values
/// of the [transformationMatrix] on your own.

class Warp extends DisplayObjectContainer {
  Matrix matrix = Matrix.fromIdentity();

  @override
  Matrix get transformationMatrix => matrix;
}
