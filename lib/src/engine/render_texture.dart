part of stagexl;

class RenderTexture {

  int _width = 0;
  int _height = 0;
  bool _transparent = true;

  num _storePixelRatio = 1.0;
  int _storeWidth = 0;
  int _storeHeight = 0;

  CanvasElement _canvas;
  RenderTextureQuad _quad;

  gl.Texture _texture;
  gl.RenderingContext _renderingContext;

  //-----------------------------------------------------------------------------------------------

  RenderTexture(int width, int height, bool transparent, int fillColor, num storePixelRatio) {

    if (width == 0 && height == 0) throw new ArgumentError();

    _width = _ensureInt(width);
    _height = _ensureInt(height);
    _transparent = _ensureBool(transparent);

    _storePixelRatio = _ensureNum(storePixelRatio);
    _storeWidth = (_width * _storePixelRatio).round();
    _storeHeight = (_height * _storePixelRatio).round();

    var backingStoreWidth = (_storeWidth / _backingStorePixelRatio).round();
    var backingStoreHeight = (_storeHeight / _backingStorePixelRatio).round();
    _canvas = new CanvasElement(width: backingStoreWidth, height: backingStoreHeight);
    _quad = new RenderTextureQuad(this, 0, 0, _width, _height, 0, 0);
    _texture = null;

    if (fillColor != 0) {
      var context = _canvas.context2D;
      context.fillStyle = _transparent ? _color2rgba(fillColor) : _color2rgb(fillColor);
      context.fillRect(0, 0, backingStoreWidth, backingStoreHeight);
    }
  }

  RenderTexture.fromImage(ImageElement imageElement, num imagePixelRatio) {

    _storePixelRatio = _ensureNum(imagePixelRatio);
    _storeWidth = _ensureInt(imageElement.width);
    _storeHeight = _ensureInt(imageElement.height);

    _width = (_storeWidth / _storePixelRatio).round();
    _height = (_storeHeight / _storePixelRatio).round();
    _transparent = true;

    var backingStoreWidth = (_storeWidth / _backingStorePixelRatio).round();
    var backingStoreHeight = (_storeWidth / _backingStorePixelRatio).round();
    _canvas = new CanvasElement(width: backingStoreWidth, height: backingStoreHeight);
    _quad = new RenderTextureQuad(this, 0, 0, _width, _height, 0, 0);
    _texture = null;

    _canvas.context2D.drawImageScaledFromSource(imageElement,
        0, 0, imageElement.width, imageElement.height,
        0, 0, backingStoreWidth, backingStoreHeight);
  }

  //-----------------------------------------------------------------------------------------------

  static Future<RenderTexture> load(String url, bool autoHiDpi, bool webpAvailable) {

    var hiDpi = Stage.autoHiDpi && autoHiDpi && url.contains("@1x.");
    var loader = _loadImageElement(hiDpi ? url.replaceAll("@1x.", "@2x.") : url, webpAvailable);

    return loader.then((image) => new RenderTexture.fromImage(image, hiDpi ? 2.0 : 1.0));
  }

  //-----------------------------------------------------------------------------------------------

  CanvasElement get canvas => _canvas;
  RenderTextureQuad get quad => _quad;
  gl.Texture get texture => _texture;

  int get width => _width;
  int get height => _height;

  int get storeWidth => _storeWidth;
  int get storeHeight => _storeHeight;
  num get storePixelRatio => _storePixelRatio;

  //-----------------------------------------------------------------------------------------------

  /*
   * Disposes the texture memory allocated by WebGL.
   */
  void dispose() {
    if (_texture != null) {
      _renderingContext.deleteTexture(_texture);
      _texture = null;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {
    if (width != _width || height != _height) {
      _width = _ensureInt(width);
      _height = _ensureInt(height);
      _storeWidth = (_width * _storePixelRatio).round();
      _storeHeight = (_height * _storePixelRatio).round();
      _canvas.width = (_storeWidth / _backingStorePixelRatio).round();
      _canvas.height = (_storeHeight / _backingStorePixelRatio).round();
      _quad = new RenderTextureQuad(this, 0, 0, _width, _height, 0, 0);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void update() {
    if (_texture != null) {
      _renderingContext.activeTexture(gl.TEXTURE10);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
      _renderingContext.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _canvas);
      _renderingContext.bindTexture(gl.TEXTURE_2D, null);
    }
  }

  //-----------------------------------------------------------------------------------------------

  gl.Texture getTexture(RenderContextWebGL renderContext) {

    if (_texture == null) {
      _renderingContext = renderContext.rawContext;
      _texture = _renderingContext.createTexture();
      _renderingContext.activeTexture(gl.TEXTURE10);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
      _renderingContext.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _canvas);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      _renderingContext.bindTexture(gl.TEXTURE_2D, null);
    }

    return _texture;
  }
}