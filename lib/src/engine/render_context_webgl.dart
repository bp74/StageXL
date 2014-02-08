part of stagexl;

class RenderContextWebGL extends RenderContext {

  final CanvasElement _canvasElement;

  final RenderProgramQuad _renderProgramQuad = new RenderProgramQuad();
  final RenderProgramTriangle _renderProgramTriangle = new RenderProgramTriangle();
  final List<RenderFrameBuffer> _renderFrameBuffers = new List<RenderFrameBuffer>();

  gl.RenderingContext _renderingContext;
  RenderTexture _renderTexture;
  RenderProgram _renderProgram;
  int _maskDepth = 0;

  RenderContextWebGL(CanvasElement canvasElement) : _canvasElement = canvasElement {

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

  void reset() {
    int width = _renderingContext.drawingBufferWidth;
    int height = _renderingContext.drawingBufferHeight;
    _renderingContext.viewport(0, 0, width, height);
    _renderFrameBuffers.clear();
  }

  void clear(int color) {
    num r = _colorGetR(color) / 255.0;
    num g = _colorGetG(color) / 255.0;
    num b = _colorGetB(color) / 255.0;
    num a = _colorGetA(color) / 255.0;

    _renderingContext.colorMask(true, true, true, true);
    _renderingContext.clearColor(r, g, b, a);
    _renderingContext.clear(gl.COLOR_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);

    // TODO: maskDepth for RenderFrameBuffer!
    _maskDepth = 0;
  }

  void flush() {
    _renderProgram.flush();
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {
    _updateState(_renderProgramQuad, renderTextureQuad.renderTexture);
    _renderProgramQuad.renderQuad(renderState, renderTextureQuad);
  }

  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2, num x3, num y3, int color) {
    _updateState(_renderProgramTriangle, _renderTexture);
    _renderProgramTriangle.renderTriangle(renderState, x1, y1, x2, y2, x3, y3, color);
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, Mask mask) {

    _renderProgram.flush();

    if (_maskDepth == 0) {
      _renderingContext.enable(gl.STENCIL_TEST);
    }

    _updateState(_renderProgramTriangle, null);
    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);
    _renderingContext.stencilMask(0xFF);
    _renderingContext.colorMask(false, false, false, false);
    _maskDepth += 1;

    mask.renderMask(renderState);
    renderState.flush();

    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilMask(0x00);
    _renderingContext.colorMask(true, true, true, true);
  }

  void endRenderMask(RenderState renderState, Mask mask) {

    _renderProgram.flush();

    if (_maskDepth == 1) {

      _maskDepth = 0;
      _renderingContext.stencilMask(0xFF);
      _renderingContext.disable(gl.STENCIL_TEST);
      _renderingContext.clear(gl.STENCIL_BUFFER_BIT);
      _renderingContext.stencilMask(0x00);

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

  void pushFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, renderFrameBuffer.framebuffer);
    _renderingContext.viewport(0, 0, renderFrameBuffer.width, renderFrameBuffer.height);
    _renderFrameBuffers.add(renderFrameBuffer);
  }

  void popFrameBuffer() {
    if (_renderFrameBuffers.length > 0) {
      _renderFrameBuffers.removeLast();
    }
    if (_renderFrameBuffers.length > 0) {
      RenderFrameBuffer renderFrameBuffer = _renderFrameBuffers.last;
      _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, renderFrameBuffer.framebuffer);
      _renderingContext.viewport(0, 0, renderFrameBuffer.width, renderFrameBuffer.height);
    } else {
      int width = _renderingContext.drawingBufferWidth;
      int height = _renderingContext.drawingBufferHeight;
      _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
      _renderingContext.viewport(0, 0, width, height);
    }
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