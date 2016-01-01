part of stagexl.drawing.internal;

class GraphicsStrokeSegment extends GraphicsMesh {

  final GraphicsStroke stroke;
  final GraphicsPathSegment pathSegment;

  GraphicsStrokeSegment(GraphicsStroke stroke, GraphicsPathSegment pathSegment)
      : super(pathSegment.vertexCount * 2, pathSegment.vertexCount * 6),
        this.stroke = stroke,
        this.pathSegment = pathSegment {

    // TODO: implement full stroke logic!
    // joint, currently always JointStyle.MITER
    // caps, currently always CapsStyle.BUTT
    // calculate normals and joints in one go (avoid length segments)
    // calculate correct miter limit (not infinite like now)
    // take closePath into account

    _calculateStroke();
  }

  void _calculateStroke() {

    var length = pathSegment.vertexCount;
    var vertices = pathSegment._vertexBuffer;
    if (length < 2) return;

    // calculate normals

    var normals = new Float32List(length * 2);
    var width = stroke.command.width;

    for (var i = 0; i < length - 1; i++) {
      num x1 = vertices[i * 2 + 0];
      num y1 = vertices[i * 2 + 1];
      num x2 = vertices[i * 2 + 2];
      num y2 = vertices[i * 2 + 3];
      num vx = x2 - x1;
      num vy = y2 - y1;
      num vl = math.sqrt(vx * vx + vy * vy);
      normals[i * 2 + 0] = 0.0 - (width / 2.0) * (vy / vl);
      normals[i * 2 + 1] = 0.0 + (width / 2.0) * (vx / vl);
    }

    // calculate joints

    num n1x = 0.0;
    num n1y = 0.0;

    for (var i = 0; i < length; i++) {

      num v2x = vertices[i * 2 + 0];
      num v2y = vertices[i * 2 + 1];
      num n2x = normals[i * 2 + 0];
      num n2y = normals[i * 2 + 1];

      if (i == 0) {
        addVertex(v2x + n2x, v2y + n2y);
        addVertex(v2x - n2x, v2y - n2y);
      } else if (i == length - 1) {
        addVertex(v2x + n1x, v2y + n1y);
        addVertex(v2x - n1x, v2y - n1y);
      } else {
        num id = (n2x * n1y - n2y * n1x);
        num it = (n2x * (n1x - n2x) + n2y * (n1y - n2y)) / id;
        num ix = n1x - it * n1y;
        num iy = n1y + it * n1x;
        addVertex(v2x + ix, v2y + iy);
        addVertex(v2x - ix, v2y - iy);
      }

      n1x = n2x;
      n1y = n2y;

      var vertexCount = this.vertexCount;
      if (vertexCount >= 4) {
        addTriangle(vertexCount - 4, vertexCount - 2, vertexCount - 3);
        addTriangle(vertexCount - 3, vertexCount - 2, vertexCount - 1);
      }
    }
  }

}
