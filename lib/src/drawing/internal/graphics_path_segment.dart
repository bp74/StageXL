part of stagexl.drawing.internal;

class GraphicsPathSegment {

  // TODO: Cache the segments to make it fast.

  Float32List _vertexBuffer = new Float32List(16);
  Int16List _indexBuffer = null;
  int _vertexCount = 0;

  int get vertexCount => _vertexCount;
  double get lastVertexX =>  _vertexBuffer[(_vertexCount - 1) * 2 + 0];
  double get lastVertexY =>  _vertexBuffer[(_vertexCount - 1) * 2 + 1];

  //---------------------------------------------------------------------------

  void addVertex(double x, double y) {

    var length = _vertexBuffer.length;
    var offset = _vertexCount * 2;

    if (offset + 2 > length) {
      var oldBuffer = _vertexBuffer;
      _vertexBuffer = new Float32List(length + minInt(length, 256));
      _vertexBuffer.setAll(0, oldBuffer);
    }

    _vertexBuffer[offset + 0] = x;
    _vertexBuffer[offset + 1] = y;
    _vertexCount += 1;
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {

    if (_vertexCount < 3) return;
    if (_indexBuffer == null) _triangulateVertexBuffer();

    // TODO: optimize for WebGL RenderProgramTriangle

    for(int i = 0; i < _indexBuffer.length - 2; i += 3) {
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

  void _triangulateVertexBuffer() {

    // TODO: benchmark more triangulation methods
    // http://erich.realtimerendering.com/ptinpoly/

    var result = new List<int>();
    var available = new List<int>();
    var clockwise = _checkClockwise();
    var index = 0;

    for(int p = 0; p < _vertexCount; p++) {
      available.add(p);
    }

    while (available.length > 3) {

      int i0 = available[(index + 0) % available.length];
      int i1 = available[(index + 1) % available.length];
      int i2 = available[(index + 2) % available.length];

      num x1 = _vertexBuffer[i0 * 2 + 0];
      num y1 = _vertexBuffer[i0 * 2 + 1];
      num x2 = _vertexBuffer[i1 * 2 + 0];
      num y2 = _vertexBuffer[i1 * 2 + 1];
      num x3 = _vertexBuffer[i2 * 2 + 0];
      num y3 = _vertexBuffer[i2 * 2 + 1];

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

          num x01 = _vertexBuffer[vi * 2 + 0] - x1;
          num y01 = _vertexBuffer[vi * 2 + 1] - y1;

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
        result.add(i0);
        result.add(i1);
        result.add(i2);
        available.removeAt((index + 1) % available.length);
        index = 0;
      } else if (index++ > 3 * available.length) {
        break; // no convex angles :(
      }
    }

    result.add(available[0]);
    result.add(available[1]);
    result.add(available[2]);

    _indexBuffer = new Int16List.fromList(result);
  }

  num _getArea() {
    num value = 0.0;
    for(int i = 0; i < _vertexCount; i++) {
      int j = (i + 1) % _vertexCount;
      num x1 = _vertexBuffer[i * 2 + 0];
      num y1 = _vertexBuffer[i * 2 + 1];
      num x2 = _vertexBuffer[j * 2 + 0];
      num y2 = _vertexBuffer[j * 2 + 1];
      value -= (x2 - x1) * (y2 + y1);
    }
    return value / 2.0;
  }

  bool _checkClockwise() {
    return _getArea() > 0.0;
  }

}
