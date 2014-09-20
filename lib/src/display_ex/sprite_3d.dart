part of stagexl.display_ex;

/// This class is experimental - use with caution.
/// The name of the class and the API may change!
///
/// Not implemented yet:
/// [Sprite3D.getBoundsTransformed] return empty region.
/// [Sprite3D.mask] is always applied relative to the parent.
///
class Sprite3D extends DisplayObjectContainer {

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

  // http://stackoverflow.com/questions/2465116/understanding-opengl-matrices/2465290#2465290
  // http://www.quickmath.com/webMathematica3/quickmath/equations/solve/advanced.jsp#c=solve_advancedsolveequations&v1=x2+%3D+(m00+*+x1+%2B+m10+*+y1+%2B+m30)+%2F+(m03+*+x1+%2B+m13+*+y1+%2B+m33)%0A%0Ay2+%3D+(m01+*+x1+%2B+m11+*+y1+%2B+m31)+%2F+(m03+*+x1+%2B+m13+*+y1+%2B+m33)%0A&v2=x1%0Ay1

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    // TODO: calculate real bounds in 3D space.

    if (returnRectangle != null) {
      returnRectangle.setTo(matrix.tx, matrix.ty, 0, 0);
    } else {
      returnRectangle = new Rectangle<num>(matrix.tx, matrix.ty, 0, 0);
    }

    return returnRectangle;
  }

  DisplayObject hitTestInput(num localX, num localY) {

    Matrix3D perspectiveMatrix3D = this.perspectiveProjection.perspectiveMatrix3D;
    Matrix3D transformationMatrix3D = this.transformationMatrix3D;
    Matrix3D matrix = _newProjectionMatrix3D;

    matrix.setIdentity();
    matrix.prependTranslation(pivotX, pivotY, 0.0);
    matrix.prepend(perspectiveMatrix3D);
    matrix.prepend(transformationMatrix3D);
    matrix.prependTranslation(-pivotX, -pivotY, 0.0);

    num m00 = matrix.m00;
    num m10 = matrix.m10;
    num m30 = matrix.m30;
    num m01 = matrix.m01;
    num m11 = matrix.m11;
    num m31 = matrix.m31;
    num m03 = matrix.m03;
    num m13 = matrix.m13;
    num m33 = matrix.m33;

    num d = localX * (m01 * m13 - m03 * m11) + localY * (m10 * m03 - m00 * m13) + (m00 * m11 - m10 * m01);
    num x = localX * (m11 * m33 - m13 * m31) + localY * (m30 * m13 - m10 * m33) + (m10 * m31 - m30 * m11);
    num y = localX * (m03 * m31 - m01 * m33) + localY * (m00 * m33 - m30 * m03) + (m30 * m01 - m00 * m31);

    return super.hitTestInput(x / d, y / d);
  }

  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else {
      _renderCanvas(renderState);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    var renderContext = renderState.renderContext as RenderContextWebGL;
    var globalMatrix = renderState.globalMatrix;
    var activeProjectionMatrix = renderContext.activeProjectionMatrix;
    var perspectiveMatrix3D = this.perspectiveProjection.perspectiveMatrix3D;
    var transformationMatrix3D = this.transformationMatrix3D;
    var pivotX = this.pivotX.toDouble();
    var pivotY = this.pivotY.toDouble();

    // TODO: avoid projection matrix changes for un-transformed objects.
    // TODO: avoid globalMatrix in the _newProjectionMatrix3D calculation.

    _oldProjectionMatrix3D.copyFromMatrix3D(activeProjectionMatrix);

    _newProjectionMatrix3D.copyFromMatrix2D(globalMatrix);
    _newProjectionMatrix3D.prependTranslation(pivotX, pivotY, 0.0);
    _newProjectionMatrix3D.prepend(perspectiveMatrix3D);
    _newProjectionMatrix3D.prepend(transformationMatrix3D);
    _newProjectionMatrix3D.prependTranslation(-pivotX, -pivotY, 0.0);
    _newProjectionMatrix3D.concat(activeProjectionMatrix);
    _newProjectionMatrix3D.prepend2D(globalMatrix.cloneInvert());

    renderContext.activateProjectionMatrix(_newProjectionMatrix3D);
    super.render(renderState);
    renderContext.activateProjectionMatrix(_oldProjectionMatrix3D);
  }

  void _renderCanvas(RenderState renderState) {

    // TODO: We could simulate the 3d-transformation with 2d scales
    // and 2d transformations - not perfect but better than nothing.

    super.render(renderState);
  }
}



