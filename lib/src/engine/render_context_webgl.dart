part of stagexl;

class RenderContextWebGL extends RenderContext {

  final CanvasElement _canvasElement;
  final int _backgroundColor;

  gl.RenderingContext _renderingContext;
  RenderTexture _renderTexture;
  RenderProgram _renderProgram;
  RenderProgramQuad _renderProgramQuad;
  RenderProgramTriangle _renderProgramTriangle;
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

    _renderProgramQuad = new RenderProgramQuad(this);
    _renderProgramTriangle = new RenderProgramTriangle(this);
    _renderProgram = _renderProgramQuad;
    _renderProgram.activate();
  }

  //-----------------------------------------------------------------------------------------------

  String get renderEngine => RenderEngine.WebGL;

  gl.RenderingContext get rawContext => _renderingContext;

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

    _renderProgram = _renderProgramQuad;
    _renderProgram.activate();
  }

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha) {
    _updateState(_renderProgramQuad, renderTextureQuad.renderTexture);
    _renderProgramQuad.renderQuad(renderTextureQuad, matrix, alpha);
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {
    _updateState(_renderProgramTriangle, _renderTexture);
    _renderProgramTriangle.renderTriangle(x1, y1, x2, y2, x3, y3, matrix, color);
  }

  void flush() {
    _renderProgram.flush();
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix) {

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

    mask._drawTriangles(this, matrix);

    _updateState(_renderProgramQuad, null);
    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilMask(0x00);
    _renderingContext.colorMask(true, true, true, true);
  }

  void endRenderMask(Mask mask) {

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

      var matrix = _identityMatrix;
      var color = Color.Magenta;

      _renderProgramTriangle.renderTriangle(-1, -1, 1, -1, 1, 1, matrix, color);
      _renderProgramTriangle.renderTriangle(-1, -1, 1, 1, -1, 1, matrix, color);

      _updateState(_renderProgramQuad, null);
      _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
      _renderingContext.stencilMask(0x00);
      _renderingContext.colorMask(true, true, true, true);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix) {
    // TODO: We will add this once we have WebGL filters.
  }

  void endRenderShadow(Shadow shadow) {

  }

  //-----------------------------------------------------------------------------------------------

  _updateState(RenderProgram renderProgram, RenderTexture renderTexture) {

    if (renderProgram != null) {
      if (identical(renderProgram, _renderProgram) == false) {
        _renderProgram.flush();
        _renderProgram = renderProgram;
        _renderProgram.activate();
      }
    }

    if (renderTexture != null) {
      if (identical(renderTexture, _renderTexture) == false) {
        _renderProgram.flush();
        var texture = renderTexture._getTexture(this);
        _renderingContext.activeTexture(gl.TEXTURE0);
        _renderingContext.bindTexture(gl.TEXTURE_2D, texture);
        _renderTexture = renderTexture;
      }
    }
  }

  _onContextLost(gl.ContextEvent contextEvent) {
    contextEvent.preventDefault();
    this.dispatchEvent(new Event("contextLost"));
  }

  _onContextRestored(gl.ContextEvent contextEvent) {
    this.dispatchEvent(new Event("contextRestored"));
  }

}