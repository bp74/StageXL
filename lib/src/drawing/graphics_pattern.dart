part of stagexl.drawing;

class GraphicsPatternType {

  final String value;
  final RenderTextureWrapping wrappingX;
  final RenderTextureWrapping wrappingY;

  const GraphicsPatternType(this.value, this.wrappingX, this.wrappingY);

  static const GraphicsPatternType Repeat =
      const GraphicsPatternType("repeat", RenderTextureWrapping.REPEAT, RenderTextureWrapping.REPEAT);

  static const GraphicsPatternType RepeatX  =
      const GraphicsPatternType("repeat-x", RenderTextureWrapping.REPEAT, RenderTextureWrapping.CLAMP);

  static const GraphicsPatternType RepeatY =
      const GraphicsPatternType("repeat-y", RenderTextureWrapping.CLAMP, RenderTextureWrapping.REPEAT);

  static const GraphicsPatternType NoRepeat =
      const GraphicsPatternType("no-repeat", RenderTextureWrapping.CLAMP, RenderTextureWrapping.CLAMP);
}

//------------------------------------------------------------------------------

class _CanvasPatternKey {

  final RenderTextureQuad renderTextureQuad;
  final GraphicsPatternType type;

  _CanvasPatternKey(this.renderTextureQuad, this.type);

  @override
  int get hashCode {
    return JenkinsHash.hash2(renderTextureQuad.hashCode, type.hashCode);
  }

  @override
  bool operator ==(Object other) {
    return other is _CanvasPatternKey &&
        renderTextureQuad == other.renderTextureQuad && type == other.type;
  }
}

//------------------------------------------------------------------------------

class GraphicsPattern {

  static SharedCache<_CanvasPatternKey, CanvasPattern> _canvasPatternCache =
      new SharedCache<_CanvasPatternKey, CanvasPattern>();

  static SharedCache<RenderTextureQuad, RenderTexture> _patternTextureCache =
      new SharedCache<RenderTextureQuad, RenderTexture>()
        ..onObjectReleased.listen((e) => e.object.dispose());

  /// cached by the canvas2D renderer
  CanvasPattern _canvasPattern;

  /// cached by both the canvas2D and the webgl renderer
  RenderTexture _patternTexture;

  RenderTextureQuad _renderTextureQuad;
  GraphicsPatternType _type;
  Matrix _matrix;

  GraphicsPattern(
      RenderTextureQuad renderTextureQuad,
      GraphicsPatternType type, [Matrix matrix = null]) {

    _renderTextureQuad = renderTextureQuad;
    _matrix = matrix;
    _type = type;
  }

  GraphicsPattern.repeat(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternType.Repeat, matrix);

  GraphicsPattern.repeatX(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternType.RepeatX, matrix);

  GraphicsPattern.repeatY(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternType.RepeatY, matrix);

  GraphicsPattern.noRepeat(RenderTextureQuad renderTextureQuad, [Matrix matrix])
      : this(renderTextureQuad, GraphicsPatternType.NoRepeat, matrix);

  //----------------------------------------------------------------------------

  GraphicsPatternType get type => _type;

  set type(GraphicsPatternType value) {
    disposeCachedRenderObjects(false);
    _type = value;
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
    var cacheKey = new _CanvasPatternKey(_renderTextureQuad, _type);
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
      var cacheKey = new _CanvasPatternKey(_renderTextureQuad, _type);
      _canvasPattern = _canvasPatternCache.getObject(cacheKey);
    }

    // create a new canvasPattern and add it to the cache
    if (_canvasPattern == null) {
      var cacheKey = new _CanvasPatternKey(_renderTextureQuad, _type);
      _canvasPattern = context.createPattern(patternTexture.source, _type.value);
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

}
