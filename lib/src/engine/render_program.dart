part of stagexl;

abstract class RenderProgram {

  RenderProgram();

  void activate(RenderContextWebGL renderContext);
  void flush();

  //-----------------------------------------------------------------------------------------------

  gl.Shader _createShader(gl.RenderingContext renderingContext, String source, int shaderType) {

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

  gl.Program createProgram(gl.RenderingContext renderingContext,
                           String vertexShaderSource, String fragmentShaderSource) {

    var program = renderingContext.createProgram();
    var vertexShader = _createShader(renderingContext, vertexShaderSource, gl.VERTEX_SHADER);
    var fragmentShader = _createShader(renderingContext, fragmentShaderSource, gl.FRAGMENT_SHADER);

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
