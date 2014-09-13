library stagexl.geom.perspective_projection;

import 'matrix_3d.dart';

class PerspectiveProjection {

  final Matrix3D perspectiveMatrix3D = new Matrix3D.fromIdentity();

  factory PerspectiveProjection() {
    return new PerspectiveProjection.fromDepth(10000, 10);
  }

  // TODO: Add a more comprehensible PerspectiveProjection constructor

  PerspectiveProjection.fromDepth(num depth, num scale) {
    perspectiveMatrix3D.setIdentity();
    perspectiveMatrix3D.data[10] = 2.0 / depth;
    perspectiveMatrix3D.data[14] = scale / depth;
  }
}
