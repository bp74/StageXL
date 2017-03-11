part of stagexl.engine;

class _ContextState {

  double alpha = 1.0;
  BlendMode blendMode = BlendMode.NORMAL;

  final Matrix matrix = new Matrix.fromIdentity();
  final Matrix3D matrix3D = new Matrix3D.fromIdentity();
  final _ContextState previousContextState;

  _ContextState(this.previousContextState);

  _ContextState _nextContextState;
  _ContextState get nextContextState {
    return _nextContextState ??= new _ContextState(this);
  }
}

/// The [RenderState] class is used to render objects to a give render surface
/// defined by the renderContext parameter.
///
/// Most users won't ever use this class directly because it's only used
/// internally to render the display list. However, more advanced users
/// may use it to create custom display objects.
///
/// The [renderObject] method keeps track of the state for hierarchical objects
/// from the display list and therefore can be called recursively.
/// The [renderQuad] method renders simple [RenderTextureQuad] objects. This is
/// also the method that is used by the display list to draw BitmapData objects.

class RenderState {

  num currentTime = 0.0;
  num deltaTime = 0.0;

  final RenderContext _renderContext;
  final _ContextState _firstContextState;

  _ContextState _currentContextState;

  RenderState(RenderContext renderContext, [Matrix matrix, num alpha, BlendMode blendMode]) :
    _renderContext = renderContext,
    _firstContextState = new _ContextState(null) {

    _currentContextState = _firstContextState;

    if (matrix is Matrix) _firstContextState.matrix.copyFrom(matrix);
    if (alpha is num) _firstContextState.alpha = alpha;
    if (blendMode is BlendMode) _firstContextState.blendMode = blendMode;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  RenderContext get renderContext => _renderContext;

  Matrix get globalMatrix => _currentContextState.matrix;
  double get globalAlpha => _currentContextState.alpha;
  BlendMode get globalBlendMode => _currentContextState.blendMode;

  //---------------------------------------------------------------------------

  void reset([Matrix matrix, num alpha, BlendMode blendMode]) {

    _currentContextState = _firstContextState;
    _currentContextState.matrix.identity();
    _currentContextState.alpha = 1.0;
    _currentContextState.blendMode = BlendMode.NORMAL;

    if (matrix is Matrix) _firstContextState.matrix.copyFrom(matrix);
    if (alpha is num) _firstContextState.alpha = alpha;
    if (blendMode is BlendMode) _firstContextState.blendMode = blendMode;
  }

  void copyFrom(RenderState renderState) {

    _currentContextState = _firstContextState;
    _currentContextState.matrix.copyFrom(renderState.globalMatrix);
    _currentContextState.alpha = renderState.globalAlpha;
    _currentContextState.blendMode = renderState.globalBlendMode;
  }

  //---------------------------------------------------------------------------

  void flush() {
    _renderContext.flush();
  }

  void renderTextureQuad(RenderTextureQuad renderTextureQuad) {
    _renderContext.renderTextureQuad(this, renderTextureQuad);
  }

  void renderTextureMapping(RenderTexture renderTexture, Matrix mappingMatrix, Int16List ixList, Float32List vxList) {
    _renderContext.renderTextureMapping(this, renderTexture, mappingMatrix, ixList, vxList);
  }

  void renderTextureMesh(RenderTexture renderTexture, Int16List ixList, Float32List vxList) {
    _renderContext.renderTextureMesh(this, renderTexture, ixList, vxList);
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, int color) {
    _renderContext.renderTriangle(this, x1, y1, x2, y2, x3, y3, color);
  }

  void renderTriangleMesh(Int16List ixList, Float32List vxList, int color) {
    _renderContext.renderTriangleMesh(this, ixList, vxList, color);
  }

  void renderTextureQuadFiltered(RenderTextureQuad renderTextureQuad, List<RenderFilter> renderFilters) {
    _renderContext.renderTextureQuadFiltered(this, renderTextureQuad, renderFilters);
  }

  void renderObjectFiltered(RenderObject renderObject) {
    _renderContext.renderObjectFiltered(this, renderObject);
  }

  //---------------------------------------------------------------------------

  void renderObject(RenderObject renderObject) {

    var matrix = renderObject.transformationMatrix;
    var blendMode = renderObject.blendMode;
    var alpha = renderObject.alpha;
    var filters = renderObject.filters;
    var cache = renderObject.cache;
    var mask = renderObject.mask;

    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;
    var maskBefore = mask != null && mask.relativeToParent == true;
    var maskAfter = mask != null && mask.relativeToParent == false;

    cs2.matrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.blendMode = (blendMode is BlendMode) ? blendMode : cs1.blendMode;
    cs2.alpha = alpha * cs1.alpha;

    //-----------

    if (maskBefore) renderContext.beginRenderMask(this, mask);

    if (renderObject is RenderObject3D && renderContext is RenderContextWebGL) {
      RenderObject3D renderObject3D = renderObject;
      var renderContextWebGL = renderContext as RenderContextWebGL;
      cs1.matrix3D.copyFrom(renderContextWebGL.activeProjectionMatrix);
      cs2.matrix3D.copyFrom2DAndConcat(cs2.matrix, cs1.matrix3D);
      cs2.matrix3D.prepend(renderObject3D.projectionMatrix3D);
      cs2.matrix3D.prependInverse2D(cs2.matrix);
      renderContextWebGL.activateProjectionMatrix(cs2.matrix3D);
    }

    _currentContextState = cs2;

    //-----------

    if (maskAfter) renderContext.beginRenderMask(this, mask);

    if (cache != null) {
      this.renderTextureQuad(cache);
    } else if (filters.length > 0) {
      renderObject.renderFiltered(this);
    } else {
      renderObject.render(this);
    }

    if (maskAfter) renderContext.endRenderMask(this, mask);

    //-----------

    _currentContextState = cs1;

    if (renderObject is RenderObject3D && renderContext is RenderContextWebGL) {
      var renderContextWebGL = renderContext as RenderContextWebGL;
      renderContextWebGL.activateProjectionMatrix(cs1.matrix3D);
    }

    if (maskBefore) renderContext.endRenderMask(this, mask);
  }

  //---------------------------------------------------------------------------

  void push(Matrix matrix, num alpha, BlendMode blendMode) {
    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;
    cs2.matrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.blendMode = (blendMode is BlendMode) ? blendMode : cs1.blendMode;
    cs2.alpha = alpha * cs1.alpha;
    _currentContextState = cs2;
  }

  void pop() {
    _currentContextState = _currentContextState.previousContextState;
  }

}




