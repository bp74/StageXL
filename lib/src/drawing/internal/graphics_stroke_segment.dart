part of stagexl.drawing.internal;

class GraphicsStrokeSegment extends GraphicsMesh {

  final GraphicsStroke stroke;
  final GraphicsPathSegment pathSegment;

  GraphicsStrokeSegment(GraphicsStroke stroke, GraphicsPathSegment pathSegment)
      : this.stroke = stroke,
        this.pathSegment = pathSegment,
        super(pathSegment.vertexCount * 2, pathSegment.vertexCount * 6) {

    // TODO: implement full stroke logic!
    // joint, currently always JointStyle.MITER
    // caps, currently always CapsStyle.BUTT
    // calculate correct miter limit (not infinite like now)

    if (pathSegment.vertexCount >= 2) {
      _calculateStroke();
    }
  }

  //---------------------------------------------------------------------------

  void _calculateStroke() {

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
        addVertex(v1x + n2x, v1y + n2y);
        addVertex(v1x - n2x, v1y - n2y);
      } else if (i == length - 1 && closed == false) {
        addVertex(v1x + n1x, v1y + n1y);
        addVertex(v1x - n1x, v1y - n1y);
      } else if (i >= 0 && (i < length || closed)) {
        num id = (n2x * n1y - n2y * n1x);
        num it = (n2x * (n1x - n2x) + n2y * (n1y - n2y)) / id;
        num ix = n1x - it * n1y;
        num iy = n1y + it * n1x;
        addVertex(v1x + ix, v1y + iy);
        addVertex(v1x - ix, v1y - iy);
      }

      // add indices
      if (i > 0 && (i < length || closed)) {
        var vertexCount = this.vertexCount;
        addTriangle(vertexCount - 4, vertexCount - 3, vertexCount - 2);
        addTriangle(vertexCount - 3, vertexCount - 2, vertexCount - 1);
      }

      // shift vertices and normals
      v1x = v2x; v1y = v2y;
      n1x = n2x; n1y = n2y;
    }
  }

}
