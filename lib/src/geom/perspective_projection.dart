library stagexl.geom.perspective_projection;

import 'matrix_3d.dart';

class PerspectiveProjection {

  final Matrix3D transformationMatrix3D = new Matrix3D.fromIdentity();

  factory PerspectiveProjection() {
    return new PerspectiveProjection.fromDepth(10000, 10);
  }

  // TODO: Add a more comprehensible PerspectiveProjection constructor

  PerspectiveProjection.fromDepth(num depth, num scale) {
    transformationMatrix3D.setIdentity();
    transformationMatrix3D.data[10] = 2.0 / depth;
    transformationMatrix3D.data[14] = scale / depth;
  }
}
