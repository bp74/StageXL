part of stagexl.drawing.internal;

class GraphicsStroke {

  final List<GraphicsStrokeSegment> _segments =  new List<GraphicsStrokeSegment>();
  final GraphicsPath path;
  final GraphicsCommandStroke command;

  GraphicsStroke(this.path, this.command) {
    for (var segment in this.path.segments) {
      _segments.add(new GraphicsStrokeSegment(this, segment));
    }
  }

  Iterable<GraphicsStrokeSegment> get segments => _segments;

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    for (var segment in _segments) {
      segment.fillColor(renderState, color);
    }
  }

  bool hitTest(double x, double y) {
    // TODO: hitTest for strokes
    return false;
  }



}
