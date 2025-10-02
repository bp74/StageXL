part of '../engine.dart';

abstract class RenderProgram {
  int _contextIdentifier = -1;

  // These assume activate() is called
  late web.WebGLRenderingContext _renderingContext;
  late web.WebGLProgram _program;

  final Map<String, int> _attributes;
  final Map<String, web.WebGLUniformLocation> _uniforms;
  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  RenderStatistics _renderStatistics;

  RenderProgram()
      : _attributes = <String, int>{},
        _uniforms = <String, web.WebGLUniformLocation>{},
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
  web.WebGLRenderingContext get renderingContext => _renderingContext;
  web.WebGLProgram get program => _program;

  Map<String, int> get attributes => _attributes;
  Map<String, web.WebGLUniformLocation> get uniforms => _uniforms;

  //---------------------------------------------------------------------------

  set projectionMatrix(Matrix3D matrix) {
    final location = uniforms['uProjectionMatrix'];
    renderingContext.uniformMatrix4fv(location, false, matrix.data.toJS);
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
      _program = _createProgram(_renderingContext);
      _updateAttributes(_renderingContext, _program);
      _updateUniforms(_renderingContext, _program);
    }

    renderingContext.useProgram(program);
  }

  //---------------------------------------------------------------------------

  void flush() {
    if (renderBufferIndex.position > 0 && renderBufferVertex.position > 0) {
      final count = renderBufferIndex.position;
      renderBufferIndex.update();
      renderBufferIndex.position = 0;
      renderBufferIndex.count = 0;
      renderBufferVertex.update();
      renderBufferVertex.position = 0;
      renderBufferVertex.count = 0;
      renderingContext.drawElements(web.WebGLRenderingContext.TRIANGLES, count,
          web.WebGLRenderingContext.UNSIGNED_SHORT, 0);
      renderStatistics.drawCount += 1;
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  web.WebGLProgram _createProgram(web.WebGLRenderingContext rc) {
    final program = rc.createProgram();
    final vShader = _createShader(
        rc, vertexShaderSource, web.WebGLRenderingContext.VERTEX_SHADER);
    final fShader = _createShader(
        rc, fragmentShaderSource, web.WebGLRenderingContext.FRAGMENT_SHADER);

    rc.attachShader(program!, vShader);
    rc.attachShader(program, fShader);
    rc.linkProgram(program);

    final status =
        rc.getProgramParameter(program, web.WebGLRenderingContext.LINK_STATUS);
    if (identical(status, true)) return program;

    final cl = rc.isContextLost();
    throw StateError(cl ? 'ContextLost' : rc.getProgramInfoLog(program)!);
  }

  //---------------------------------------------------------------------------

  web.WebGLShader _createShader(
      web.WebGLRenderingContext rc, String source, int type) {
    final shader = rc.createShader(type);
    if (shader == null) {
      throw StateError('Failed to create shader');
    }
    rc.shaderSource(shader, source);
    rc.compileShader(shader);

    final status =
        rc.getShaderParameter(shader, web.WebGLRenderingContext.COMPILE_STATUS);
    if (identical(status, true)) return shader;

    final cl = rc.isContextLost();
    throw StateError(cl ? 'ContextLost' : rc.getShaderInfoLog(shader)!);
  }

  //---------------------------------------------------------------------------

  void _updateAttributes(
      web.WebGLRenderingContext rc, web.WebGLProgram program) {
    _attributes.clear();
    final count = rc.getProgramParameter(
        program, web.WebGLRenderingContext.ACTIVE_ATTRIBUTES) as int;

    for (var i = 0; i < count; i++) {
      final activeInfo = rc.getActiveAttrib(program, i);
      if (activeInfo == null) {
        throw StateError('Failed to get WebGLActiveInfo');
      }
      final location = rc.getAttribLocation(program, activeInfo.name);
      rc.enableVertexAttribArray(location);
      _attributes[activeInfo.name] = location;
    }
  }

  //---------------------------------------------------------------------------

  void _updateUniforms(web.WebGLRenderingContext rc, web.WebGLProgram program) {
    _uniforms.clear();
    final count = rc.getProgramParameter(
        program, web.WebGLRenderingContext.ACTIVE_UNIFORMS) as int;

    for (var i = 0; i < count; i++) {
      final activeInfo = rc.getActiveUniform(program, i);
      if (activeInfo == null) {
        throw StateError('Failed to get WebGLActiveInfo');
      }
      final location = rc.getUniformLocation(program, activeInfo.name);
      if (location == null) {
        throw StateError(
            'Failed to get UniformLocation for ${activeInfo.name}');
      }
      _uniforms[activeInfo.name] = location;
    }
  }
}
