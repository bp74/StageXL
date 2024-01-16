part of '../engine.dart';

class RenderStencilBuffer {
  int _width = 0;
  int _height = 0;

  RenderContextWebGL? _renderContext;

  int _contextIdentifier = -1;
  gl.RenderingContext? _renderingContext;
  gl.Renderbuffer? _renderbuffer;

  RenderStencilBuffer.rawWebGL(int width, int height)
      : _width = width,
        _height = height;

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;

  gl.Renderbuffer? get renderbuffer => _renderbuffer;
  int get contextIdentifier => _contextIdentifier;

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {
    if (_renderbuffer != null) {
      _renderingContext!.deleteRenderbuffer(_renderbuffer);
    }

    _contextIdentifier = -1;
    _renderbuffer = null;
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {
    if (_width != width || _height != height) {
      _width = width;
      _height = height;

      if (_renderContext == null || _renderbuffer == null) return;
      if (_renderContext!.contextIdentifier != contextIdentifier) return;

      _renderContext!.activateRenderStencilBuffer(this);
      _renderingContext!.renderbufferStorage(
          gl.WebGL.RENDERBUFFER, gl.WebGL.DEPTH_STENCIL, _width, _height);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {
    if (contextIdentifier != renderContext.contextIdentifier) {
      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _renderbuffer = _renderingContext!.createRenderbuffer();
      _renderingContext!.bindRenderbuffer(gl.WebGL.RENDERBUFFER, _renderbuffer);
      _renderingContext!.renderbufferStorage(
          gl.WebGL.RENDERBUFFER, gl.WebGL.DEPTH_STENCIL, _width, _height);
    } else {
      _renderingContext!.bindRenderbuffer(gl.WebGL.RENDERBUFFER, _renderbuffer);
    }
  }
}
