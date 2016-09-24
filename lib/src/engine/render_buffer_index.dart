part of stagexl.engine;

class RenderBufferIndex {

  final Int16List data;
  final int usage;

  int position = 0;   // position in data list
  int count = 0;      // count of indices

  int _contextIdentifier = -1;
  gl.Buffer _buffer;
  gl.RenderingContext _renderingContext;
  RenderStatistics _renderStatistics;

  //---------------------------------------------------------------------------

  RenderBufferIndex(int length) :
    data = new Int16List(length),
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
      _renderStatistics = renderContext.renderStatistics;
      _renderingContext = renderContext.rawContext;
      _buffer = _renderingContext.createBuffer();
      _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _buffer);
      _renderingContext.bufferData(gl.ELEMENT_ARRAY_BUFFER, data, usage);
    }

    _renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _buffer);
  }

  void update() {
    var update = new Int16List.view(data.buffer, 0, this.position);
    _renderingContext.bufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, update);
    _renderStatistics.indexCount += this.count;
  }

}
