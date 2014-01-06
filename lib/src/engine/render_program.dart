part of stagexl;

abstract class RenderProgram {

  RenderContextWebGL _renderContext;
  gl.Program _program;

  //-----------------------------------------------------------------------------------------------

  gl.Program get program => _program;

  void activate();
  void flush();

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha);
  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color);

  //-----------------------------------------------------------------------------------------------

  gl.Shader _createShader(String source, int shaderType) {

    var renderingContext = _renderContext.rawContext;
    var shader = renderingContext.createShader(shaderType);

    renderingContext.shaderSource(shader, source);
    renderingContext.compileShader(shader);

    var vertexShaderStatus = renderingContext.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (vertexShaderStatus == false) throw renderingContext.getShaderInfoLog(shader);

    return shader;
  }

  //-----------------------------------------------------------------------------------------------

  gl.Program _createProgram(gl.Shader vertexShader, gl.Shader fragmentShader) {

    var renderingContext = _renderContext.rawContext;
    var program = renderingContext.createProgram();

    renderingContext.attachShader(program, vertexShader);
    renderingContext.attachShader(program, fragmentShader);
    renderingContext.linkProgram(program);

    var programStatus = renderingContext.getProgramParameter(program, gl.LINK_STATUS);
    if (programStatus == false) throw renderingContext.getProgramInfoLog(program);

    return program;
  }

  //-----------------------------------------------------------------------------------------------

  updateViewPort(int width, int height) {

    var renderingContext = _renderContext.rawContext;
    var viewTransformLocation = renderingContext.getUniformLocation(program, "uViewMatrix");

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

    if (viewTransformLocation != null) {
      renderingContext.uniformMatrix3fv(viewTransformLocation, false, viewMatrixList);
    }
  }
}
