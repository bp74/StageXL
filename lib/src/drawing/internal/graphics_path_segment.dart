part of stagexl.drawing;

class _GraphicsPathSegment extends _GraphicsMeshSegment {

  bool _clockwise;
  bool _closed = false;

  _GraphicsPathSegment() : super(16, 32);

  _GraphicsPathSegment.clone(_GraphicsPathSegment segment) : super.clone(segment) {
    _clockwise = segment.clockwise;
    _closed = segment.closed;
  }

  //---------------------------------------------------------------------------

  bool get clockwise {
    if (_clockwise is! bool) _clockwise = _calculateArea() >= 0.0;
    return _clockwise;
  }

  bool get closed {
    return _closed;
  }

  set closed(bool value) {
    _closed = value;
  }

  //---------------------------------------------------------------------------

  @override
  int addVertex(double x, double y) {
    var buf = _vertexBuffer;
    var ofs = _vertexCount * 2;
    if (ofs == 0 || !similar(buf[ofs - 2], x) || !similar(buf[ofs - 1], y)) {
      _indexCount = 0;
      _clockwise = null;
      return super.addVertex(x, y);
    } else {
      return this.vertexCount - 1;
    }
  }

  void calculateIndices() {
    _calculateIndices();
  }

  //---------------------------------------------------------------------------

  int windingCountHitTest(double x, double y) {

    if (_minX > x || _maxX < x) return 0;
    if (_minY > y || _maxY < y) return 0;
    if (_vertexCount < 3) return 0;

    // Winding Number Method
    // http://geomalgorithms.com/a03-_inclusion.html

    int wn = 0;
    num ax = _vertexBuffer[(_vertexCount - 1) * 2 + 0];
    num ay = _vertexBuffer[(_vertexCount - 1) * 2 + 1];

    for(int i = 0; i < _vertexCount; i++) {
      num bx = _vertexBuffer[i * 2 + 0];
      num by = _vertexBuffer[i * 2 + 1];
      if (ay <= y) {
        if (by >  y && (bx - ax) * (y - ay) - (x - ax) * (by - ay) > 0) wn++;
      } else {
        if (by <= y && (bx - ax) * (y - ay) - (x - ax) * (by - ay) < 0) wn--;
      }
      ax = bx;
      ay = by;
    }

    return wn;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _calculateIndices() {

    _indexCount = 0;

    var buffer = _vertexBuffer;
    var count = _vertexCount;
    if (count < 3) return;

    // TODO: benchmark more triangulation methods
    // http://erich.realtimerendering.com/ptinpoly/

    var available = new List<int>();
    var clockwise = this.clockwise;
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

      num u = 0.0, v = 0.0;
      num tmp = y31 * x21 - x31 * y21;
      var earFound = clockwise ? tmp >= 0 : tmp <= 0;

      for(int j = 0; j < available.length && earFound; j++) {
        int vi = available[j];
        if (vi != i0 && vi != i1 && vi != i2) {
          num x01 = buffer[vi * 2 + 0] - x1;
          num y01 = buffer[vi * 2 + 1] - y1;
          if ((u = tmp * x21 * y01 - tmp * y21 * x01) >= 0.0) {
            if ((v = tmp * y31 * x01 - tmp * x31 * y01) >= 0.0) {
              if (u + v < tmp * tmp) earFound = false;
            }
          }
        }
      }

      if (earFound) {
        addIndices(i0, i1, i2);
        available.removeAt((index + 1) % available.length);
        index = 0;
      } else if (index++ > 3 * available.length) {
        break; // no convex angles :(
      }
    }

    addIndices(available[0], available[1], available[2]);
  }

  //---------------------------------------------------------------------------

  double _calculateArea() {

    var buffer = _vertexBuffer;
    var count = _vertexCount;
    if (count < 3) return 0.0;

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

    return value / 2.0;
  }

}
