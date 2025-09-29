part of '../engine.dart';

class RenderTexture {
  int _width = 0;
  int _height = 0;

  // TODO: Make CanvasImageSource again once
  // https://github.com/dart-lang/sdk/issues/12379#issuecomment-572239799
  // is addressed
  web.CanvasImageSource? _source;
  web.HTMLCanvasElement? _canvas;
  RenderTextureFiltering _filtering = RenderTextureFiltering.LINEAR;
  RenderTextureWrapping _wrappingX = RenderTextureWrapping.CLAMP;
  RenderTextureWrapping _wrappingY = RenderTextureWrapping.CLAMP;
  RenderContextWebGL? _renderContext;

  int _contextIdentifier = -1;
  bool _textureSourceWorkaround = false;
  gl.RenderingContext? _renderingContext;
  gl.Texture? _texture;

  int _pixelFormat = gl.WebGL.RGBA;
  int _pixelType = gl.WebGL.UNSIGNED_BYTE;

  //-----------------------------------------------------------------------------------------------

  RenderTexture(int width, int height, int fillColor) {
    if (width <= 0) throw ArgumentError('width');
    if (height <= 0) throw ArgumentError('height');

    _width = width;
    _height = height;
    _source = _canvas = web.HTMLCanvasElement()
      ..width = _width
      ..height = _height;

    if (fillColor != 0) {
      final context = _canvas!.context2D;
      context.fillStyle = color2rgba(fillColor).toJS;
      context.fillRect(0, 0, _width, _height);
    }
  }

  RenderTexture.fromImageElement(web.HTMLImageElement imageElement) {
    _width = imageElement.width;
    _height = imageElement.height;
    _source = imageElement;
  }

  RenderTexture.fromImageBitmap(web.ImageBitmap image) {
    _width = image.width;
    _height = image.height;
    _source = image;
  }

  RenderTexture.fromCanvasElement(web.HTMLCanvasElement canvasElement) {
    _width = canvasElement.width;
    _height = canvasElement.height;
    _source = _canvas = canvasElement;
  }

  RenderTexture.fromVideoElement(web.HTMLVideoElement videoElement) {
    if (videoElement.readyState < 3) throw ArgumentError('videoElement');
    _width = videoElement.videoWidth;
    _height = videoElement.videoHeight;
    _source = videoElement;
    _globalFrameListeners.insert(0, _onGlobalFrame);
  }

  RenderTexture.rawWebGL(int width, int height)
      : _width = width,
        _height = height;

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;

  web.CanvasImageSource? get source {
    if (_source is web.CanvasImageSource) return _source;
    return null;
  }

  RenderTextureQuad get quad => RenderTextureQuad(
      this,
      Rectangle<int>(0, 0, _width, _height),
      Rectangle<int>(0, 0, _width, _height),
      0,
      1.0);

  web.HTMLCanvasElement get canvas {
    if (_source.isA<web.HTMLCanvasElement>()) {
      return _source as web.HTMLCanvasElement;
    } else if (_source.isA<web.HTMLImageElement>()) {
      final imageElement = _source as web.HTMLImageElement;
      _source = _canvas = web.HTMLCanvasElement()
        ..width = _width
        ..height = _height;

      _canvas!.context2D.drawImage(imageElement, 0, 0, _width, _height);
      return _canvas!;
    } else if (_source.isA<web.ImageBitmap>()) {
      final image = _source as web.ImageBitmap;
      _source = _canvas = web.HTMLCanvasElement()
        ..width = _width
        ..height = _height;

      // Note: We need to use js_util.callMethod, because Dart SDK
      // does not support ImageBitmap as a CanvasImageSource
      _canvas!.context2D.drawImage(
        image,
        0,
        0,
        _width,
        _height,
      );

      return _canvas!;
    } else {
      throw StateError('RenderTexture is read only.');
    }
  }
  web.ImageBitmap? get imageBitmap {
    if (_source is web.ImageBitmap) return _source as web.ImageBitmap?;
    return null;
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

  int get pixelFormat => _pixelFormat;

  set pixelFormat(int value) {
    if (pixelFormat == value) return;

    _pixelFormat = value;
    update();
  }

  int get pixelType => _pixelType;

  set pixelType(int value) {
    if (pixelType == value) return;

    _pixelType = value;
    update();
  }

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {
    if (_texture != null) {
      _renderingContext?.deleteTexture(_texture);
    }

    if (_source is web.ImageBitmap) {
      (_source as web.ImageBitmap).close();
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
    if (_source is web.HTMLVideoElement) {
      throw StateError('RenderTexture is not resizeable.');
    } else if (_width == width && _height == height) {
      // there is no need to resize the texture
    } else if (_source == null) {
      _width = width;
      _height = height;

      if (_renderContext == null || _texture == null) return;
      if (_renderContext!.contextIdentifier != contextIdentifier) return;

      const target = web.WebGL.TEXTURE_2D;

      _renderContext!.activateRenderTexture(this);
      _renderingContext!.texImage2D(
          target, 0, pixelFormat, _width, _height, 0, pixelFormat, pixelType);
    } else {
      _width = width;
      _height = height;
      _source = _canvas = web.HTMLCanvasElement()
        ..width = _width
        ..height = _height;
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

    _renderContext!.flush();
    _renderContext!.activateRenderTexture(this);

    final scissors = _renderingContext!.isEnabled(gl.WebGL.SCISSOR_TEST);
    if (scissors) _renderingContext!.disable(gl.WebGL.SCISSOR_TEST);

    const target = gl.WebGL.TEXTURE_2D;

    if (_textureSourceWorkaround) {
      _canvas!.context2D.drawImage(source!, 0, 0);
      _renderingContext!
          .texImage2D(target, 0, pixelFormat, pixelFormat, pixelType, _canvas);
    } else {
      _renderingContext!
          .texImage2D(target, 0, pixelFormat, pixelFormat, pixelType, _source);
    }

    if (scissors) _renderingContext!.enable(gl.WebGL.SCISSOR_TEST);
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext, int textureSlot) {
    if (contextIdentifier != renderContext.contextIdentifier) {
      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      final renderingContext = _renderingContext = renderContext.rawContext;
      _texture = renderingContext.createTexture();

      const target = gl.WebGL.TEXTURE_2D;

      renderingContext.activeTexture(textureSlot);
      renderingContext.bindTexture(target, _texture);

      final scissors = renderingContext.isEnabled(gl.WebGL.SCISSOR_TEST);
      if (scissors) renderingContext.disable(gl.WebGL.SCISSOR_TEST);

      if (_source != null) {
        renderingContext.texImage2D(
            target, 0, pixelFormat, pixelFormat, pixelType, _source);
        _textureSourceWorkaround =
            renderingContext.getError() == gl.WebGL.INVALID_VALUE;
      } else {
        renderingContext.texImage2D(
            target, 0, pixelFormat, width, height, 0, pixelFormat, pixelType);
      }

      if (_textureSourceWorkaround) {
        // WEBGL11072: INVALID_VALUE: texImage2D: This texture source is not supported
        _canvas = web.HTMLCanvasElement()
            ..width = width
            ..height = height;
        _canvas!.context2D.drawImage(source!, 0, 0);
        renderingContext.texImage2D(
            target, 0, pixelFormat, pixelFormat, pixelType, _canvas);
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
    if (source is web.HTMLVideoElement) {
      final videoElement = source as web.HTMLVideoElement;
      final currentTime = videoElement.currentTime;
      if (_videoUpdateTime != currentTime) {
        _videoUpdateTime = currentTime;
        update();
      }
    }
  }
}
