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

  RenderState(RenderContext renderContext, [Matrix matrix]) : _renderContext = renderContext {

    _firstContextState = new _ContextState();
    _currentContextState = _firstContextState;

    var viewPortMatrix = _renderContext.viewPortMatrix;

    if (matrix is Matrix) {
      _firstContextState.matrix.copyFromAndConcat(matrix, viewPortMatrix);
    } else {
      _firstContextState.matrix.copyFrom(viewPortMatrix);
    }
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

    _renderContext.clear();

    var viewPortMatrix = _renderContext.viewPortMatrix;

    if (matrix is Matrix) {
      _firstContextState.matrix.copyFromAndConcat(matrix, viewPortMatrix);
    } else {
      _firstContextState.matrix.copyFrom(viewPortMatrix);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject) {

    var matrix = displayObject.transformationMatrix;
    var alpha = displayObject.alpha;
    var mask = displayObject.mask;
    var shadow = displayObject.shadow;
    var composite = displayObject.compositeOperation;

    var cs1 = _currentContextState;
    var cs2 = _currentContextState.nextContextState;

    _currentContextState = cs2;

    var nextMatrix = cs2.matrix;
    var nextAlpha = cs1.alpha.toDouble() * alpha;
    var nextCompositeOperation = (composite is String) ? composite : cs1.compositeOperation;

    nextMatrix.copyFromAndConcat(matrix, cs1.matrix);
    cs2.alpha = nextAlpha;
    cs2.compositeOperation = nextCompositeOperation;

    // apply mask

    if (mask != null) {
      if (mask.targetSpace == null) {
        matrix = cs2.matrix;
      } else if (identical(mask.targetSpace, displayObject)) {
        matrix = cs2.matrix;
      } else if (identical(mask.targetSpace, displayObject.parent)) {
        matrix = cs1.matrix;
      } else {
        matrix = mask.targetSpace.transformationMatrixTo(displayObject);
        if (matrix == null) matrix = _identityMatrix; else matrix.concat(cs2.matrix);
      }
      _renderContext.beginRenderMask(this, mask, matrix);
    }

    // apply shadow

    if (shadow != null) {
      if (shadow.targetSpace == null) {
        matrix = cs2.matrix;
      } else if (identical(shadow.targetSpace, displayObject)) {
        matrix = cs2.matrix;
      } else if (identical(shadow.targetSpace, displayObject.parent)) {
        matrix = cs1.matrix;
      } else {
        matrix = shadow.targetSpace.transformationMatrixTo(displayObject);
        if (matrix == null) matrix = _identityMatrix; else matrix.concat(cs2.matrix);
      }
      _renderContext.beginRenderShadow(this, shadow, matrix);
    }

    // render DisplayObject

    _renderContext.globalAlpha = nextAlpha;
    _renderContext.globalCompositeOperation = nextCompositeOperation;

    if (displayObject.cached) {
      displayObject._renderCache(this);
    } else {
      displayObject.render(this);
    }

    // restore shadow

    if (shadow != null) {
      _renderContext.endRenderShadow(shadow);
    }

    // restore mask

    if (mask != null) {
      _renderContext.endRenderMask(mask);
    }

    _currentContextState = cs1;
  }

  //-------------------------------------------------------------------------------------------------

  void renderQuad(RenderTextureQuad renderTextureQuad) {
    var matrix = _currentContextState.matrix;
    _renderContext.renderQuad(renderTextureQuad, matrix);
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, int color) {
    var matrix = _currentContextState.matrix;
    var alpha = _currentContextState.alpha;
    var colorAlpha = (color & 0x00FFFFFF) + ((alpha * 255).round() << 24);
    _renderContext.renderTriangle(x1, y1, x2, y2, x3, y3, matrix, colorAlpha);
  }

  void flush() {
    _renderContext.flush();
  }
}




