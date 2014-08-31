part of stagexl.engine;

class _ContextState {

  final Matrix matrix = new Matrix.fromIdentity();
  num alpha = 1.0;
  BlendMode blendMode = BlendMode.NORMAL;

  _ContextState _nextContextState;

  _ContextState get nextContextState {
    if (_nextContextState == null) _nextContextState = new _ContextState();
    return _nextContextState;
  }
}

/// The [RenderState] class is used to render objects to a give render surface
/// defined by the renderContext parameter. Most users won't ever use this
/// class directly because it's only used internaly to render the display list.
/// However, more advanced users may use it to create custom display objects.
///
/// The [renderObject] method keeps track of the state for hierarchical objects
/// from the display list and therefore can be called recursively.
/// The [renderQuad] method renders simple [RenderTextureQuad] objects. This is
/// also the method that is used by the display list to draw BitmapData objects.
///
class RenderState {

  num currentTime = 0.0;
  num deltaTime = 0.0;

  final RenderContext _renderContext;
  final _ContextState _firstContextState;

  _ContextState _currentContextState;

  RenderState(RenderContext renderContext, [Matrix matrix, num alpha, BlendMode blendMode]) :
    _renderContext = renderContext,
    _firstContextState = new _ContextState() {

    _currentContextState = _firstContextState;

    if (matrix is Matrix) _firstContextState.matrix.copyFrom(matrix);
    if (alpha is num) _firstContextState.alpha = alpha;
    if (blendMode is BlendMode) _firstContextState.blendMode = blendMode;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  RenderContext get renderContext => _renderContext;

  Matrix get globalMatrix => _currentContextState.matrix;
  double get globalAlpha => _currentContextState.alpha;
  BlendMode get globalBlendMode => _currentContextState.blendMode;

  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------

  void renderQuad(RenderTextureQuad renderTextureQuad) {
    _renderContext.renderQuad(this, renderTextureQuad);
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, int color) {
    _renderContext.renderTriangle(this, x1, y1, x2, y2, x3, y3, color);
  }

  void flush() {
    _renderContext.flush();
  }

  void renderObject(RenderObject renderObject) {

    var matrix = renderObject.transformationMatrix;
    var blendMode = renderObject.blendMode;
    var alpha = renderObject.alpha;
    var filters = renderObject.filters;
    var cache = renderObject.cache;
    var mask = renderObject.mask;

    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;

    cs2.matrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.blendMode = (blendMode is BlendMode) ? blendMode : cs1.blendMode;
    cs2.alpha = alpha * cs1.alpha;

    if (mask != null) {
      _currentContextState = mask.relativeToParent ? cs1 : cs2;
      renderContext.beginRenderMask(this, mask);
    }

    _currentContextState = cs2;

    if (cache != null) {
      renderQuad(cache);
    } else if (filters.length > 0) {
      _renderFiltered(renderObject);
    } else {
      renderObject.render(this);
    }

    if (mask != null) {
      _currentContextState = mask.relativeToParent ? cs1 : cs2;
      renderContext.endRenderMask(this, mask);
    }

    _currentContextState = cs1;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _renderFiltered(RenderObject renderObject) {

    if (renderContext is RenderContextWebGL) {

      var bounds = renderObject.bounds;
      var filters = renderObject.filters;
      var context = renderContext as RenderContextWebGL;

      var boundsLeft = bounds.left.floor();
      var boundsTop = bounds.top.floor();
      var boundsRight = bounds.right.ceil();
      var boundsBottom = bounds.bottom.ceil();

      for (int i = 0; i < filters.length; i++) {
        var overlap = filters[i].overlap;
        boundsLeft += overlap.left;
        boundsTop += overlap.top;
        boundsRight += overlap.right;
        boundsBottom += overlap.bottom;
      }

      var boundsWidth = boundsRight - boundsLeft;
      var boundsHeight = boundsBottom - boundsTop;

      var initialRenderFrameBuffer = context.activeRenderFrameBuffer;
      var initialProjectionMatrix = context.activeProjectionMatrix.clone();

      var flattenRenderFrameBuffer = context.requestRenderFrameBuffer(boundsWidth, boundsHeight);
      var flattenRenderTexture = flattenRenderFrameBuffer.renderTexture;
      var flattenRenderTextureQuad = new RenderTextureQuad(
          flattenRenderTexture, 0, boundsLeft, boundsTop, 0, 0, boundsWidth, boundsHeight);
      var flattenRenderState = new RenderState(context, flattenRenderTextureQuad.bufferMatrix);
      var flattenProjectionMatrix = new Matrix3D.fromIdentity();

      // TODO: We should remove the flattenRenderTextureQuad and use the flattenProjectionMatrix
      // for the transformation. This is also useful for the filterRenderState resets later in
      // the code. Less code and less memore allocations. But this also affects filters like
      // AlphaMaskFilter or DisplacementFilter.

      context.activateRenderFrameBuffer(flattenRenderFrameBuffer);
      context.activateProjectionMatrix(flattenProjectionMatrix);
      context.clear(0);
      renderObject.render(flattenRenderState);

      //----------------------------------------------

      var renderFrameBufferMap = new Map<int, RenderFrameBuffer>();
      renderFrameBufferMap[0] = flattenRenderFrameBuffer;

      RenderTextureQuad sourceRenderTextureQuad = null;
      RenderFrameBuffer sourceRenderFrameBuffer = null;
      RenderFrameBuffer targetRenderFrameBuffer = null;
      RenderState filterRenderState = flattenRenderState;

      for (int i = 0; i < filters.length; i++) {

        RenderFilter filter = filters[i];
        List<int> renderPassSources = filter.renderPassSources;
        List<int> renderPassTargets = filter.renderPassTargets;

        for (int pass = 0; pass < renderPassSources.length; pass++) {

          int renderPassSource = renderPassSources[pass];
          int renderPassTarget = renderPassTargets[pass];

          // get sourceRenderTextureQuad

          if (renderFrameBufferMap.containsKey(renderPassSource)) {
            sourceRenderFrameBuffer = renderFrameBufferMap[renderPassSource];
            sourceRenderTextureQuad = new RenderTextureQuad(
                sourceRenderFrameBuffer.renderTexture, 0,
                boundsLeft, boundsTop, 0, 0, boundsWidth, boundsHeight);
          } else {
            throw new StateError("Invalid renderPassSource!");
          }

          // get targetRenderFrameBuffer

          if (i == filters.length - 1 && renderPassTarget == renderPassTargets.last) {
            targetRenderFrameBuffer = initialRenderFrameBuffer;
            filterRenderState.copyFrom(this);
            context.activateRenderFrameBuffer(targetRenderFrameBuffer);
            context.activateBlendMode(filterRenderState.globalBlendMode);
            context.activateProjectionMatrix(initialProjectionMatrix);
          } else if (renderFrameBufferMap.containsKey(renderPassTarget)) {
            targetRenderFrameBuffer = renderFrameBufferMap[renderPassTarget];
            filterRenderState.reset(targetRenderFrameBuffer.renderTexture.quad.bufferMatrix);
            filterRenderState.globalMatrix.prependTranslation(-boundsLeft, -boundsTop);
            context.activateRenderFrameBuffer(targetRenderFrameBuffer);
            context.activateBlendMode(BlendMode.NORMAL);
          } else {
            targetRenderFrameBuffer = context.requestRenderFrameBuffer(boundsWidth, boundsHeight);
            filterRenderState.reset(targetRenderFrameBuffer.renderTexture.quad.bufferMatrix);
            filterRenderState.globalMatrix.prependTranslation(-boundsLeft, -boundsTop);
            renderFrameBufferMap[renderPassTarget] = targetRenderFrameBuffer;
            context.activateRenderFrameBuffer(targetRenderFrameBuffer);
            context.activateBlendMode(BlendMode.NORMAL);
            context.clear(0);
          }

          // render filter

          filter.renderFilter(filterRenderState, sourceRenderTextureQuad, pass);

          // release obsolete source RenderFrameBuffer

          if (renderPassSources.skip(pass + 1).every((rps) => rps != renderPassSource)) {
            renderFrameBufferMap.remove(renderPassSource);
            context.releaseRenderFrameBuffer(sourceRenderFrameBuffer);
          }
        }

        renderFrameBufferMap.clear();
        renderFrameBufferMap[0] = targetRenderFrameBuffer;
      }

    } else {

      renderObject.render(this);

    }
  }


}




