part of stagexl.drawing.internal;

class GraphicsStrokeSegment extends GraphicsMesh {

  final GraphicsStroke stroke;
  final GraphicsPathSegment pathSegment;

  GraphicsStrokeSegment(GraphicsStroke stroke, GraphicsPathSegment pathSegment)
      : this.stroke = stroke,
        this.pathSegment = pathSegment,
        super(pathSegment.vertexCount * 2, pathSegment.vertexCount * 6) {

    if (pathSegment.vertexCount >= 2) {
      _calculateStroke();
    }
  }

  //---------------------------------------------------------------------------

  bool hitTest(double px, double py) {

    // TODO: stroke hitTest should be optimized

    for(int o = 0; o < _indexCount - 2; o += 3) {

      var i1 = _indexBuffer[o + 0];
      var i2 = _indexBuffer[o + 1];
      var i3 = _indexBuffer[o + 2];
      var ax = _vertexBuffer[i1 * 2 + 0];
      var ay = _vertexBuffer[i1 * 2 + 1];
      var bx = _vertexBuffer[i2 * 2 + 0];
      var by = _vertexBuffer[i2 * 2 + 1];
      var cx = _vertexBuffer[i3 * 2 + 0];
      var cy = _vertexBuffer[i3 * 2 + 1];

      num v0x = cx - ax;
      num v0y = cy - ay;
      num v1x = bx - ax;
      num v1y = by - ay;
      num v2x = px - ax;
      num v2y = py - ay;

      num dot00 = v0x * v0x + v0y * v0y;
      num dot01 = v0x * v1x + v0y * v1y;
      num dot02 = v0x * v2x + v0y * v2y;
      num dot11 = v1x * v1x + v1y * v1y;
      num dot12 = v1x * v2x + v1y * v2y;

      num invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
      num u = (dot11 * dot02 - dot01 * dot12) * invDenom;
      num v = (dot00 * dot12 - dot01 * dot02) * invDenom;
      if ((u >= 0) && (v >= 0) && (u + v < 1)) return true;
    }

    return false;
  }

  //---------------------------------------------------------------------------

  void _calculateStroke() {

    // TODO: implement full stroke logic!
    // joint, currently always JointStyle.MITER
    // caps, currently always CapsStyle.BUTT
    // calculate correct miter limit (not infinite like now)

    var length = pathSegment.vertexCount;
    var closed = pathSegment.closed;
    var vertices = pathSegment._vertexBuffer;
    var width = stroke.command.width;

    var v1x = 0.0, v1y = 0.0;
    var n1x = 0.0, n1y = 0.0;
    var v2x = 0.0, v2y = 0.0;
    var n2x = 0.0, n2y = 0.0;

    for (var i = -2; i <= length; i++) {

      // get next vertex
      var offset = ((i + 1) % length) * 2;
      v2x = vertices[offset + 0];
      v2y = vertices[offset + 1];

      // calculate next normal
      num vx = v2x - v1x;
      num vy = v2y - v1y;
      num vl = math.sqrt(vx * vx + vy * vy);
      n2x = 0.0 - (width / 2.0) * (vy / vl);
      n2y = 0.0 + (width / 2.0) * (vx / vl);

      // calculate vertices
      if (i == 0 && closed == false) {
        this.addVertex(v1x + n2x, v1y + n2y);
        this.addVertex(v1x - n2x, v1y - n2y);
      } else if (i == length - 1 && closed == false) {
        this.addVertex(v1x + n1x, v1y + n1y);
        this.addVertex(v1x - n1x, v1y - n1y);
      } else if (i >= 0 && (i < length || closed)) {
        num id = (n2x * n1y - n2y * n1x);
        num it = (n2x * (n1x - n2x) + n2y * (n1y - n2y)) / id;
        num ix = n1x - it * n1y;
        num iy = n1y + it * n1x;
        this.addVertex(v1x + ix, v1y + iy);
        this.addVertex(v1x - ix, v1y - iy);
      }

      // add indices
      if (i > 0 && (i < length || closed)) {
        var vertexCount = this.vertexCount;
        this.addIndices(vertexCount - 4, vertexCount - 3, vertexCount - 2);
        this.addIndices(vertexCount - 3, vertexCount - 2, vertexCount - 1);
      }

      // shift vertices and normals
      v1x = v2x; v1y = v2y;
      n1x = n2x; n1y = n2y;
    }
  }

}
