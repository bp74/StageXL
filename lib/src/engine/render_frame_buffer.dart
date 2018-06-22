part of stagexl.engine;

class RenderFrameBuffer {
  RenderTexture _renderTexture;
  RenderStencilBuffer _renderStencilBuffer;
  RenderContextWebGL _renderContext;

  int _contextIdentifier = -1;
  gl.Framebuffer _framebuffer;
  gl.RenderingContext _renderingContext;

  final List<_MaskState> _maskStates = new List<_MaskState>();

  RenderFrameBuffer.rawWebGL(int width, int height) {
    _renderTexture = new RenderTexture.rawWebGL(width, height);
    _renderStencilBuffer = new RenderStencilBuffer.rawWebGL(width, height);
  }

  //---------------------------------------------------------------------------

  int get width => _renderTexture.width;
  int get height => _renderTexture.height;
  int get contextIdentifier => _contextIdentifier;

  RenderTexture get renderTexture => _renderTexture;
  RenderStencilBuffer get renderStencilBuffer => _renderStencilBuffer;

  //---------------------------------------------------------------------------

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

  //---------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {
    if (this.contextIdentifier != renderContext.contextIdentifier) {
      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _framebuffer = renderContext.rawContext.createFramebuffer();
      _renderContext.activateRenderTexture(_renderTexture);
      _renderContext.activateRenderStencilBuffer(_renderStencilBuffer);

      var target = gl.WebGL.FRAMEBUFFER;
      var color = gl.WebGL.COLOR_ATTACHMENT0;
      var colorTarget = gl.WebGL.TEXTURE_2D;
      var colorData = _renderTexture.texture;
      var stencil = gl.WebGL.DEPTH_STENCIL_ATTACHMENT;
      var stencilTarget = gl.WebGL.RENDERBUFFER;
      var stencilData = _renderStencilBuffer.renderbuffer;

      _renderingContext.bindFramebuffer(target, _framebuffer);
      _renderingContext.framebufferTexture2D(
          target, color, colorTarget, colorData, 0);
      _renderingContext.framebufferRenderbuffer(
          target, stencil, stencilTarget, stencilData);
    } else {
      _renderingContext.bindFramebuffer(gl.WebGL.FRAMEBUFFER, _framebuffer);
    }
  }
}
