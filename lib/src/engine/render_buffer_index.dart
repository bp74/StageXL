part of stagexl.engine;

class RenderBufferIndex {

  final Int16List data;
  final int usage;

  int _contextIdentifier = -1;
  gl.Buffer _buffer = null;
  gl.RenderingContext _renderingContext = null;

  //---------------------------------------------------------------------------

  RenderBufferIndex(int length) :
    data = new Int16List(length * 3),
    usage = gl.DYNAMIC_DRAW;

  //---------------------------------------------------------------------------

  int get contextIdentifier => _contextIdentifier;

  void dispose() {
    if (this._buffer != null && _renderingContext != null) {
      _renderingContext.deleteBuffer(_buffer);
      _renderingContext = null;
      _buffer = null;
      _contextIdentifier = -1;
    }
  }

  void activate(RenderContextWebGL renderContext) {

    if (_contextIdentifier != renderContext.contextIdentifier) {
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _buffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _buffer);
      _renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, data, usage);
    }

    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _buffer);
  }

  void update(int offset, int length) {
    var indexUpdate = new Int16List.view(data.buffer, offset, length);
    _renderingContext.bufferSubDataTyped(gl.ELEMENT_ARRAY_BUFFER, 0, indexUpdate);
  }
}
