part of stagexl.drawing;

class CanvasPatternKey{
  RenderTextureQuad _renderTextureQuad;
  String _kind;
  CanvasPatternKey(this._renderTextureQuad,this._kind);

  @override
  int get hashCode {
    return JenkinsHash.hash2(_renderTextureQuad.hashCode,_kind.hashCode);
  }

  @override
  bool operator == (Object other){
    return (other is CanvasPatternKey) && (this._renderTextureQuad == other._renderTextureQuad) && (this._kind == other._kind);
  }
}

class GraphicsPattern {

  /// cached by the canvas2D renderer
  CanvasPattern _canvasPattern;
  static SharedCache<CanvasPatternKey,CanvasPattern>  _canvasPatternCache = new SharedCache<CanvasPatternKey,CanvasPattern>();

  /// cached by both the canvas2D and the webgl renderer
  RenderTexture _patternTexture;
  Matrix        _renderMatrix;
  static SharedCache<RenderTextureQuad,RenderTexture>  _patternTextureCache = new SharedCache<RenderTextureQuad,RenderTexture>()..onObjectReleasedListen(releaseTexture);


  RenderTextureQuad _renderTextureQuad;
  Matrix _matrix;
  String _kind;

  GraphicsPattern.repeat(this._renderTextureQuad, [this._matrix])
      : this._kind = "repeat";

  GraphicsPattern.repeatX(this._renderTextureQuad, [this._matrix])
      : this._kind = "repeat-x";

  GraphicsPattern.repeatY(this._renderTextureQuad, [this._matrix])
      : this._kind = "repeat-y";

  GraphicsPattern.noRepeat(this._renderTextureQuad, [this._matrix])
      : this._kind = "no-repeat";


  void set kind(String value) {
    if (value != "repeat" && value != "no-repeat" && value != "repeat-x" && value != "repeat-y") throw new ArgumentError("kind must be 'repeat', 'repeat-x', 'repeat-y', or 'no-repeat'");
    disposeCachedRenderObjects(false);
    _kind = value;
  }
  String get kind => _kind;

  void set matrix(Matrix value){
    _renderMatrix = null;
    _matrix = value;
  }
  Matrix get matrix {
    _renderMatrix = null;
    return _matrix;
  }

  void set renderTextureQuad(RenderTextureQuad texture){
    disposeCachedRenderObjects(true);
    _renderTextureQuad = texture;
  }
  RenderTextureQuad get renderTextureQuad {
    disposeCachedRenderObjects(true);
    return _renderTextureQuad;
  }

  void disposeCachedRenderObjects(bool patternTextureChanged) {
    _canvasPatternCache.releaseObject(new CanvasPatternKey(_renderTextureQuad,_kind));
    _canvasPattern = null;
    if ( patternTextureChanged && _patternTexture != null ) {
      if ( _patternTexture != _renderTextureQuad.renderTexture ) {
        _patternTextureCache.releaseObject(_renderTextureQuad);
      }
      _patternTexture = null;
    }
  }

  CanvasPattern  getCanvasPattern(CanvasRenderingContext2D context) {
    if ( _canvasPattern != null ) return _canvasPattern;

    CanvasPatternKey cacheKey = new CanvasPatternKey(_renderTextureQuad,_kind);
    _canvasPattern = _canvasPatternCache.getObject(cacheKey);

    if ( _canvasPattern == null ) {
      RenderTexture fillTexture = patternTexture;
      if ( fillTexture != null ){
        _canvasPattern = context.createPattern(fillTexture.source, _kind);
        _canvasPatternCache.addObject(cacheKey,_canvasPattern);
      }
    }
    return _canvasPattern;
  }

  RenderTexture  get patternTexture {
    if ( _patternTexture != null ) return _patternTexture;

    if ( _renderTextureQuad != null ) {
      _patternTexture = _patternTextureCache.getObject(_renderTextureQuad);

      if ( _patternTexture == null ) {
        if (_renderTextureQuad.isEquivalentToSource) {
          _patternTexture = _renderTextureQuad.renderTexture;
        } else {
          BitmapData bitmapData = new BitmapData.fromRenderTextureQuad(
              _renderTextureQuad);
          bitmapData = bitmapData.clone();
          _patternTexture = bitmapData.renderTextureQuad.renderTexture;
          _patternTextureCache.addObject(_renderTextureQuad,_patternTexture);
        }
      }
    }

    return _patternTexture;
  }

  Matrix  get _canvasRenderMatrix {
    return _matrix;
  }

  Matrix  get webGLRenderMatrix {
    if ( _renderMatrix != null ) return _renderMatrix;
    if ( _matrix != null ) _renderMatrix = _matrix.cloneInvert();
    return _renderMatrix;
  }

  static void releaseTexture(ObjectReleaseEvent event)
  {
    RenderTexture texture = event.object as RenderTexture;
    if ( texture != null ) {
      texture.dispose();
    }
  }

}
