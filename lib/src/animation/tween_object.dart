part of '../animation.dart';

/// The abstract base class for [TweenObject2D] and [TweenObject3D].

abstract class TweenObject {
  // Basically just a plain object. But we declare if for
  // better documentation and to get a base class for all
  // derived TweenObjectXXXX classes.
}

/// The [TweenObject2D] class defines the interface for a class
/// that can used with the [Tween.animate] method.
///
/// All display objects do implement this interface.

abstract class TweenObject2D extends TweenObject {
  num x = 0;
  num y = 0;
  num pivotX = 0;
  num pivotY = 0;
  num scaleX = 1;
  num scaleY = 1;
  num skewX = 0;
  num skewY = 0;
  num rotation = 0;
  num alpha = 1;
}

/// The [TweenObject3D] class defines the interface for a class
/// that can used with the [Tween.animate3D] method.
///
/// All 3D display objects do implement this interface.

abstract class TweenObject3D extends TweenObject {
  num offsetX = 0;
  num offsetY = 0;
  num offsetZ = 0;
  num rotationX = 0;
  num rotationY = 0;
  num rotationZ = 0;
}
