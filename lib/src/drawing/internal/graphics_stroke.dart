part of stagexl.drawing.internal;

class GraphicsStroke extends GraphicsMesh {

  final double width;
  final JointStyle jointStyle;
  final CapsStyle capsStyle;

  GraphicsStroke(GraphicsPath path, this.width, this.jointStyle, this.capsStyle) {
    for (var pathSegment in path.segments) {
      segments.add(new GraphicsStrokeSegment(this, pathSegment));
    }
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    for (GraphicsStrokeSegment segment in segments) {
      segment.fillColor(renderState, color);
    }
  }

  bool hitTest(double x, double y) {
    for (GraphicsStrokeSegment segment in segments) {
      if (segment.checkBounds(x, y) == false) continue;
      if (segment.hitTest(x, y)) return true;
    }
    return false;
  }

}
