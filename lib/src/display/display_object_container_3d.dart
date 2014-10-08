part of stagexl.display;

/// The abstract [DisplayObjectContainer3D] class enables 3D transformations
/// of 2D display objects.
///
/// Use the [rotationX], [rotationY] and [rotationZ] properties to rotate the
/// display object in 3D space. Use the [offsetX], [offsetY] and [offsetZ]
/// properties to move the display object in 3D space.
///
abstract class DisplayObjectContainer3D extends DisplayObjectContainer {

  PerspectiveProjection perspectiveProjection = new PerspectiveProjection();

  num _offsetX = 0.0;
  num _offsetY = 0.0;
  num _offsetZ = 0.0;
  num _rotationX = 0.0;
  num _rotationY = 0.0;
  num _rotationZ = 0.0;

  bool _transformationMatrix3DRefresh = false;
  final Matrix3D _transformationMatrix3D = new Matrix3D.fromIdentity();
  final Matrix3D _oldProjectionMatrix3D = new Matrix3D.fromIdentity();
  final Matrix3D _newProjectionMatrix3D = new Matrix3D.fromIdentity();

  //-----------------------------------------------------------------------------------------------

  /// The offset to the x-axis for all children in 3D space.
  num get offsetX => _offsetX;
  /// The offset to the y-axis for all children in 3D space.
  num get offsetY => _offsetY;
  /// The offset to the z-axis for all children in 3D space.
  num get offsetZ => _offsetZ;

  /// The x-axis rotation in 3D space.
  num get rotationX => _rotationX;
  /// The y-axis rotation in 3D space.
  num get rotationY => _rotationY;
  /// The z-axis rotation in 3D space.
  num get rotationZ => _rotationZ;

  set offsetX(num value) {
    if (value is num) _offsetX = value;
    _transformationMatrix3DRefresh = true;
  }

  set offsetY(num value) {
    if (value is num) _offsetY = value;
    _transformationMatrix3DRefresh = true;
  }

  set offsetZ(num value) {
    if (value is num) _offsetZ = value;
    _transformationMatrix3DRefresh = true;
  }

  set rotationX(num value) {
    if (value is num) _rotationX = value;
    _transformationMatrix3DRefresh = true;
  }

  set rotationY(num value) {
    if (value is num) _rotationY = value;
    _transformationMatrix3DRefresh = true;
  }

  set rotationZ(num value) {
    if (value is num) _rotationZ = value;
    _transformationMatrix3DRefresh = true;
  }

  //-----------------------------------------------------------------------------------------------

  Matrix3D get transformationMatrix3D {

    if (_transformationMatrix3DRefresh) {
      _transformationMatrix3DRefresh = false;
      _transformationMatrix3D.setIdentity();
      _transformationMatrix3D.rotateX(0.0 - rotationX);
      _transformationMatrix3D.rotateY(0.0 + rotationY);
      _transformationMatrix3D.rotateZ(0.0 - rotationZ);
      _transformationMatrix3D.translate(offsetX, offsetY, offsetZ);
    }

    return _transformationMatrix3D;
  }

  //-----------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    // This calculation is simplified for optimal performance. To get a more
    // accurate result we would need to transform all children to 3D space.
    // The current calculation should be sufficient for most use cases.

    Rectangle rectangle = super.getBoundsTransformed(_identityMatrix, returnRectangle);
    num rl = rectangle.left.toDouble();
    num rr = rectangle.right.toDouble();
    num rt = rectangle.top.toDouble();
    num rb = rectangle.bottom.toDouble();

    // transform rectangle corners

    _calculateNewProjectionMatrix3D(matrix);

    num m00 = _newProjectionMatrix3D.m00;
    num m10 = _newProjectionMatrix3D.m10;
    num m30 = _newProjectionMatrix3D.m30;
    num m01 = _newProjectionMatrix3D.m01;
    num m11 = _newProjectionMatrix3D.m11;
    num m31 = _newProjectionMatrix3D.m31;
    num m03 = _newProjectionMatrix3D.m03;
    num m13 = _newProjectionMatrix3D.m13;
    num m33 = _newProjectionMatrix3D.m33;

    num d1 = (m03 * rl + m13 * rt + m33);
    num x1 = (m00 * rl + m10 * rt + m30) / d1;
    num y1 = (m01 * rl + m11 * rt + m31) / d1;
    num d2 = (m03 * rr + m13 * rt + m33);
    num x2 = (m00 * rr + m10 * rt + m30) / d2;
    num y2 = (m01 * rr + m11 * rt + m31) / d2;
    num d3 = (m03 * rr + m13 * rb + m33);
    num x3 = (m00 * rr + m10 * rb + m30) / d3;
    num y3 = (m01 * rr + m11 * rb + m31) / d3;
    num d4 = (m03 * rl + m13 * rb + m33);
    num x4 = (m00 * rl + m10 * rb + m30) / d4;
    num y4 = (m01 * rl + m11 * rb + m31) / d4;

    // find minima and maxima

    num left = x1;
    if (left > x2) left = x2;
    if (left > x3) left = x3;
    if (left > x4) left = x4;

    num top = y1;
    if (top > y2) top = y2;
    if (top > y3) top = y3;
    if (top > y4) top = y4;

    num right = x1;
    if (right < x2) right = x2;
    if (right < x3) right = x3;
    if (right < x4) right = x4;

    num bottom = y1;
    if (bottom < y2) bottom = y2;
    if (bottom < y3) bottom = y3;
    if (bottom < y4) bottom = y4;

