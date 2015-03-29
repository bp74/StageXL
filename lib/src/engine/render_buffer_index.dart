part of stagexl.engine;

class RenderBufferIndex {

  final Int16List data;
  final int usage;

  int _contextIdentifier = -1;
  gl.Buffer _buffer = null;
  gl.RenderingContext _renderingContext = null;

  //---------------------------------------------------------------------------

  RenderBufferIndex.forTriangles(int triangles) :
    data = new Int16List(triangles * 3),
    usage = gl.DYNAMIC_DRAW;

  RenderBufferIndex.forQuads(int quads) :
    data = new Int16List(quads * 6),
    usage = gl.STATIC_DRAW {
    for(int i = 0, j = 0; i <= data.length - 6; i += 6, j +=4 ) {
      data[i + 0] = j + 0;
      data[i + 1] = j + 1;
      data[i + 2] = j + 2;
      data[i + 3] = j + 0;
      data[i + 4] = j + 2;
      data[i + 5] = j + 3;
    }
  }

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