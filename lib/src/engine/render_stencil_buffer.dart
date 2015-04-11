part of stagexl.engine;

class RenderStencilBuffer {

  int _width = 0;
  int _height = 0;
  int _depth = 0;

  RenderContextWebGL _renderContext = null;

  int _contextIdentifier = -1;
  gl.RenderingContext _renderingContext = null;
  gl.Renderbuffer _renderbuffer = null;

  RenderStencilBuffer.rawWebGL(int width, int height) {
    _width = ensureInt(width);
    _height = ensureInt(height);
    _depth = 0;
  }

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;
  int get depth => _depth;

  gl.Renderbuffer get renderbuffer => _renderbuffer;
  int get contextIdentifier => _contextIdentifier;

  void set depth(int value) {
    _depth = ensureInt(value);
  }

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {

    if (_renderbuffer != null) _renderingContext.deleteRenderbuffer(_renderbuffer);

    _contextIdentifier = -1;
    _renderbuffer = null;
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {

    if (_width != width || _height != height) {

      _width = width;
      _height = height;

      if (_renderContext == null || _renderbuffer == null) return;
      if (_renderContext.contextIdentifier != contextIdentifier) return;

      _renderContext.activateRenderStencilBuffer(this);
      _renderingContext.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL, _width, _height);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {
      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _renderbuffer = _renderingContext.createRenderbuffer();
      _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, _renderbuffer);
      _renderingContext.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL, _width, _height);
    } else {
      _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, _renderbuffer);
    }
  }

}