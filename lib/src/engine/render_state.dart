part of stagexl;

class _ContextState {
  final Matrix matrix = new Matrix.fromIdentity();
  double alpha = 1.0;
  String compositeOperation = CompositeOperation.SOURCE_OVER;

  _ContextState _nextContextState;

  _ContextState get nextContextState {
    if (_nextContextState == null) _nextContextState = new _ContextState();
    return _nextContextState;
  }
}

class RenderState {

  final RenderContext _renderContext;

  num _currentTime = 0.0;
  num _deltaTime = 0.0;
  _ContextState _firstContextState;
  _ContextState _currentContextState;

  RenderState(RenderContext renderContext, [Matrix matrix, num alpha, String compositeOperation]) :
    _renderContext = renderContext {

    _firstContextState = new _ContextState();
    _currentContextState = _firstContextState;

    if (matrix is Matrix) _firstContextState.matrix.copyFrom(matrix);
    if (alpha is num) _firstContextState.alpha = alpha;
    if (compositeOperation is String) _firstContextState.compositeOperation = compositeOperation;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  RenderContext get renderContext => _renderContext;
  num get currentTime => _currentTime;
  num get deltaTime => _deltaTime;

  Matrix get globalMatrix => _currentContextState.matrix;
  double get globalAlpha => _currentContextState.alpha;
  String get globalCompositeOperation => _currentContextState.compositeOperation;

  //-------------------------------------------------------------------------------------------------

  void reset([Matrix matrix, num currentTime, num deltaTime]) {

    _currentTime = (currentTime is num) ? currentTime : 0.0;
    _deltaTime = (deltaTime is num) ? deltaTime : 0.0;
    _currentContextState = _firstContextState;

    if (matrix is Matrix) {
      _firstContextState.matrix.copyFrom(matrix);
    } else {
      _firstContextState.matrix.identity();
    }
  }

  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject) {

    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;
    var maskRenderState = null;
    var shadowRenderState = null;

    var matrix = displayObject.transformationMatrix;
    var composite = displayObject.compositeOperation;
    var alpha = displayObject.alpha;
    var mask = displayObject.mask;
    var shadow = displayObject.shadow;
    var cached = displayObject.cached;
    var filters = displayObject._filters;

    cs2.matrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.compositeOperation = (composite is String) ? composite : cs1.compositeOperation;
    cs2.alpha = alpha * cs1.alpha.toDouble();

    _currentContextState = cs2;

    // apply mask

    if (mask != null) {
      if (mask.targetSpace == null) {
        maskRenderState = new RenderState(_renderContext, cs2.matrix);
      } else if (identical(mask.targetSpace, displayObject)) {
        maskRenderState = new RenderState(_renderContext, cs2.matrix);
      } else if (identical(mask.targetSpace, displayObject.parent)) {
        maskRenderState = new RenderState(_renderContext, cs1.matrix);
      } else {
        matrix = mask.targetSpace.transformationMatrixTo(displayObject);
        maskRenderState = new RenderState(_renderContext, matrix);
        maskRenderState.globalMatrix.concat(cs2.matrix);
      }
      _renderContext.beginRenderMask(maskRenderState, mask);
    }

    // apply shadow

    if (shadow != null) {
      if (shadow.targetSpace == null) {
        shadowRenderState = new RenderState(_renderContext, cs2.matrix);
      } else if (identical(shadow.targetSpace, displayObject)) {
        shadowRenderState = new RenderState(_renderContext, cs2.matrix);
      } else if (identical(shadow.targetSpace, displayObject.parent)) {
        shadowRenderState = new RenderState(_renderContext, cs1.matrix);
      } else {
        matrix = shadow.targetSpace.transformationMatrixTo(displayObject);
        shadowRenderState = new RenderState(_renderContext, matrix);
        shadowRenderState.globalMatrix.concat(cs2.matrix);
      }
      _renderContext.beginRenderShadow(shadowRenderState, shadow);
    }

    // render DisplayObject (cached / filtered / standard)

    if (cached) {

      var cacheTexture = displayObject._cacheTexture;
      var cacheRectangle = displayObject._cacheRectangle;
      _currentContextState.matrix.prependTranslation(cacheRectangle.x, cacheRectangle.y);
      _renderContext.renderQuad(this, cacheTexture.quad);

    } else if (filters != null && filters.length > 0 && _renderContext is RenderContextWebGL) {

      RenderContextWebGL renderContext = _renderContext;

      var filterOverlap = new Rectangle.zero();
      for(var filter in filters) {
        filterOverlap = filterOverlap.union(filter.overlap);
      }

      var bounds = displayObject.getBoundsTransformed(_identityMatrix).align();
      var renderFrameBuffer = new RenderFrameBuffer(renderContext, bounds.width, bounds.height);
      var renderState = new RenderState(renderContext);

      renderState.globalMatrix.translate(-bounds.x, -bounds.y);
      renderState.globalMatrix.scale(2.0 / bounds.width, 2.0 / bounds.height);
      renderState.globalMatrix.translate(-1, -1);

      renderContext.flush();
      renderContext.pushFrameBuffer(renderFrameBuffer);
      renderContext.clear(Color.Transparent);
      displayObject.render(renderState);
      renderContext.flush();
      renderContext.popFrameBuffer();

      var renderTextureQuad = renderFrameBuffer.renderTexture.quad;
      renderTextureQuad._offsetX = bounds.x;
      renderTextureQuad._offsetY = bounds.y;

      for(var filter in filters) {
        filter.renderFilter(this, renderFrameBuffer.renderTexture.quad);
      }

      renderFrameBuffer.dispose();

    } else {

      displayObject.render(this);

    }

    // restore shadow

    if (shadow != null) {
      _renderContext.endRenderShadow(shadowRenderState, shadow);
    }

    // restore mask

    if (mask != null) {
      _renderContext.endRenderMask(maskRenderState, mask);
    }

    _currentContextState = cs1;
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
}




