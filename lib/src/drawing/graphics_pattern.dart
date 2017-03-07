part of stagexl.drawing;

class GraphicsPattern {

  /// cached by the canvas2D renderer
  CanvasPattern _canvasPattern;

  /// cached by both the canvas2D and the webgl renderer
  RenderTexture _patternTexture;
  Matrix        _renderMatrix;


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
    _canvasPattern = null;
    if ( patternTextureChanged && _patternTexture != null ) {
      if ( _patternTexture != _renderTextureQuad.renderTexture ) {
        _patternTexture.dispose();
      }
      _patternTexture = null;
    }
  }

  CanvasPattern  getCanvasPattern(CanvasRenderingContext2D context) {
    if ( _canvasPattern != null ) return _canvasPattern;

    RenderTexture fillTexture = patternTexture;
    if ( fillTexture != null ){
      _canvasPattern = context.createPattern(fillTexture.source, _kind);
    }
    return _canvasPattern;
  }

  RenderTexture  get patternTexture {
    if ( _patternTexture != null ) return _patternTexture;

    if ( _renderTextureQuad != null ) {
      if (_renderTextureQuad.isEquivalentToSource) {
        _patternTexture = _renderTextureQuad.renderTexture;
      } else {
        BitmapData bitmapData = new BitmapData.fromRenderTextureQuad(_renderTextureQuad);
        bitmapData = bitmapData.clone();
        _patternTexture = bitmapData.renderTextureQuad.renderTexture;
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

}
