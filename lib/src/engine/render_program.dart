part of stagexl.engine;

abstract class RenderProgram {
  int _contextIdentifier = -1;
  gl.RenderingContext? _renderingContext;
  gl.Program? _program;

  final Map<String, int> _attributes;
  final Map<String, gl.UniformLocation> _uniforms;
  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  RenderStatistics _renderStatistics;

  RenderProgram()
      : _attributes = <String, int>{},
        _uniforms = <String, gl.UniformLocation>{},
        _renderBufferIndex = RenderBufferIndex(0),
        _renderBufferVertex = RenderBufferVertex(0),
        _renderStatistics = RenderStatistics();

  //---------------------------------------------------------------------------

  String get vertexShaderSource;
  String get fragmentShaderSource;

  int get contextIdentifier => _contextIdentifier;
  RenderBufferIndex get renderBufferIndex => _renderBufferIndex;
  RenderBufferVertex get renderBufferVertex => _renderBufferVertex;
  RenderStatistics get renderStatistics => _renderStatistics;
  gl.RenderingContext? get renderingContext => _renderingContext;
  gl.Program? get program => _program;

  Map<String, int> get attributes => _attributes;
  Map<String, gl.UniformLocation> get uniforms => _uniforms;

  //---------------------------------------------------------------------------

  set projectionMatrix(Matrix3D matrix) {
    var location = uniforms['uProjectionMatrix'];
    renderingContext!.uniformMatrix4fv(location, false, matrix.data);
  }

  //---------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {
    if (contextIdentifier != renderContext.contextIdentifier) {
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _renderStatistics = renderContext.renderStatistics;
      _renderBufferIndex = renderContext.renderBufferIndex;
      _renderBufferVertex = renderContext.renderBufferVertex;
      _renderBufferIndex.activate(renderContext);
      _renderBufferVertex.activate(renderContext);
      _program = _createProgram(_renderingContext!);
      _updateAttributes(_renderingContext!, _program!);
      _updateUniforms(_renderingContext!, _program!);
    }

    renderingContext!.useProgram(program);
  }

  //---------------------------------------------------------------------------

  void flush() {
    if (renderBufferIndex.position > 0 && renderBufferVertex.position > 0) {
      var count = renderBufferIndex.position;
      renderBufferIndex.update();
      renderBufferIndex.position = 0;
      renderBufferIndex.count = 0;
      renderBufferVertex.update();
      renderBufferVertex.position = 0;
      renderBufferVertex.count = 0;
      renderingContext!.drawElements(
          gl.WebGL.TRIANGLES, count, gl.WebGL.UNSIGNED_SHORT, 0);
      renderStatistics.drawCount += 1;
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  gl.Program _createProgram(gl.RenderingContext rc) {
    var program = rc.createProgram();
    var vShader = _createShader(rc, vertexShaderSource, gl.WebGL.VERTEX_SHADER);
    var fShader =
        _createShader(rc, fragmentShaderSource, gl.WebGL.FRAGMENT_SHADER);

    rc.attachShader(program, vShader);
    rc.attachShader(program, fShader);
    rc.linkProgram(program);

    var status = rc.getProgramParameter(program, gl.WebGL.LINK_STATUS);
    if (status == true) return program;

    var cl = rc.isContextLost();
    throw StateError(cl ? 'ContextLost' : rc.getProgramInfoLog(program)!);
  }

  //---------------------------------------------------------------------------

  gl.Shader _createShader(gl.RenderingContext rc, String source, int type) {
    var shader = rc.createShader(type);
    rc.shaderSource(shader, source);
    rc.compileShader(shader);

    var status = rc.getShaderParameter(shader, gl.WebGL.COMPILE_STATUS);
    if (status == true) return shader;

    var cl = rc.isContextLost();
    throw StateError(cl ? 'ContextLost' : rc.getShaderInfoLog(shader)!);
  }

  //---------------------------------------------------------------------------

  void _updateAttributes(gl.RenderingContext rc, gl.Program program) {
    _attributes.clear();
    var count = rc.getProgramParameter(program, gl.WebGL.ACTIVE_ATTRIBUTES) as int;

    for (var i = 0; i < count; i++) {
      var activeInfo = rc.getActiveAttrib(program, i);
      var location = rc.getAttribLocation(program, activeInfo.name);
      rc.enableVertexAttribArray(location);
      _attributes[activeInfo.name] = location;
    }
  }

  //---------------------------------------------------------------------------

  void _updateUniforms(gl.RenderingContext rc, gl.Program program) {
    _uniforms.clear();
    var count = rc.getProgramParameter(program, gl.WebGL.ACTIVE_UNIFORMS) as int;

    for (var i = 0; i < count; i++) {
      var activeInfo = rc.getActiveUniform(program, i);
      var location = rc.getUniformLocation(program, activeInfo.name);
      _uniforms[activeInfo.name] = location;
    }
  }
}
