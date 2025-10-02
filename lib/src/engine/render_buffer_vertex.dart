part of '../engine.dart';

class RenderBufferVertex {
  final Float32List data;
  final int usage;

  int position = 0; // position in data list
  int count = 0; // count of vertices

  int _contextIdentifier = -1;
  web.WebGLBuffer? _buffer;
  web.WebGLRenderingContext? _renderingContext;
  late RenderStatistics _renderStatistics;

  //---------------------------------------------------------------------------

  RenderBufferVertex(int length)
      : data = Float32List(length),
        usage = web.WebGLRenderingContext.DYNAMIC_DRAW;

  //---------------------------------------------------------------------------

  int get contextIdentifier => _contextIdentifier;

  void dispose() {
    if (_buffer != null && _renderingContext != null) {
      _renderingContext!.deleteBuffer(_buffer);
      _renderingContext = null;
      _buffer = null;
      _contextIdentifier = -1;
    }
  }

  void activate(RenderContextWebGL renderContext) {
    if (_contextIdentifier != renderContext.contextIdentifier) {
      _contextIdentifier = renderContext.contextIdentifier;
      _renderStatistics = renderContext.renderStatistics;
      _renderingContext = renderContext.rawContext;
      _buffer = _renderingContext!.createBuffer();
      _renderingContext!
          .bindBuffer(web.WebGLRenderingContext.ARRAY_BUFFER, _buffer);
      _renderingContext!
          .bufferData(web.WebGLRenderingContext.ARRAY_BUFFER, data.toJS, usage);
    }

    _renderingContext!
        .bindBuffer(web.WebGLRenderingContext.ARRAY_BUFFER, _buffer);
  }

  void update() {
    final update = Float32List.view(data.buffer, 0, position);
    _renderingContext!
        .bufferSubData(web.WebGLRenderingContext.ARRAY_BUFFER, 0, update.toJS);
    _renderStatistics.vertexCount += count;
  }

  void bindAttribute(int? index, int size, int stride, int offset) {
    if (index == null) return;
    _renderingContext!.vertexAttribPointer(
        index, size, web.WebGLRenderingContext.FLOAT, false, stride, offset);
  }
}
