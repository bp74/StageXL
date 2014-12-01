library stagexl.geom.perspective_projection;

import 'matrix_3d.dart';

/// The [PerspectiveProjection] defines the matrix that is used to projection
/// 3D display objects on a 2D plane like the stage or other display objects.
///
class PerspectiveProjection {

  final Matrix3D perspectiveMatrix3D = new Matrix3D.fromIdentity();

  /// Creates a default perspective projection which should be suitable for
  /// most use cases.
  ///
  factory PerspectiveProjection() {
    return new PerspectiveProjection.fromDepth(10000, 10);
  }

  /// Creates a perspective projection with custom [depth] and [scale] values.
  ///
  /// The [depth] defines the distance to the farthest display object after
  /// the 3D transformation. The [scale] defines the distortion of the 3D
  /// objects caused by an imaginary lense.
  ///
  /// The values used by the default constructor are 10000 and 10.
  ///
  PerspectiveProjection.fromDepth(num depth, num scale) {
    perspectiveMatrix3D.setIdentity();
    perspectiveMatrix3D.data[10] = 1.0 / depth;
    perspectiveMatrix3D.data[14] = scale / depth;
  }

  /// Creates a perspective projection for 3D objects which are children of
  /// other 3D objects. For those display objects no perspective projection
  /// should be applied.
  ///
  PerspectiveProjection.none() {
    perspectiveMatrix3D.setIdentity();
  }

}
