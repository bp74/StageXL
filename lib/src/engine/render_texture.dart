part of stagexl.engine;

class RenderTexture {
  int _width = 0;
  int _height = 0;

  CanvasImageSource? _source;
  CanvasElement? _canvas;
  RenderTextureFiltering _filtering = RenderTextureFiltering.LINEAR;
  RenderTextureWrapping _wrappingX = RenderTextureWrapping.CLAMP;
  RenderTextureWrapping _wrappingY = RenderTextureWrapping.CLAMP;
  RenderContextWebGL? _renderContext;

  int _contextIdentifier = -1;
  bool _textureSourceWorkaround = false;
  gl.RenderingContext? _renderingContext;
  gl.Texture? _texture;

  //-----------------------------------------------------------------------------------------------

  RenderTexture(int width, int height, int fillColor) {
    if (width <= 0) throw ArgumentError('width');
    if (height <= 0) throw ArgumentError('height');

    _width = width;
    _height = height;
    _source = _canvas = CanvasElement(width: _width, height: _height);

    if (fillColor != 0) {
      var context = _canvas!.context2D;
      context.fillStyle = color2rgba(fillColor);
      context.fillRect(0, 0, _width, _height);
    }
  }

  RenderTexture.fromImageElement(ImageElement imageElement) {
    _width = imageElement.width!;
    _height = imageElement.height!;
    _source = imageElement;
  }

  RenderTexture.fromCanvasElement(CanvasElement canvasElement) {
    _width = canvasElement.width!;
    _height = canvasElement.height!;
    _source = _canvas = canvasElement;
  }

  RenderTexture.fromVideoElement(VideoElement videoElement) {
    if (videoElement.readyState < 3) throw ArgumentError('videoElement');
    _width = videoElement.videoWidth;
    _height = videoElement.videoHeight;
    _source = videoElement;
    _globalFrameListeners.insert(0, _onGlobalFrame);
  }

  RenderTexture.rawWebGL(int width, int height) :
    _width = width,
    _height = height;

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;
  CanvasImageSource? get source => _source;

  RenderTextureQuad get quad {
    return RenderTextureQuad(this, Rectangle<int>(0, 0, _width, _height),
        Rectangle<int>(0, 0, _width, _height), 0, 1.0);
  }

  CanvasElement get canvas {
    if (_source is CanvasElement) {
      return _source as CanvasElement;
    } else if (_source is ImageElement) {
      var imageElement = _source as ImageElement;
      _canvas = _source = CanvasElement(width: _width, height: _height);
      _canvas!.context2D.drawImageScaled(imageElement, 0, 0, _width, _height);
      return _canvas!;
    } else {
      throw StateError('RenderTexture is read only.');
    }
  }

  gl.Texture? get texture => _texture;
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
    if (_renderContext!.contextIdentifier != contextIdentifier) return;

    _renderContext!.activateRenderTexture(this);
    _renderingContext!.texParameteri(
        gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_MIN_FILTER, _filtering.value);
    _renderingContext!.texParameteri(
        gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_MAG_FILTER, _filtering.value);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureWrapping get wrappingX => _wrappingX;

