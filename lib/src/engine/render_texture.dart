part of stagexl.engine;

class RenderTexture {

  int _width = 0;
  int _height = 0;
  bool _transparent = true;

  num _storePixelRatio = 1.0;
  int _storeWidth = 0;
  int _storeHeight = 0;

  CanvasImageSource _source;
  CanvasElement _canvas;
  VideoElement _video;
  RenderTextureQuad _quad;
  RenderTextureFiltering _filtering = RenderTextureFiltering.LINEAR;

  int _contextIdentifier = -1;
  bool _textureSourceWorkaround = false;
  gl.RenderingContext _renderingContext = null;
  gl.Texture _texture = null;

  //-----------------------------------------------------------------------------------------------

  RenderTexture(int width, int height, bool transparent, int fillColor, num storePixelRatio) {

    if (width == 0 && height == 0) throw new ArgumentError();

    _width = ensureInt(width);
    _height = ensureInt(height);
    _transparent = ensureBool(transparent);
    _storePixelRatio = ensureNum(storePixelRatio);
    _storeWidth = (_width * _storePixelRatio).round();
    _storeHeight = (_height * _storePixelRatio).round();

    _canvas = _source = new CanvasElement(width: _storeWidth, height: _storeHeight);
    _quad = new RenderTextureQuad(this, 0, 0, 0, 0, 0, _width, _height);

    if (fillColor != 0 || transparent == false) {
      var context = _canvas.context2D;
      context.fillStyle = transparent ? color2rgba(fillColor) : color2rgb(fillColor);
      context.fillRect(0, 0, _storeWidth, _storeHeight);
    }
  }

  RenderTexture.fromImage(ImageElement imageElement, num imagePixelRatio) {

    _storePixelRatio = ensureNum(imagePixelRatio);
    _width = (ensureNum(imageElement.width) / _storePixelRatio).floor();
    _height = (ensureNum(imageElement.height) / _storePixelRatio).floor();
    _storeWidth = (_width * _storePixelRatio).round();
    _storeHeight = (_height * _storePixelRatio).round();
    _transparent = true;

    _canvas = _source = new CanvasElement(width: _storeWidth, height: _storeHeight);
    _quad = new RenderTextureQuad(this, 0, 0, 0, 0, 0, _width, _height);
    _texture = null;

    _canvas.context2D.drawImageScaledFromSource(imageElement,
        0, 0, imageElement.width, imageElement.height,
        0, 0, _storeWidth, _storeHeight);
  }

  RenderTexture.fromVideoElement(VideoElement videoElement, num videoPixelRatio) {

    _storePixelRatio = ensureNum(videoPixelRatio);
    _width = (ensureNum(videoElement.videoWidth) / _storePixelRatio).floor();
    _height = (ensureNum(videoElement.videoHeight) / _storePixelRatio).floor();
    _storeWidth = (_width * _storePixelRatio).round();
    _storeHeight = (_height * _storePixelRatio).round();
    _transparent = true;

    _source = videoElement;
    _quad = new RenderTextureQuad(this, 0, 0, 0, 0, 0, _width, _height);
    _texture = null;
    _canvas = null;

    _globalFrameListeners.insert(0, _onGlobalFrame);
  }

  RenderTexture.fromRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer, num storePixelRatio) {

    _storePixelRatio = ensureNum(storePixelRatio);
    _storeWidth = ensureInt(renderFrameBuffer.width);
    _storeHeight = ensureInt(renderFrameBuffer.height);
    _width = (_storeWidth / _storePixelRatio).round();
    _height = (_storeHeight / _storePixelRatio).round();
    _transparent = true;

    _canvas = _source = null;
    _quad = new RenderTextureQuad(this, 0, 0, 0, 0, 0, _width, _height);

    _contextIdentifier = renderFrameBuffer.renderContext.contextIdentifier;
    _renderingContext = renderFrameBuffer.renderingContext;
    _texture = renderFrameBuffer.texture;
  }

  //-----------------------------------------------------------------------------------------------

  static Future<RenderTexture> load(
      String url, bool autoHiDpi, bool webpAvailable, bool corsEnabled) {

    var hiDpi = autoHiDpi && url.contains("@1x.");
    var hiDpiUrl = hiDpi ? url.replaceAll("@1x.", "@2x.") : url;
    var imageLoader = new ImageLoader(hiDpiUrl, webpAvailable, corsEnabled);

    return imageLoader.done.then((image) =>
        new RenderTexture.fromImage(image, hiDpi ? 2.0 : 1.0));
  }

  //-----------------------------------------------------------------------------------------------

  CanvasElement get canvas => _canvas;
  CanvasImageSource get source => _source;
  RenderTextureQuad get quad => _quad;
  RenderTextureFiltering get filtering => _filtering;

  gl.Texture get texture => _texture;

  int get width => _width;
  int get height => _height;

  int get storeWidth => _storeWidth;
  int get storeHeight => _storeHeight;
  num get storePixelRatio => _storePixelRatio;

  //-----------------------------------------------------------------------------------------------

  set filtering(RenderTextureFiltering filtering) {

    if (_filtering != filtering) {
      _filtering = filtering;

      if (_texture != null) {
        _renderingContext.activeTexture(gl.TEXTURE10);
        _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
        _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _filtering.value);
        _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _filtering.value);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {

    if (_contextIdentifier != -1) {
      _contextIdentifier = -1;
      _renderingContext.deleteTexture(_texture);
    }

    _texture = null;
    _source = null;
    _canvas = null;
    _renderingContext = null;
    _globalFrameListeners.remove(_onGlobalFrame);
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {
    if (width != _width || height != _height) {
      _width = ensureInt(width);
      _height = ensureInt(height);
      _storeWidth = (_width * _storePixelRatio).round();
      _storeHeight = (_height * _storePixelRatio).round();
      _canvas.width = _storeWidth;
      _canvas.height = _storeHeight;
      _quad = new RenderTextureQuad(this, 0, 0, 0, 0, 0, _width, _height);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void update() {

    if (_texture != null) {

      _renderingContext.activeTexture(gl.TEXTURE10);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);

      if (_textureSourceWorkaround) {
        _canvas.context2D.drawImage(_source, 0, 0);
        _renderingContext.texImage2DCanvas(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _canvas);
      } else {
        _renderingContext.texImage2DUntyped(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _source);
      }

      _renderingContext.bindTexture(gl.TEXTURE_2D, null);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext, int textureSlot) {

    if (_contextIdentifier != renderContext.contextIdentifier) {

      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _texture = _renderingContext.createTexture();

      _renderingContext.activeTexture(textureSlot);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
      _renderingContext.texImage2DUntyped(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _source);
      _textureSourceWorkaround = _renderingContext.getError() == gl.INVALID_VALUE;
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _filtering.value);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _filtering.value);

      if (_textureSourceWorkaround) {
        // IE sucks! WEBGL11072: INVALID_VALUE: texImage2D: This texture source is not supported
        _canvas = new CanvasElement(width: this.storeWidth, height: this.storeHeight);
        _canvas.context2D.drawImage(_source, 0, 0);
        _renderingContext.texImage2DCanvas(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, _canvas);
      }

    } else {

      _renderingContext.activeTexture(textureSlot);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
    }
  }

  //-----------------------------------------------------------------------------------------------

  num _videoUpdateTime = -1.0;

  void _onGlobalFrame(num deltaTime) {
    if (source is VideoElement) {
      var videoElement = source as VideoElement;
      var currentTime = videoElement.currentTime;
      if (_videoUpdateTime == currentTime) return;
      _videoUpdateTime = currentTime;
      update();
    }
  }

}