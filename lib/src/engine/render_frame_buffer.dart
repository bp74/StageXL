part of stagexl.engine;

class RenderFrameBuffer {

  RenderContextWebGL _renderContext = null;
  RenderStencilBuffer _renderStencilBuffer = null;
  RenderTexture _renderTexture = null;

  int _contextIdentifier = -1;
  gl.Framebuffer _framebuffer = null;
  gl.RenderingContext _renderingContext = null;

  int _width = 0;
  int _height = 0;

  RenderFrameBuffer.rawWebGL(int width, int height) {
    _width = ensureInt(width);
    _height = ensureInt(height);
    _renderTexture = new RenderTexture.rawWebGL(width, height);
    _renderStencilBuffer = new RenderStencilBuffer.rawWebGL(width, height);
  }

  //-----------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;

  RenderTexture get renderTexture => _renderTexture;
  RenderStencilBuffer get renderStencilBuffer => _renderStencilBuffer;

  gl.Framebuffer get framebuffer => _framebuffer;
  int get contextIdentifier => _contextIdentifier;

  //-----------------------------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {

    if (_renderTexture != null) _renderTexture.dispose();
    if (_renderStencilBuffer != null) _renderStencilBuffer.dispose();
    if (_framebuffer != null) _renderingContext.deleteFramebuffer(_framebuffer);

    _contextIdentifier = -1;
    _renderTexture = null;
    _renderStencilBuffer = null;
    _framebuffer = null;
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {

    if (_width != width || _height != height) {

      _width = width;
      _height = height;
      _renderTexture.resize(width, height);
      _renderStencilBuffer.resize(width, height);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _framebuffer = renderContext.rawContext.createFramebuffer();
      _renderContext.activateRenderTexture(_renderTexture);
      _renderContext.activateRenderStencilBuffer(_renderStencilBuffer);

      var target = gl.FRAMEBUFFER;
      var color = gl.COLOR_ATTACHMENT0;
      var colorTarget = gl.TEXTURE_2D;
      var colorData = _renderTexture.texture;
      var stencil = gl.DEPTH_STENCIL_ATTACHMENT;
      var stencilTarget = gl.RENDERBUFFER;
      var stencilData = _renderStencilBuffer.renderbuffer;

      _renderingContext.bindFramebuffer(target, _framebuffer);
      _renderingContext.framebufferTexture2D(target, color, colorTarget, colorData, 0);
      _renderingContext.framebufferRenderbuffer(target, stencil, stencilTarget, stencilData);

    } else {

      _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, _framebuffer);

    }
  }

}