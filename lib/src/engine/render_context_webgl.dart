part of stagexl;

// TODO: Fix alpha issues (http://greggman.github.io/webgl-fundamentals/webgl/lessons/webgl-and-alpha.html)
// TODO: Handle WebGL context lost.
// TODO: Collect WebGL texture memory with reference counter?

class RenderContextWebGL extends RenderContext {

  CanvasElement _canvasElement;
  gl.RenderingContext _renderingContext;
  RenderProgram _renderProgram;
  RenderTexture _renderTexture;

  RenderContextWebGL(CanvasElement canvasElement) : _canvasElement = canvasElement {

    _canvasElement.onWebGlContextLost.listen((e) => "ToDo: Handle WebGL context lost.");
    _canvasElement.onWebGlContextRestored.listen((e) => "ToDo: Handle WebGL context restored.");

    var renderingContext = _canvasElement.getContext3d(
        alpha: false, depth: false, stencil: true, antialias: true,
        premultipliedAlpha: false, preserveDrawingBuffer: false);

    if (renderingContext is! gl.RenderingContext) {
      throw new StateError("Failed to get WebGL context.");
    }

    _renderingContext = renderingContext;
    _renderingContext.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    _renderingContext.enable(gl.BLEND);
    _renderingContext.enable(gl.STENCIL_TEST);
    _renderingContext.disable(gl.DEPTH_TEST);

    _renderProgram = new DefaultRenderProgram(this);
    _renderTexture = null;

    _renderingContext.useProgram(_renderProgram.program);
    _updateViewPort();
  }

  //-----------------------------------------------------------------------------------------------

  gl.RenderingContext get rawContext => _renderingContext;

  //-----------------------------------------------------------------------------------------------

  void clear() {
    _renderingContext.clearColor(1.0, 1.0, 1.0, 0.0);
    _renderingContext.clear(gl.COLOR_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
  }

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    var renderTexture = renderTextureQuad.renderTexture;

    if (identical(renderTexture, _renderTexture) == false) {
      var texture =  renderTexture.getTexture(this);
      _renderProgram.flush();
      _renderingContext.activeTexture(gl.TEXTURE0);
      _renderingContext.bindTexture(gl.TEXTURE_2D, texture);
      _renderTexture = renderTexture;
    }

    _renderProgram.renderQuad(renderState, renderTextureQuad);
  }

  void flush() {
    _renderProgram.flush();
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix) {

  }

  void endRenderMask(Mask mask) {

  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix) {

  }

  void endRenderShadow(Shadow shadow) {

  }

  //-----------------------------------------------------------------------------------------------

  _updateViewPort() {

    var width = _renderingContext.drawingBufferWidth;
    var height = _renderingContext.drawingBufferHeight;

    _renderingContext.viewport(0, 0, width, height);

    var program = _renderProgram.program;
    var viewTransformLocation = _renderingContext.getUniformLocation(program, "uViewMatrix");

    if (viewTransformLocation != null) {

      var viewMatrixList = new Float32List(9);
      viewMatrixList[0] = 2.0 / width;
      viewMatrixList[1] = 0.0;
      viewMatrixList[2] = 0.0;
      viewMatrixList[3] = 0.0;
      viewMatrixList[4] = - 2.0 / height;
      viewMatrixList[5] = 0.0;
      viewMatrixList[6] = -1.0;
      viewMatrixList[7] = 1.0;
      viewMatrixList[8] = 1.0;

      _renderingContext.uniformMatrix3fv(viewTransformLocation, false, viewMatrixList);
    }
  }


}