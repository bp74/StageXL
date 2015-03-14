part of stagexl.engine;

abstract class RenderProgram {

  int _contextIdentifier = -1;
  gl.RenderingContext _renderingContext = null;
  gl.Program _program = null;

  final Map<String, int> _attributes = new Map<String, int>();
  final Map<String, gl.UniformLocation> _uniforms = new Map<String, gl.UniformLocation>();

  //-----------------------------------------------------------------------------------------------

  String get vertexShaderSource;
  String get fragmentShaderSource;

  int get contextIdentifier => _contextIdentifier;
  gl.RenderingContext get renderingContext => _renderingContext;
  gl.Program get program => _program;
  Map<String, int> get attributes => _attributes;
  Map<String, gl.UniformLocation> get uniforms => _uniforms;

  //-----------------------------------------------------------------------------------------------

  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(uniforms["uProjectionMatrix"], false, matrix.data);
  }

  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _program = renderingContext.createProgram();
      _attributes.clear();
      _uniforms.clear();

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

      int activeAttributes = renderingContext.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
      int activeUniforms = renderingContext.getProgramParameter(program, gl.ACTIVE_UNIFORMS);

      for(int index = 0; index < activeAttributes; index++) {
        var activeInfo = renderingContext.getActiveAttrib(program, index);
        var location = renderingContext.getAttribLocation(program, activeInfo.name);
        renderingContext.enableVertexAttribArray(location);
        _attributes[activeInfo.name] = location;
      }

      for(int index = 0; index < activeUniforms; index++) {
        var activeInfo = renderingContext.getActiveUniform(program, index);
        var location = renderingContext.getUniformLocation(program, activeInfo.name);
        _uniforms[activeInfo.name] = location;
      }
    }

    renderingContext.useProgram(program);
  }

  void flush() {

  }

  //-----------------------------------------------------------------------------------------------

  gl.Shader _createShader(gl.RenderingContext renderingContext, String source, int shaderType) {

    var shader = renderingContext.createShader(shaderType);

    renderingContext.shaderSource(shader, source);
    renderingContext.compileShader(shader);

    var shaderStatus = renderingContext.getShaderParameter(shader, gl.COMPILE_STATUS);
    var isContextLost = renderingContext.isContextLost();
    if (shaderStatus == false && isContextLost == false) {
      throw renderingContext.getShaderInfoLog(shader);
    }

    return shader;
  }
}