    rectangle.setTo(left, top, right - left, bottom - top);

    return rectangle;
  }

  //-----------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    _calculateNewProjectionMatrix3D(_identityMatrix);

    num m00 = _newProjectionMatrix3D.m00;
    num m10 = _newProjectionMatrix3D.m10;
    num m30 = _newProjectionMatrix3D.m30;
    num m01 = _newProjectionMatrix3D.m01;
    num m11 = _newProjectionMatrix3D.m11;
    num m31 = _newProjectionMatrix3D.m31;
    num m03 = _newProjectionMatrix3D.m03;
    num m13 = _newProjectionMatrix3D.m13;
    num m33 = _newProjectionMatrix3D.m33;

    num px = localX.toDouble();
    num py = localY.toDouble();

    num d = px * (m01 * m13 - m03 * m11) + py * (m10 * m03 - m00 * m13) + m00 * m11 - m10 * m01;
    num x = px * (m11 * m33 - m13 * m31) + py * (m30 * m13 - m10 * m33) + m10 * m31 - m30 * m11;
    num y = px * (m03 * m31 - m01 * m33) + py * (m00 * m33 - m30 * m03) + m30 * m01 - m00 * m31;

    return super.hitTestInput(x / d, y / d);
  }

  //-----------------------------------------------------------------------------------------------

  Point<num> localToGlobal(Point<num> localPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    _calculateNewProjectionMatrix3D(_tmpMatrix);

    num m00 = _newProjectionMatrix3D.m00;
    num m10 = _newProjectionMatrix3D.m10;
    num m30 = _newProjectionMatrix3D.m30;
    num m01 = _newProjectionMatrix3D.m01;
    num m11 = _newProjectionMatrix3D.m11;
    num m31 = _newProjectionMatrix3D.m31;
    num m03 = _newProjectionMatrix3D.m03;
    num m13 = _newProjectionMatrix3D.m13;
    num m33 = _newProjectionMatrix3D.m33;

    num px = localPoint.x.toDouble();
    num py = localPoint.y.toDouble();

    num d = m03 * px + m13 * py + m33;
    num x = m00 * px + m10 * py + m30;
    num y = m01 * px + m11 * py + m31;

    return new Point<num>(x / d, y / d);
  }

  //-------------------------------------------------------------------------------------------------

  Point<num> globalToLocal(Point<num> globalPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    _calculateNewProjectionMatrix3D(_tmpMatrix);

    num m00 = _newProjectionMatrix3D.m00;
    num m10 = _newProjectionMatrix3D.m10;
    num m30 = _newProjectionMatrix3D.m30;
    num m01 = _newProjectionMatrix3D.m01;
    num m11 = _newProjectionMatrix3D.m11;
    num m31 = _newProjectionMatrix3D.m31;
    num m03 = _newProjectionMatrix3D.m03;
    num m13 = _newProjectionMatrix3D.m13;
    num m33 = _newProjectionMatrix3D.m33;

    num px = globalPoint.x.toDouble();
    num py = globalPoint.y.toDouble();

    num d = px * (m01 * m13 - m03 * m11) + py * (m10 * m03 - m00 * m13) + m00 * m11 - m10 * m01;
    num x = px * (m11 * m33 - m13 * m31) + py * (m30 * m13 - m10 * m33) + m10 * m31 - m30 * m11;
    num y = px * (m03 * m31 - m01 * m33) + py * (m00 * m33 - m30 * m03) + m30 * m01 - m00 * m31;

    return new Point<num>(x / d, y / d);
  }

  //-----------------------------------------------------------------------------------------------

  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else {
      _renderCanvas(renderState);
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  void _calculateNewProjectionMatrix3D(Matrix matrix) {

    Matrix3D perspectiveMatrix3D = this.perspectiveProjection.perspectiveMatrix3D;
    Matrix3D transformationMatrix3D = this.transformationMatrix3D;
    double pivotX = this.pivotX.toDouble();
    double pivotY = this.pivotY.toDouble();

    _newProjectionMatrix3D.copyFromMatrix2D(matrix);
    _newProjectionMatrix3D.prependTranslation(pivotX, pivotY, 0.0);
    _newProjectionMatrix3D.prepend(perspectiveMatrix3D);
    _newProjectionMatrix3D.prepend(transformationMatrix3D);
    _newProjectionMatrix3D.prependTranslation(-pivotX, -pivotY, 0.0);
  }

  //-----------------------------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    var renderContext = renderState.renderContext as RenderContextWebGL;
    var activeProjectionMatrix = renderContext.activeProjectionMatrix;
    var globalMatrix = renderState.globalMatrix;

    _calculateNewProjectionMatrix3D(globalMatrix);

    _tmpMatrix.copyFromAndInvert(globalMatrix);
    _newProjectionMatrix3D.concat(activeProjectionMatrix);
    _newProjectionMatrix3D.prepend2D(_tmpMatrix);
    _oldProjectionMatrix3D.copyFromMatrix3D(activeProjectionMatrix);

    renderContext.activateProjectionMatrix(_newProjectionMatrix3D);
    super.render(renderState);
    renderContext.activateProjectionMatrix(_oldProjectionMatrix3D);
  }

  //-----------------------------------------------------------------------------------------------

  void _renderCanvas(RenderState renderState) {

    // TODO: We could simulate the 3d-transformation with 2d scales
    // and 2d transformations - not perfect but better than nothing.

  }
}



