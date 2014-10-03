part of stagexl.display;

/// The [Sprite3D] class enables 3D transformations of 2D display objects.
///
/// Use the [rotationX], [rotationY] and [rotationZ] properties to rotate the
/// display object in 3D space. Use the [offsetX], [offsetY] and [offsetZ]
/// properties to move the display object in 3D space.
///
/// Example:
///
///     var flip = new Sprite3D()
///     flip.addChild(bitmap);
///     flip.rotationY = PI / 4
///     flip.addTo(stage);
///
class Sprite3D extends DisplayObjectContainer3D {

  // Currently the Sprite3D class does not add features
  // to the DisplayObjectContainer3D implementation.

}