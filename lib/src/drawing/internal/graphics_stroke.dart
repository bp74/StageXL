part of stagexl.drawing.internal;

class GraphicsStroke {

  final GraphicsCommandStroke command;
  final List<GraphicsStrokeSegment> _segments = new List<GraphicsStrokeSegment>();

  GraphicsStroke(GraphicsPath path, this.command) {
    for (var pathSegment in path.segments) {
      var closed = pathSegment.closed;
      var vertices = _filterVertices(pathSegment);
      _segments.add(new GraphicsStrokeSegment(this, closed, vertices));
    }
  }

  Iterable<GraphicsStrokeSegment> get segments => _segments;

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    for (var segment in _segments) {
      segment.fillColor(renderState, color);
    }
  }

  bool hitTest(double x, double y) {
    for (var segment in _segments) {
      if (segment.checkBounds(x, y) == false) continue;
      if (segment.hitTest(x, y)) return true;
    }
    return false;
  }

  //---------------------------------------------------------------------------

  Float32List _filterVertices(GraphicsPathSegment pathSegment) {

    var vertexCount = pathSegment.vertexCount;
    var vertexBuffer = pathSegment._vertexBuffer;

    var vertices = new Float32List(vertexCount * 2);
    var x1 = double.NAN;
    var y1 = double.NAN;
    var length = 0;

    for (int i = 0; i < vertexCount; i++) {
      var x2 = vertexBuffer[i * 2 + 0];
      var y2 = vertexBuffer[i * 2 + 1];
      if (x1 != x2 || y1 != y2) {
        vertices[length * 2 + 0] = x2;
        vertices[length * 2 + 1] = y2;
        x1 = x2;
        y1 = y2;
        length += 1;
      }
    }

    if (pathSegment.closed) {
      var ax = vertices[0];
      var ay = vertices[1];
      var bx = vertices[length * 2 - 2];
      var by = vertices[length * 2 - 1];
      if (ax == bx && ay == by) length -= 1;
    }

    return new Float32List.view(vertices.buffer, 0, length * 2);
  }

}
