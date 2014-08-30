part of stagexl.engine;

class RenderFrameBuffer {

  gl.RenderingContext _renderingContext;
  gl.Framebuffer _framebuffer;
  gl.Renderbuffer _renderbuffer;
  gl.Texture _texture;

  RenderContextWebGL _renderContext;
  RenderTexture _renderTexture;

  int _width;
  int _height;
  int _stencilDepth = 0;

  RenderFrameBuffer(RenderContextWebGL renderContext, int width, int height) :

    _width = width,
    _height = height,
    _renderContext = renderContext,
    _renderingContext = renderContext.rawContext,
    _framebuffer = renderContext.rawContext.createFramebuffer(),
    _renderbuffer = renderContext.rawContext.createRenderbuffer(),
    _texture = renderContext.rawContext.createTexture() {

    // http://www.songho.ca/opengl/gl_fbo.html
    // Switching the texture of the FBO is faster than switching FBO itself?! We will try this later.

    _renderingContext.activeTexture(gl.TEXTURE10);
    _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
    _renderingContext.texImage2DTyped(gl.TEXTURE_2D, 0, gl.RGBA, _width, _height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    _renderingContext.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    _renderingContext.bindTexture(gl.TEXTURE_2D, null);

    _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, _renderbuffer);
    _renderingContext.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL, _width, _height);
    _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, null);

    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, _framebuffer);
    _renderingContext.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, _texture, 0);
    _renderingContext.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, _renderbuffer);
    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);

    _renderTexture = new RenderTexture.fromRenderFrameBuffer(this, 1.0);
  }

  //-----------------------------------------------------------------------------------------------

  gl.RenderingContext get renderingContext => _renderingContext;
  gl.Framebuffer get framebuffer => _framebuffer;
  gl.Renderbuffer get renderbuffer => _renderbuffer;
  gl.Texture get texture => _texture;

  RenderContextWebGL get renderContext => _renderContext;
  RenderTexture get renderTexture => _renderTexture;

  int get width => _width;
  int get height => _height;
  int get stencilDepth => _stencilDepth;

  //-----------------------------------------------------------------------------------------------

  /**
   * Call the dispose method the release memory allocated by WebGL.
   */

  void dispose() {
    if (_texture != null) _renderingContext.deleteTexture(_texture);
    if (_renderbuffer != null) _renderingContext.deleteRenderbuffer(_renderbuffer);
    if (_framebuffer != null) _renderingContext.deleteFramebuffer(_framebuffer);
    _texture = null;
    _renderbuffer = null;
    _texture = null;
  }

  //-----------------------------------------------------------------------------------------------

  void resize(int width, int height) {
    if (_width != width || _height != height) {
      _width = width;
      _height = height;
      _renderingContext.activeTexture(gl.TEXTURE10);
      _renderingContext.bindTexture(gl.TEXTURE_2D, _texture);
      _renderingContext.texImage2DTyped(gl.TEXTURE_2D, 0, gl.RGBA, _width, _height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
      _renderingContext.bindTexture(gl.TEXTURE_2D, null);

      _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, _renderbuffer);
      _renderingContext.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL , _width, _height);
      _renderingContext.bindRenderbuffer(gl.RENDERBUFFER, null);

      _renderTexture = new RenderTexture.fromRenderFrameBuffer(this, 1.0);
    }
  }

}