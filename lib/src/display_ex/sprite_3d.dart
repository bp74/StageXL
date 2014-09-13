part of stagexl.display_ex;

/// This class is experimental - use with caution.
/// The name of the class and the API may change!
///
class Sprite3D extends DisplayObjectContainer {

  PerspectiveProjection perspectiveProjection = new PerspectiveProjection();

  num _z = 0.0;
  num _rotationX = 0.0;
  num _rotationY = 0.0;
  num _rotationZ = 0.0;

  final Matrix _identityMatrix = new Matrix.fromIdentity();
  final Matrix3D _transformationMatrix3D = new Matrix3D.fromIdentity();
  bool _transformationMatrix3DRefresh = true;

  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else {
      _renderCanvas(renderState);
    }
  }

  //-----------------------------------------------------------------------------------------------

  num get z => _z;
  num get rotationX => _rotationX;
  num get rotationY => _rotationY;
  num get rotationZ => _rotationZ;

  set z(num value) {
    if (value is num) _z = value;
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
      _transformationMatrix3D.setIdentity();
      _transformationMatrix3D.rotateX(0.0 - _rotationX);
      _transformationMatrix3D.rotateY(_rotationY);
      _transformationMatrix3D.rotateZ(0.0 - _rotationZ);
      _transformationMatrix3D.translate(0.0, 0.0, _z);
    }

    return _transformationMatrix3D;
  }

  //-----------------------------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    // TODO: optimize memory allocations!
    // TODO: think about how we can maintain draw call batching!
    // TODO: maybe we sould add worldX, worldY, worldZ properties to move
    // the sprite relative to the pivot point in 3d space.

    var renderContext = renderState.renderContext as RenderContextWebGL;
    var globalMatrix = renderState.globalMatrix;
    var globalAlpha = renderState.globalAlpha;
    var globalBlendMode = renderState.globalBlendMode;
    var activeProjectionMatrix = renderContext.activeProjectionMatrix;

    var identityMatrix = new Matrix.fromIdentity();
    var tmpRenderState = new RenderState(renderContext, identityMatrix, globalAlpha, globalBlendMode);
    var perspectiveMatrix = perspectiveProjection.perspectiveMatrix3D;
    var transformationMatrix2D = new Matrix3D.fromMatrix2D(globalMatrix);

    var projectionMatrix = new Matrix3D.fromMatrix3D(transformationMatrix3D);
    projectionMatrix.concat(perspectiveMatrix);
    projectionMatrix.concat(transformationMatrix2D);
    projectionMatrix.concat(activeProjectionMatrix);

    renderContext.activateProjectionMatrix(projectionMatrix);
    super.render(tmpRenderState);
    renderContext.activateProjectionMatrix(activeProjectionMatrix);
  }

  void _renderCanvas(RenderState renderState) {

    // TODO: We could simulate the 3d-transformation with 2d scales
    // and 2d transformations - not perfect but better than nothing.

    super.render(renderState);
  }
}



