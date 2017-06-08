part of stagexl.engine;

class RenderTexture {

  int _width = 0;
  int _height = 0;

  CanvasImageSource _source;
  CanvasElement _canvas;
  RenderTextureFiltering _filtering = RenderTextureFiltering.LINEAR;
  RenderTextureWrapping _wrappingX = RenderTextureWrapping.CLAMP;
  RenderTextureWrapping _wrappingY = RenderTextureWrapping.CLAMP;
  RenderContextWebGL _renderContext;

  int _contextIdentifier = -1;
  bool _textureSourceWorkaround = false;
  gl.RenderingContext _renderingContext;
  gl.Texture _texture;

  //-----------------------------------------------------------------------------------------------

  RenderTexture(int width, int height, int fillColor) {

    if (width <= 0) throw new ArgumentError("width");
    if (height <= 0) throw new ArgumentError("height");

    _width = ensureInt(width);
    _height = ensureInt(height);
    _source = _canvas = new CanvasElement(width: _width, height: _height);

    if (fillColor != 0) {
      var context = _canvas.context2D;
      context.fillStyle = color2rgba(fillColor);
      context.fillRect(0, 0, _width, _height);
    }
  }

  RenderTexture.fromImageElement(ImageElement imageElement) {
    _width = ensureInt(imageElement.width);
    _height = ensureInt(imageElement.height);
    _source = imageElement;
  }

  RenderTexture.fromCanvasElement(CanvasElement canvasElement) {
    _width = ensureInt(canvasElement.width);
    _height = ensureInt(canvasElement.height);
    _source = _canvas = canvasElement;
  }

  RenderTexture.fromVideoElement(VideoElement videoElement) {
    if (videoElement.readyState < 3) throw new ArgumentError("videoElement");
    _width = ensureInt(videoElement.videoWidth);
    _height = ensureInt(videoElement.videoHeight);
    _source = videoElement;
    _globalFrameListeners.insert(0, _onGlobalFrame);
  }

  RenderTexture.rawWebGL(int width, int height) {
    _width = ensureInt(width);
    _height = ensureInt(height);
  }

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;
  CanvasImageSource get source => _source;

  RenderTextureQuad get quad {
    return new RenderTextureQuad(this,
        new Rectangle<int>(0, 0, _width, _height),
        new Rectangle<int>(0, 0, _width, _height), 0, 1.0);
  }

  CanvasElement get canvas {
    if (_source is CanvasElement) {
      return _source;
    } else if (_source is ImageElement) {
      ImageElement imageElement = _source;
      _canvas = _source = new CanvasElement(width: _width, height: _height);
      _canvas.context2D.drawImageScaled(imageElement, 0, 0, _width, _height);
      return _canvas;
    } else {
      throw new StateError("RenderTexture is read only.");
    }
  }

  gl.Texture get texture => _texture;
  int get contextIdentifier => _contextIdentifier;

  //-----------------------------------------------------------------------------------------------

  /// Get or set the filtering used for this RenderTexture.
  ///
  /// The default is [RenderTextureFiltering.LINEAR] which is fine
  /// for most use cases. In games with 2D pixel art it is sometimes better
  /// to use the [RenderTextureFiltering.NEAREST] filtering.

  RenderTextureFiltering get filtering => _filtering;

