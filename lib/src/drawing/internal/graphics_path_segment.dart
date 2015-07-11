part of stagexl.drawing.internal;

class GraphicsPathSegment {

  // TODO: Cache the segments to make it fast.

  Float32List _vertexBuffer = new Float32List(16);
  Int16List _indexBuffer = null;
  int _vertexCount = 0;

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

    List<int> result = new List<int>();
    List<int> available = new List<int>();
    int index = 0;

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

      var earFound = false;

      if ((y1 - y2) * (x3 - x2) + (x2 - x1) * (y3 - y2) >= 0) {

        earFound = true;

        for(int j = 0; j < available.length; j++) {

          int vi = available[j];
          if (vi == i0 || vi == i1 || vi == i2) continue;

          // TODO: check if this works too:

          /*
          double y23 = y2 - y3;
          double x32 = x3 - x2;
          double y31 = y3 - y1;
          double x13 = x1 - x3;
          double det = y23 * x13 - x32 * y31;
          double minD = Math.min(det, 0);
          double maxD = Math.max(det, 0);
          double dx = x - x3;
          double dy = y - y3;

          double a = y23 * dx + x32 * dy;
          if (a < minD || a > maxD) return false;
          double b = y31 * dx + x13 * dy;
          if (b < minD || b > maxD) return false;
          double c = det - a - b;
          if (c < minD || c > maxD) return false;
          return true;
          */

          num v0x = x3 - x1;
          num v0y = y3 - y1;
          num v1x = x2 - x1;
          num v1y = y2 - y1;
          num v2x = _vertexBuffer[vi * 2 + 0] - x1;
          num v2y = _vertexBuffer[vi * 2 + 1] - y1;

          num dot00 = v0x * v0x + v0y * v0y;
          num dot01 = v0x * v1x + v0y * v1y;
          num dot02 = v0x * v2x + v0y * v2y;
          num dot11 = v1x * v1x + v1y * v1y;
          num dot12 = v1x * v2x + v1y * v2y;

          num d = (dot00 * dot11 - dot01 * dot01);
          num u = (dot11 * dot02 - dot01 * dot12) / d;
          num v = (dot00 * dot12 - dot01 * dot02) / d;

          if ((u >= 0) && (v >= 0) && (u + v < 1)) {
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

}
