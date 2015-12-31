part of stagexl.drawing.internal;

class GraphicsPathSegment {

  Float32List _vertexBuffer = null;
  Int16List _indexBuffer = null;

  int _vertexCount = 0;
  int _indexCount = 0;
  bool _clockwise = null;

  double _minX = 0.0 + double.MAX_FINITE;
  double _minY = 0.0 + double.MAX_FINITE;
  double _maxX = 0.0 - double.MAX_FINITE;
  double _maxY = 0.0 - double.MAX_FINITE;

  //---------------------------------------------------------------------------

  GraphicsPathSegment(int vertexBufferSize, int indexBufferSize) :
      _vertexBuffer = new Float32List(vertexBufferSize),
      _indexBuffer = new Int16List(indexBufferSize);

  GraphicsPathSegment clone() {
    var vertexBufferSize = _vertexCount * 2;
    var indexBufferSize = _indexCount;
    var segment = new GraphicsPathSegment(vertexBufferSize, indexBufferSize);
    segment._vertexBuffer.setRange(0, vertexBufferSize, _vertexBuffer);
    segment._indexBuffer.setRange(0, indexBufferSize, _indexBuffer);
    segment._vertexCount = _vertexCount;
    segment._indexCount = _indexCount;
    segment._clockwise = _clockwise;
    segment._minX = _minX;
    segment._minY = _minY;
    segment._maxX = _maxX;
    segment._maxY = _maxY;
    return segment;
  }

  //---------------------------------------------------------------------------

  int get vertexCount => _vertexCount;
  int get indexCount => _indexCount;

  double get lastVertexX => _vertexBuffer[(_vertexCount - 1) * 2 + 0];
  double get lastVertexY => _vertexBuffer[(_vertexCount - 1) * 2 + 1];
  double get firstVertexX => _vertexBuffer[0];
  double get firstVertexY => _vertexBuffer[1];

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;

  Rectangle<num> get bounds =>
      new Rectangle<double>(minX, minY, maxX - minX, maxY - minY);

  bool get clockwise => _clockwise = _clockwise is! bool
      ? _calculateArea(_vertexBuffer, _vertexCount) >= 0.0
      : _clockwise;

  //---------------------------------------------------------------------------

  void reset() {
    _vertexCount = 0;
    _indexCount = 0;
    _clockwise = null;
    _minX = 0.0 + double.MAX_FINITE;
    _minY = 0.0 + double.MAX_FINITE;
    _maxX = 0.0 - double.MAX_FINITE;
    _maxY = 0.0 - double.MAX_FINITE;
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

    _minX = _minX > x ? x : _minX;
    _minY = _minY > y ? y : _minY;
    _maxX = _maxX < x ? x : _maxX;
    _maxY = _maxY < y ? y : _maxY;

    _vertexBuffer[offset + 0] = x;
    _vertexBuffer[offset + 1] = y;
    _vertexCount += 1;
    _clockwise = null;
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

  void calculateIndices() {
    _indexCount = 0;
    _calculateIndices(_vertexBuffer, _vertexCount, clockwise);
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

  void fillColor(RenderState renderState, int color) {
    var ixList = new Int16List.view(_indexBuffer.buffer, 0, _indexCount);
    var vxList = new Float32List.view(_vertexBuffer.buffer, 0, _vertexCount * 2);
    renderState.renderTriangleMesh(ixList, vxList, color);
  }

  //---------------------------------------------------------------------------

  GraphicsPathSegment calculateStroke(num width, String joint, String caps) {

    // TODO: implement full stroke logic!
    // joint, currently always JointStyle.MITER
    // caps, currently always CapsStyle.BUTT
    // calculate normals and joints in one go (avoid length segments)
    // calculate correct miter limit (not infinite like now)
    // take closePath into account

    var length = _vertexCount;
    var stroke = new GraphicsPathSegment(length * 2, length * 6);
    if (_vertexCount < 2) return stroke;

    // calculate normals

    var normals = new Float32List(length * 2);

    for (var i = 0; i < length - 1; i++) {
      num x1 = _vertexBuffer[i * 2 + 0];
      num y1 = _vertexBuffer[i * 2 + 1];
      num x2 = _vertexBuffer[i * 2 + 2];
      num y2 = _vertexBuffer[i * 2 + 3];
      num vx = x2 - x1;
      num vy = y2 - y1;
      num vl = math.sqrt(vx * vx + vy * vy);
      normals[i * 2 + 0] = 0.0 - (width / 2.0) * (vy / vl);
      normals[i * 2 + 1] = 0.0 + (width / 2.0) * (vx / vl);
    }

    // calculate joints

    num v1x = 0.0, v1y = 0.0;
    num n1x = 0.0, n1y = 0.0;

    for (var i = 0; i < length; i++) {

      num v2x = _vertexBuffer[i * 2 + 0];
      num v2y = _vertexBuffer[i * 2 + 1];
      num n2x = normals[i * 2 + 0];
      num n2y = normals[i * 2 + 1];

      if (i == 0) {
        stroke.addVertex(v2x + n2x, v2y + n2y);
        stroke.addVertex(v2x - n2x, v2y - n2y);
      } else if (i == length - 1) {
        stroke.addVertex(v2x + n1x, v2y + n1y);
        stroke.addVertex(v2x - n1x, v2y - n1y);
      } else {
        num id = (n2x * n1y - n2y * n1x);
        num it = (n2x * (n1x - n2x) + n2y * (n1y - n2y)) / id;
        num ix = n1x - it * n1y;
        num iy = n1y + it * n1x;
        stroke.addVertex(v2x + ix, v2y + iy);
        stroke.addVertex(v2x - ix, v2y - iy);
      }

      v1x = v2x; v1y = v2y;
      n1x = n2x; n1y = n2y;

      var strokeVertexCount = stroke.vertexCount;
      if (strokeVertexCount >= 4) {
        stroke.addIndex(strokeVertexCount - 4);
        stroke.addIndex(strokeVertexCount - 2);
        stroke.addIndex(strokeVertexCount - 3);
        stroke.addIndex(strokeVertexCount - 3);
        stroke.addIndex(strokeVertexCount - 2);
        stroke.addIndex(strokeVertexCount - 1);
      }
    }

    return stroke;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _calculateIndices(Float32List buffer, int count, bool clockwise) {

    if (count < 3) return;

    // TODO: benchmark more triangulation methods
    // http://erich.realtimerendering.com/ptinpoly/

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

      num u = 0.0, v = 0.0;
      num tmp = y31 * x21 - x31 * y21;
      var earFound = clockwise ? tmp >= 0 : tmp <= 0;

      for(int j = 0; j < available.length && earFound; j++) {
        int vi = available[j];
        if (vi != i0 && vi != i1 && vi != i2) {
          num x01 = buffer[vi * 2 + 0] - x1;
          num y01 = buffer[vi * 2 + 1] - y1;
          if ((u = tmp * (x21 * y01 - y21 * x01)) >= 0.0) {
            if ((v = tmp * (y31 * x01 - x31 * y01)) >= 0.0) {
              if (u + v < tmp * tmp) earFound = false;
            }
          }
        }
      }

      if (earFound) {
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

  double _calculateArea(Float32List buffer, int count) {

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
