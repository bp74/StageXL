part of stagexl;

class RenderContextWebGL extends RenderContext {

  final CanvasElement _canvasElement;
  final int _backgroundColor;

  final RenderProgramQuad _renderProgramQuad = new RenderProgramQuad();
  final RenderProgramTriangle _renderProgramTriangle = new RenderProgramTriangle();

  gl.RenderingContext _renderingContext;
  RenderTexture _renderTexture;
  RenderProgram _renderProgram;
  int _maskDepth = 0;

  RenderContextWebGL(CanvasElement canvasElement, int backgroundColor) :
    _canvasElement = canvasElement,
    _backgroundColor = _ensureInt(backgroundColor) {

    _canvasElement.onWebGlContextLost.listen(_onContextLost);
    _canvasElement.onWebGlContextRestored.listen(_onContextRestored);

    var renderingContext = _canvasElement.getContext3d(
        alpha: false, depth: false, stencil: true, antialias: false,
        premultipliedAlpha: true, preserveDrawingBuffer: false);

    if (renderingContext is! gl.RenderingContext) {
      throw new StateError("Failed to get WebGL context.");
    }

    _renderingContext = renderingContext;
    _renderingContext.enable(gl.BLEND);
    _renderingContext.disable(gl.STENCIL_TEST);
    _renderingContext.disable(gl.DEPTH_TEST);
    _renderingContext.disable(gl.CULL_FACE);
    _renderingContext.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
    _renderingContext.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);

    _renderProgram = _renderProgramQuad;
    _renderProgram.activate(this);
  }

  //-----------------------------------------------------------------------------------------------

  gl.RenderingContext get rawContext => _renderingContext;

  String get renderEngine => RenderEngine.WebGL;

  Matrix get viewPortMatrix {
    int width = _renderingContext.drawingBufferWidth;
    int height = _renderingContext.drawingBufferHeight;
    return new Matrix(2.0 / width, 0.0, 0.0, - 2.0 / height, -1.0, 1.0);
  }

  //-----------------------------------------------------------------------------------------------

  void clear() {

    int width = _renderingContext.drawingBufferWidth;
    int height = _renderingContext.drawingBufferHeight;
    num r = _colorGetR(_backgroundColor) / 255.0;
    num g = _colorGetG(_backgroundColor) / 255.0;
    num b = _colorGetB(_backgroundColor) / 255.0;

    _renderingContext.viewport(0, 0, width, height);
    _renderingContext.colorMask(true, true, true, true);
    _renderingContext.clearColor(r, g, b, 1.0);
    _renderingContext.clear(gl.COLOR_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
  }

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {
    _updateState(_renderProgramQuad, renderTextureQuad.renderTexture);
    _renderProgramQuad.renderQuad(renderState, renderTextureQuad);
  }

  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2, num x3, num y3, int color) {
    _updateState(_renderProgramTriangle, _renderTexture);
    _renderProgramTriangle.renderTriangle(renderState, x1, y1, x2, y2, x3, y3, color);
  }

  void flush() {
    _renderProgram.flush();
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, Mask mask) {

    if (_maskDepth == 0) {
      _renderProgram.flush();
      _renderingContext.enable(gl.STENCIL_TEST);
    }

    _updateState(_renderProgramTriangle, null);
    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);
    _renderingContext.stencilMask(0xFF);
    _renderingContext.colorMask(false, false, false, false);
    _maskDepth += 1;

    mask.renderMask(renderState);

    _updateState(_renderProgramQuad, null);
    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilMask(0x00);
    _renderingContext.colorMask(true, true, true, true);
  }

  void endRenderMask(RenderState renderState, Mask mask) {

    if (_maskDepth == 1) {

      _renderProgram.flush();
      _maskDepth = 0;
      _renderingContext.stencilMask(0xFF);
      _renderingContext.disable(gl.STENCIL_TEST);
      _renderingContext.clear(gl.STENCIL_BUFFER_BIT);
      _renderingContext.stencilMask(0);

    } else {

      _updateState(_renderProgramTriangle, null);
      _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
      _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.DECR);
      _renderingContext.stencilMask(0xFF);
      _renderingContext.colorMask(false, false, false, false);
      _maskDepth -= 1;

      renderState.globalMatrix.copyFrom(_identityMatrix);
      renderState.renderTriangle(-1, -1, 1, -1, 1, 1, Color.Magenta);
      renderState.renderTriangle(-1, -1, 1, 1, -1, 1, Color.Magenta);
      renderState.flush();

      _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
      _renderingContext.stencilMask(0x00);
      _renderingContext.colorMask(true, true, true, true);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderShadow(RenderState renderState, Shadow shadow) {
    // TODO: We will add this once we have WebGL filters.
  }

  void endRenderShadow(RenderState renderState, Shadow shadow) {

  }

  //-----------------------------------------------------------------------------------------------

  RenderFrameBuffer beginFrameBuffer(int width, int height) {
    // TODO: get from pool, use stack
    var renderFrameBuffer = new RenderFrameBuffer(_renderingContext, width, height);
    _renderProgram.flush();
    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, renderFrameBuffer.framebuffer);
    _renderingContext.viewport(0, 0, renderFrameBuffer.width, renderFrameBuffer.height);
    renderFrameBuffer.clear();
    return renderFrameBuffer;
  }

  void endFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    // TODO: release to pool, use stack
    _renderProgram.flush();

    int width = _renderingContext.drawingBufferWidth;
    int height = _renderingContext.drawingBufferHeight;

    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
    _renderingContext.viewport(0, 0, width, height);

  }

  //-----------------------------------------------------------------------------------------------

  _updateState(RenderProgram renderProgram, RenderTexture renderTexture) {

    // dartbug.com/16286

    if (renderProgram != null) {
      if (identical(renderProgram, _renderProgram) == false) {
        _renderProgram.flush();
        _renderProgram = renderProgram;
        _renderProgram.activate(this);
      }
    }

    if (renderTexture != null) {
      if (identical(renderTexture, _renderTexture) == false) {
        _renderProgram.flush();
        _renderTexture = renderTexture;
        _renderTexture.activate(this, gl.TEXTURE0);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _onContextLost(gl.ContextEvent contextEvent) {
    contextEvent.preventDefault();
    this.dispatchEvent(new Event("contextLost"));
  }

  _onContextRestored(gl.ContextEvent contextEvent) {
    this.dispatchEvent(new Event("contextRestored"));
  }

}