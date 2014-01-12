part of stagexl;

// TODO: Fix alpha issues (http://greggman.github.io/webgl-fundamentals/webgl/lessons/webgl-and-alpha.html)
// TODO: Handle WebGL context lost.
// TODO: Collect WebGL texture memory with reference counter?

class RenderContextWebGL extends RenderContext {

  final CanvasElement _canvasElement;
  final int _backgroundColor;

  gl.RenderingContext _renderingContext;
  RenderTexture _renderTexture;
  RenderProgram _renderProgram;
  RenderProgram _renderProgramDefault;
  RenderProgram _renderProgramPrimitive;
  int _maskDepth = 0;

  RenderContextWebGL(CanvasElement canvasElement, int backgroundColor) :
    _canvasElement = canvasElement,
    _backgroundColor = _ensureInt(backgroundColor) {

    _canvasElement.onWebGlContextLost.listen((e) => "ToDo: Handle WebGL context lost.");
    _canvasElement.onWebGlContextRestored.listen((e) => "ToDo: Handle WebGL context restored.");

    var renderingContext = _canvasElement.getContext3d(
        alpha: false, depth: false, stencil: true, antialias: false,
        premultipliedAlpha: false, preserveDrawingBuffer: false);

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

    _renderTexture = null;
    _renderProgram = null;
    _renderProgramDefault = new RenderProgramDefault(this);
    _renderProgramPrimitive = new RenderProgramPrimitive(this);

    _activateRenderProgram(_renderProgramDefault);
  }

  //-----------------------------------------------------------------------------------------------

  String get renderEngine => RenderEngine.Canvas2D;

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
  }

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha) {

    _checkState(renderTextureQuad.renderTexture);
    _renderProgram.renderQuad(renderTextureQuad, matrix, alpha);
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {
    _renderProgram.renderTriangle(x1, y1, x2, y2, x3, y3, matrix, color);
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

    _activateRenderProgram(_renderProgramPrimitive);
    _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);
    _renderingContext.stencilMask(0xFF);
    _renderingContext.colorMask(false, false, false, false);
    _maskDepth += 1;

    mask._drawTriangles(this, matrix);

    _activateRenderProgram(_renderProgramDefault);
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

      _activateRenderProgram(_renderProgramPrimitive);
      _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
      _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.DECR);
      _renderingContext.stencilMask(0xFF);
      _renderingContext.colorMask(false, false, false, false);
      _maskDepth -= 1;

      var matrix = _identityMatrix;
      var color = Color.Magenta;

      _renderProgram.renderTriangle(-1, -1, 1, -1, 1, 1, matrix, color);
      _renderProgram.renderTriangle(-1, -1, 1, 1, -1, 1, matrix, color);

      _activateRenderProgram(_renderProgramDefault);
      _renderingContext.stencilFunc(gl.EQUAL, _maskDepth, 0xFF);
      _renderingContext.stencilMask(0x00);
      _renderingContext.colorMask(true, true, true, true);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix) {

  }

  void endRenderShadow(Shadow shadow) {

  }

  //-----------------------------------------------------------------------------------------------

  _checkState(RenderTexture renderTexture) {

    if (identical(renderTexture, _renderTexture) == false) {
      _renderProgram.flush();
      var texture = renderTexture.getTexture(this);
      _renderingContext.activeTexture(gl.TEXTURE0);
      _renderingContext.bindTexture(gl.TEXTURE_2D, texture);
      _renderTexture = renderTexture;
    }
  }

  _activateRenderProgram(RenderProgram renderProgram) {
    if (_renderProgram != null) {
      _renderProgram.flush();
    }
    _renderProgram = renderProgram;
    _renderProgram.activate();
  }

}