  set filtering(RenderTextureFiltering filtering) {

    if (_filtering == filtering) return;
    _filtering = filtering;

    if (_renderContext == null || _texture == null) return;
    if (_renderContext.contextIdentifier != contextIdentifier) return;

    _renderContext.activateRenderTexture(this);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _filtering.value);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _filtering.value);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureWrapping get wrappingX => _wrappingX;

  set wrappingX(RenderTextureWrapping wrapping) {

    if (_wrappingX == wrapping) return;
    _wrappingX = wrapping;

    if (_renderContext == null || _texture == null) return;
    if (_renderContext.contextIdentifier != contextIdentifier) return;

    _renderContext.activateRenderTexture(this);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, _wrappingX.value);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureWrapping get wrappingY => _wrappingY;

  set wrappingY(RenderTextureWrapping wrapping) {

    if (_wrappingY == wrapping) return;
    _wrappingY = wrapping;

    if (_renderContext == null || _texture == null) return;
    if (_renderContext.contextIdentifier != contextIdentifier) return;

    _renderContext.activateRenderTexture(this);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, _wrappingY.value);
  }

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {

    if (_renderingContext != null && _texture != null) {
      _renderingContext.deleteTexture(_texture);
    }

    _texture = null;
    _source = null;
    _canvas = null;
    _renderingContext = null;
    _contextIdentifier = -1;
    _globalFrameListeners.remove(_onGlobalFrame);
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {

    if (_source is VideoElement) {

      throw new StateError("RenderTexture is not resizeable.");

    } else if (_width == width && _height == height) {

      // there is no need to resize the texture

    } else if (_source == null) {

      _width = width;
      _height = height;

      if (_renderContext == null || _texture == null) return;
      if (_renderContext.contextIdentifier != contextIdentifier) return;

      var target = gl.TEXTURE_2D;
      var rgba = gl.RGBA;
      var type = gl.UNSIGNED_BYTE;

      _renderContext.activateRenderTexture(this);
      _renderingContext.texImage2D(target, 0, rgba, _width, _height, 0, rgba, type, null);

    } else {

      _width = width;
      _height = height;
      _canvas = _source = new CanvasElement(width: _width, height: _height);
    }
  }

  //-----------------------------------------------------------------------------------------------

  /// Update the underlying WebGL texture with the source of this RenderTexture.
  ///
  /// The source of the RenderTexture is an ImageElement, CanvasElement or
  /// VideoElement. If changes are made to the source you have to call the
  /// [update] method to apply those changes to the WebGL texture.
  ///
  /// The progress in a VideoElement will automatically updated the
  /// RenderTexture and you don't need to call the [update] method.

  void update() {

    if (_renderContext == null || _texture == null) return;
    if (_renderContext.contextIdentifier != contextIdentifier) return;

    var target = gl.TEXTURE_2D;
    var rgba = gl.RGBA;
    var type = gl.UNSIGNED_BYTE;

    var scissors = _renderingContext.isEnabled(gl.SCISSOR_TEST);
    if (scissors) _renderingContext.disable(gl.SCISSOR_TEST);

    if (_textureSourceWorkaround) {
      _canvas.context2D.drawImage(_source, 0, 0);
      _renderContext.activateRenderTexture(this);
      _renderingContext.texImage2D(target, 0, rgba, rgba, type, _canvas);
    } else {
      _renderContext.activateRenderTexture(this);
      _renderingContext.texImage2D(target, 0, rgba, rgba, type, _source);
    }

    if (scissors) _renderingContext.enable(gl.SCISSOR_TEST);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext, int textureSlot) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      var target = gl.TEXTURE_2D;
      var rgba = gl.RGBA;
      var type = gl.UNSIGNED_BYTE;

      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _texture = _renderingContext.createTexture();

      _renderingContext.activeTexture(textureSlot);
      _renderingContext.bindTexture(target, _texture);

      var scissors = _renderingContext.isEnabled(gl.SCISSOR_TEST);
      if (scissors) _renderingContext.disable(gl.SCISSOR_TEST);

      if (_source != null) {
        _renderingContext.texImage2D(target, 0, rgba, rgba, type, _source);
        _textureSourceWorkaround = _renderingContext.getError() == gl.INVALID_VALUE;
      } else {
        _renderingContext.texImage2D(target, 0, rgba, width, height, 0, rgba, type, null);
      }

      if (_textureSourceWorkaround) {
        // WEBGL11072: INVALID_VALUE: texImage2D: This texture source is not supported
        _canvas = new CanvasElement(width: width, height: height);
        _canvas.context2D.drawImage(_source, 0, 0);
        _renderingContext.texImage2D(target, 0, rgba, rgba, type, _canvas);
      }

      if (scissors) _renderingContext.enable(gl.SCISSOR_TEST);

      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, _wrappingX.value);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, _wrappingY.value);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _filtering.value);
      _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _filtering.value);

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
      if (_videoUpdateTime != currentTime) {
        _videoUpdateTime = currentTime;
        update();
      }
    }
  }

}
