part of stagexl.drawing;

class GraphicsPatternKind {

  final String value;
  final RenderTextureWrapping wrappingX;
  final RenderTextureWrapping wrappingY;

  const GraphicsPatternKind(this.value, this.wrappingX, this.wrappingY);

  static const GraphicsPatternKind Repeat =
      const GraphicsPatternKind("repeat", RenderTextureWrapping.REPEAT, RenderTextureWrapping.REPEAT);

  static const GraphicsPatternKind RepeatX  =
      const GraphicsPatternKind("repeat-x", RenderTextureWrapping.REPEAT, RenderTextureWrapping.CLAMP);

  static const GraphicsPatternKind RepeatY =
      const GraphicsPatternKind("repeat-y", RenderTextureWrapping.CLAMP, RenderTextureWrapping.REPEAT);

  static const GraphicsPatternKind NoRepeat =
      const GraphicsPatternKind("no-repeat", RenderTextureWrapping.CLAMP, RenderTextureWrapping.CLAMP);
}

//------------------------------------------------------------------------------

class CanvasPatternKey {

  RenderTextureQuad _renderTextureQuad;
  GraphicsPatternKind _kind;
  CanvasPatternKey(this._renderTextureQuad, this._kind);

  @override
  int get hashCode {
    return JenkinsHash.hash2(_renderTextureQuad.hashCode, _kind.hashCode);
  }

  @override
  bool operator ==(Object other) {
    return (other is CanvasPatternKey) &&
        (this._renderTextureQuad == other._renderTextureQuad) &&
        (this._kind == other._kind);
  }
}

//------------------------------------------------------------------------------

class GraphicsPattern {

  /// cached by the canvas2D renderer
  CanvasPattern _canvasPattern;
  static SharedCache<CanvasPatternKey, CanvasPattern> _canvasPatternCache =
      new SharedCache<CanvasPatternKey, CanvasPattern>();

  /// cached by both the canvas2D and the webgl renderer
  RenderTexture _patternTexture;
  static SharedCache<RenderTextureQuad, RenderTexture> _patternTextureCache =
      new SharedCache<RenderTextureQuad, RenderTexture>()
        ..onObjectReleasedListen(releaseTexture);

  RenderTextureQuad _renderTextureQuad;
  GraphicsPatternKind _kind;
  Matrix _matrix;

  GraphicsPattern(
      RenderTextureQuad renderTextureQuad,
      GraphicsPatternKind kind, [Matrix matrix = null]) {

    _renderTextureQuad = renderTextureQuad;
    _matrix = matrix;
    _kind = kind;
  }

  GraphicsPattern.repeat(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternKind.Repeat, matrix);

  GraphicsPattern.repeatX(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternKind.RepeatX, matrix);

  GraphicsPattern.repeatY(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternKind.RepeatY, matrix);

  GraphicsPattern.noRepeat(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternKind.NoRepeat, matrix);

  //----------------------------------------------------------------------------

  GraphicsPatternKind get kind => _kind;

  set kind(GraphicsPatternKind value) {
    disposeCachedRenderObjects(false);
    _kind = value;
  }

  Matrix get matrix => _matrix;

  set matrix(Matrix value) {
    _matrix = value;
  }

  RenderTextureQuad get renderTextureQuad {
    disposeCachedRenderObjects(true);
    return _renderTextureQuad;
  }

  set renderTextureQuad(RenderTextureQuad texture) {
    disposeCachedRenderObjects(true);
    _renderTextureQuad = texture;
  }

  //----------------------------------------------------------------------------

  void disposeCachedRenderObjects(bool patternTextureChanged) {
    var cacheKey = new CanvasPatternKey(_renderTextureQuad, _kind);
    _canvasPatternCache.releaseObject(cacheKey);
    _canvasPattern = null;
    if (patternTextureChanged && _patternTexture != null) {
      if (_patternTexture != _renderTextureQuad.renderTexture) {
        _patternTextureCache.releaseObject(_renderTextureQuad);
      }
      _patternTexture = null;
    }
  }

  CanvasPattern getCanvasPattern(CanvasRenderingContext2D context) {

    // try to get the canvasPattern from the cache
    if (_canvasPattern == null) {
      var cacheKey = new CanvasPatternKey(_renderTextureQuad, _kind);
      _canvasPattern = _canvasPatternCache.getObject(cacheKey);
    }

    // create a new canvasPattern and add it to the cache
    if (_canvasPattern == null) {
      var cacheKey = new CanvasPatternKey(_renderTextureQuad, _kind);
      _canvasPattern = context.createPattern(patternTexture.source, _kind.value);
      _canvasPatternCache.addObject(cacheKey, _canvasPattern);
    }

    return _canvasPattern;
  }

  RenderTexture get patternTexture {

    // try to get the patternTexture from the texture cache
    if (_patternTexture == null && _renderTextureQuad != null) {
      _patternTexture = _patternTextureCache.getObject(_renderTextureQuad);
    }

    // try to use the original texture as patternTexture
    if (_patternTexture == null && _renderTextureQuad.isEquivalentToSource) {
      _patternTexture = _renderTextureQuad.renderTexture;
    }

    // clone the original texture to get the patternTexture
    if (_patternTexture == null) {
      var pixelRatio = _renderTextureQuad.pixelRatio;
      var textureWidth = _renderTextureQuad.offsetRectangle.width;
      var textureHeight = _renderTextureQuad.offsetRectangle.height;
      var renderTexture = new RenderTexture(textureWidth, textureHeight, 0);
      var renderTextureQuad = renderTexture.quad.withPixelRatio(pixelRatio);
      var renderContext = new RenderContextCanvas(renderTexture.canvas);
      var renderState = new RenderState(renderContext, renderTextureQuad.drawMatrix);
      renderState.renderTextureQuad(_renderTextureQuad);
      _patternTexture = renderTexture;
      _patternTextureCache.addObject(_renderTextureQuad, _patternTexture);
    }

    return _patternTexture;
  }

  static void releaseTexture(ObjectReleaseEvent event) {
    var renderTexture = event.object;
    if (renderTexture is RenderTexture) {
      renderTexture.dispose();
    }
  }
}
