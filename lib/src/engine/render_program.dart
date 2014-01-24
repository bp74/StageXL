part of stagexl;

abstract class RenderProgram {

  RenderContextWebGL _renderContext;
  gl.Program _program;

  RenderProgram(RenderContextWebGL renderContext) : _renderContext = renderContext;

  //-----------------------------------------------------------------------------------------------

  gl.Program get program => _program;

  void activate();
  void flush();

  //-----------------------------------------------------------------------------------------------

  gl.Shader _createShader(String source, int shaderType) {

    var renderingContext = _renderContext.rawContext;
    var shader = renderingContext.createShader(shaderType);

    renderingContext.shaderSource(shader, source);
    renderingContext.compileShader(shader);

    var vertexShaderStatus = renderingContext.getShaderParameter(shader, gl.COMPILE_STATUS);
    var isContextLost = renderingContext.isContextLost();
    if (vertexShaderStatus == false && isContextLost == false) {
      throw renderingContext.getShaderInfoLog(shader);
    }

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
    var isContextLost = renderingContext.isContextLost();
    if (programStatus == false && isContextLost == false) {
      throw renderingContext.getProgramInfoLog(program);
    }

    return program;
  }
}
