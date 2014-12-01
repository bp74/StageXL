part of stagexl.animation;

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
  num x, y;
  num pivotX, pivotY;
  num scaleX, scaleY;
  num skewX, skewY;
  num rotation;
  num alpha;
}

/// The [TweenObject3D] class defines the interface for a class
/// that can used with the [Tween.animate3D] method.
///
/// All 3D display objects do implement this interface.

abstract class TweenObject3D extends TweenObject {
  num offsetX;
  num offsetY;
  num offsetZ;
  num rotationX;
  num rotationY;
  num rotationZ;
}
