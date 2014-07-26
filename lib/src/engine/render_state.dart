part of stagexl;

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

class RenderState {

  final RenderContext _renderContext;

  num _currentTime = 0.0;
  num _deltaTime = 0.0;
  _ContextState _firstContextState;
  _ContextState _currentContextState;

  RenderState(RenderContext renderContext, [Matrix matrix, num alpha, BlendMode blendMode]) :
    _renderContext = renderContext {

    _firstContextState = new _ContextState();
    _currentContextState = _firstContextState;

    if (matrix is Matrix) _firstContextState.matrix.copyFrom(matrix);
    if (alpha is num) _firstContextState.alpha = alpha;
    if (blendMode is BlendMode) _firstContextState.blendMode = blendMode;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  RenderContext get renderContext => _renderContext;
  num get currentTime => _currentTime;
  num get deltaTime => _deltaTime;

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

  void renderDisplayObject(DisplayObject displayObject) {

    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;
    var matrix = displayObject.transformationMatrix;
    var blendMode = displayObject.blendMode;
    var alpha = displayObject.alpha;

    cs2.matrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.blendMode = (blendMode is BlendMode) ? blendMode : cs1.blendMode;
    cs2.alpha = alpha * cs1.alpha;

    _currentContextState = cs2;
    displayObject._renderInternal(this);
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




