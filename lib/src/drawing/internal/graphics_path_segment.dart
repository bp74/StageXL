part of stagexl.drawing.internal;

class GraphicsPathSegment {

  Float32List _vertexBuffer = new Float32List(16);
  Int16List _indexBuffer = new Int16List(32);

  int _vertexCount = 0;
  int _indexCount = 0;
  bool _clockwise = true;
  num _area = 0.0;

  //---------------------------------------------------------------------------

  int get vertexCount => _vertexCount;
  double get lastVertexX => _vertexBuffer[(_vertexCount - 1) * 2 + 0];
  double get lastVertexY => _vertexBuffer[(_vertexCount - 1) * 2 + 1];
  double get firstVertexX => _vertexBuffer[0];
  double get firstVertexY => _vertexBuffer[1];

  //---------------------------------------------------------------------------

  GraphicsPathSegment clone() {
    // TODO: implement GraphicsPathSegment clone
    return null;
  }

  //---------------------------------------------------------------------------

  void reset() {
    _vertexCount = 0;
    _indexCount = 0;
    _clockwise = true;
    _area = 0.0;
  }

  //---------------------------------------------------------------------------

  void addVertex(double x, double y) {

    var offset = _vertexCount * 2;
    var length = _vertexBuffer.length;
    var buffer = _vertexBuffer;

    if (offset + 2 > length) {
      _vertexBuffer = new Float32List(length + minInt(length, 256));
      _vertexBuffer.setAll(0, buffer);
    }

    _vertexBuffer[offset + 0] = x;
    _vertexBuffer[offset + 1] = y;
    _vertexCount += 1;
  }

  //---------------------------------------------------------------------------

  void addIndex(int index) {

    var offset = _indexCount;
    var length = _indexBuffer.length;
    var buffer = _indexBuffer;

    if (offset + 1 > length) {
      _indexBuffer = new Int16List(length + minInt(length, 256));
      _indexBuffer.setAll(0, buffer);
    }

    _indexBuffer[offset] = index;
    _indexCount++;
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {

    _compute();

    // TODO: optimize for WebGL RenderProgramTriangle

    for(int i = 0; i < _indexCount - 2; i += 3) {
      int i0 = _indexBuffer[i + 0];
      int i1 = _indexBuffer[i + 1];
      int i2 = _indexBuffer[i + 2];
      num ax = _vertexBuffer[i0 * 2 + 0];
      num ay = _vertexBuffer[i0 * 2 + 1];
      num bx = _vertexBuffer[i1 * 2 + 0];
      num by = _vertexBuffer[i1 * 2 + 1];
      num cx = _vertexBuffer[i2 * 2 + 0];
      num cy = _vertexBuffer[i2 * 2 + 1];
      var renderContext = renderState.renderContext;
      renderContext.renderTriangle(renderState, ax, ay, bx, by, cx, cy, color);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _compute() {
    if (_vertexCount < 3) {
      _area = 0.0;
      _clockwise = true;
      _indexCount = 0;
    } else {
      _calculateArea(_vertexBuffer, _vertexCount);
      _clockwise = _area >= 0.0;
      _indexCount = 0;
      _calculateIndices(_vertexBuffer, _vertexCount, _clockwise);
    }
  }

  //---------------------------------------------------------------------------

  void _calculateIndices(Float32List buffer, int count, bool clockwise) {

    // TODO: benchmark more triangulation methods
    // http://erich.realtimerendering.com/ptinpoly/

    var result = new List<int>();
    var available = new List<int>();
    var index = 0;

    for(int p = 0; p < count; p++) {
      available.add(p);
    }

    while (available.length > 3) {

      int i0 = available[(index + 0) % available.length];
      int i1 = available[(index + 1) % available.length];
      int i2 = available[(index + 2) % available.length];

      num x1 = buffer[i0 * 2 + 0];
      num y1 = buffer[i0 * 2 + 1];
      num x2 = buffer[i1 * 2 + 0];
      num y2 = buffer[i1 * 2 + 1];
      num x3 = buffer[i2 * 2 + 0];
      num y3 = buffer[i2 * 2 + 1];

      num x31 = x3 - x1;
      num y31 = y3 - y1;
      num x21 = x2 - x1;
      num y21 = y2 - y1;
      num d = y21 * x31 - x21 * y31;
      bool earFound = false;

      if ((d == 0) || (d < 0) == clockwise) {

        earFound = true;

        for(int j = 0; j < available.length; j++) {

          int vi = available[j];
          if(vi == i0 || vi == i1 || vi == i2) continue;

          num x01 = buffer[vi * 2 + 0] - x1;
          num y01 = buffer[vi * 2 + 1] - y1;

          num dot00 = x31 * x31 + y31 * y31;
          num dot01 = x31 * x21 + y31 * y21;
          num dot02 = x31 * x01 + y31 * y01;
          num dot11 = x21 * x21 + y21 * y21;
          num dot12 = x21 * x01 + y21 * y01;

          num invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
          num u = (dot11 * dot02 - dot01 * dot12) * invDenom;
          num v = (dot00 * dot12 - dot01 * dot02) * invDenom;

          if((u >= 0) && (v >= 0) && (u + v < 1)) {
            earFound = false;
            break;
          }
        }
      }

      if(earFound) {
        addIndex(i0);
        addIndex(i1);
        addIndex(i2);
        available.removeAt((index + 1) % available.length);
        index = 0;
      } else if (index++ > 3 * available.length) {
        break; // no convex angles :(
      }
    }

    addIndex(available[0]);
    addIndex(available[1]);
    addIndex(available[2]);
  }

  //---------------------------------------------------------------------------

  void _calculateArea(Float32List buffer, int count) {

    num value = 0.0;
    num x1 = buffer[(count - 1) * 2 + 0];
    num y1 = buffer[(count - 1) * 2 + 1];

    for(int i = 0; i < count; i++) {
      num x2 = buffer[i * 2 + 0];
      num y2 = buffer[i * 2 + 1];
      value += (x1 - x2) * (y1 + y2);
      x1 = x2;
      y1 = y2;
    }

    _area = value / 2.0;
  }

}