  set wrappingX(RenderTextureWrapping wrapping) {
    if (_wrappingX == wrapping) return;
    _wrappingX = wrapping;

    if (_renderContext == null || _texture == null) return;
    if (_renderContext!.contextIdentifier != contextIdentifier) return;

    _renderContext!.activateRenderTexture(this);
    _renderingContext!.texParameteri(
        gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_WRAP_S, _wrappingX.value);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureWrapping get wrappingY => _wrappingY;

  set wrappingY(RenderTextureWrapping wrapping) {
    if (_wrappingY == wrapping) return;
    _wrappingY = wrapping;

    if (_renderContext == null || _texture == null) return;
    if (_renderContext!.contextIdentifier != contextIdentifier) return;

    _renderContext!.activateRenderTexture(this);
    _renderingContext!.texParameteri(
        gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_WRAP_T, _wrappingY.value);
  }

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {
    if (_texture != null) {
      _renderingContext?.deleteTexture(_texture);
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
      throw StateError('RenderTexture is not resizeable.');
    } else if (_width == width && _height == height) {
      // there is no need to resize the texture

    } else if (_source == null) {
      _width = width;
      _height = height;

      if (_renderContext == null || _texture == null) return;
      if (_renderContext!.contextIdentifier != contextIdentifier) return;

      var target = gl.WebGL.TEXTURE_2D;
      var rgba = gl.WebGL.RGBA;
      var type = gl.WebGL.UNSIGNED_BYTE;

      _renderContext!.activateRenderTexture(this);
      _renderingContext!.texImage2D(
          target, 0, rgba, _width, _height, 0, rgba, type, null);
    } else {
      _width = width;
      _height = height;
      _canvas = _source = CanvasElement(width: _width, height: _height);
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
    if (_renderContext!.contextIdentifier != contextIdentifier) return;

    var target = gl.WebGL.TEXTURE_2D;
    var rgba = gl.WebGL.RGBA;
    var type = gl.WebGL.UNSIGNED_BYTE;

    _renderContext!.flush();
    _renderContext!.activateRenderTexture(this);

    var scissors = _renderingContext!.isEnabled(gl.WebGL.SCISSOR_TEST);
    if (scissors) _renderingContext!.disable(gl.WebGL.SCISSOR_TEST);

    if (_textureSourceWorkaround) {
      _canvas!.context2D.drawImage(_source!, 0, 0);
      _renderingContext!.texImage2D(target, 0, rgba, rgba, type, _canvas);
    } else {
      _renderingContext!.texImage2D(target, 0, rgba, rgba, type, _source);
    }

    if (scissors) _renderingContext!.enable(gl.WebGL.SCISSOR_TEST);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext, int textureSlot) {
    if (contextIdentifier != renderContext.contextIdentifier) {
      var target = gl.WebGL.TEXTURE_2D;
      var rgba = gl.WebGL.RGBA;
      var type = gl.WebGL.UNSIGNED_BYTE;

      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      final renderingContext = _renderingContext = renderContext.rawContext;
      _texture = renderingContext.createTexture();

      renderingContext.activeTexture(textureSlot);
      renderingContext.bindTexture(target, _texture);

      var scissors = renderingContext.isEnabled(gl.WebGL.SCISSOR_TEST);
      if (scissors) renderingContext.disable(gl.WebGL.SCISSOR_TEST);

      if (_source != null) {
        renderingContext.texImage2D(target, 0, rgba, rgba, type, _source);
        _textureSourceWorkaround =
            renderingContext.getError() == gl.WebGL.INVALID_VALUE;
      } else {
        renderingContext.texImage2D(
            target, 0, rgba, width, height, 0, rgba, type, null);
      }

      if (_textureSourceWorkaround) {
        // WEBGL11072: INVALID_VALUE: texImage2D: This texture source is not supported
        _canvas = CanvasElement(width: width, height: height);
        _canvas!.context2D.drawImage(_source!, 0, 0);
        renderingContext.texImage2D(target, 0, rgba, rgba, type, _canvas);
      }

      if (scissors) renderingContext.enable(gl.WebGL.SCISSOR_TEST);

      renderingContext.texParameteri(
          gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_WRAP_S, _wrappingX.value);
      renderingContext.texParameteri(
          gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_WRAP_T, _wrappingY.value);
      renderingContext.texParameteri(
          gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_MIN_FILTER, _filtering.value);
      renderingContext.texParameteri(
          gl.WebGL.TEXTURE_2D, gl.WebGL.TEXTURE_MAG_FILTER, _filtering.value);
    } else {
      _renderingContext!.activeTexture(textureSlot);
      _renderingContext!.bindTexture(gl.WebGL.TEXTURE_2D, _texture);
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
