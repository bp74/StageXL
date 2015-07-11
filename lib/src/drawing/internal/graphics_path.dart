part of stagexl.drawing.internal;

class GraphicsPath {

  List<GraphicsPathSegment> _segments = new List<GraphicsPathSegment>();
  GraphicsPathSegment _currentSegment;

  void moveTo(double x, double y) {
    _currentSegment = new GraphicsPathSegment();
    _currentSegment.addVertex(x, y);
    _segments.add(_currentSegment);
  }

  void lineTo(double x, double y) {
    if (_currentSegment == null) {
      moveTo(x, y);
    } else {
      _currentSegment.addVertex(x, y);
    }
  }

  //---------------------------------------------------------------------------

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    // TODO: implement arc path
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    // TODO: implement arcTo path
  }

  void circle(double x, double y, double radius, bool antiClockwise) {

    // TODO: implement antiClockwise

    var steps = 40;
    var cosR = math.cos(2 * math.PI / steps);
    var sinR = math.sin(2 * math.PI / steps);
    var tx = x - x * cosR + y * sinR;
    var ty = y - x * sinR - y * cosR;
    var ax = x + radius;
    var ay = y;

    this.moveTo(ax, ay);

    for (int s = 0; s < steps; s++) {
      var bx = ax * cosR - ay * sinR + tx;
      var by = ax * sinR + ay * cosR + ty;
      _currentSegment.addVertex(ax = bx, ay = by);
    }
  }

  void ellipse(double x, double y, double width, double height) {
    // TODO: implement ellipse path
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    // TODO: implement quadraticCurveTo path
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    // TODO: implement bezierCurveTo path
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    // TODO: non-zero winding rule
    for(var segment in _segments) {
      segment.fillColor(renderState, color);
    }
  }




}
