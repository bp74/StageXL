part of stagexl.display_ex;

/// This class is experimental - use with caution.
/// The name of the class and the API may change!
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

  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else {
      _renderCanvas(renderState);
    }
  }

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
      _transformationMatrix3D.translate(offsetX, offsetY, offsetZ);
      _transformationMatrix3D.rotateX(0.0 - rotationX);
      _transformationMatrix3D.rotateY(0.0 + rotationY);
      _transformationMatrix3D.rotateZ(0.0 - rotationZ);
    }

    return _transformationMatrix3D;
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



