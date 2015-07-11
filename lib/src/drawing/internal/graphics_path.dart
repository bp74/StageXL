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
    // TODO: adjust steps

    var steps = 40;
    var cosR = math.cos(2 * math.PI / steps);
    var sinR = math.sin(2 * math.PI / steps);
    var tx = x - x * cosR + y * sinR;
    var ty = y - x * sinR - y * cosR;
    var ax = x + radius;
    var ay = y;

    this.moveTo(ax, ay);

    for (int s = 1; s <= steps; s++) {
      var bx = ax * cosR - ay * sinR + tx;
      var by = ax * sinR + ay * cosR + ty;
      _currentSegment.addVertex(ax = bx, ay = by);
    }
  }

  void ellipse(double x, double y, double width, double height) {
    // TODO: implement ellipse path
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {

    // TODO: adjust steps

    if (_currentSegment == null) {

      this.moveTo(endY, endY);

    } else {

      int steps = 10;
      num vx = _currentSegment.lastVertexX;
      num vy = _currentSegment.lastVertexY;

      for(int s = 1; s <= steps; s++) {
        num t0 = s / steps;
        num t1 = 1.0 - t0;
        num b0 = t1 * t1;
        num b1 = t1 * t0 * 2.0;
        num b2 = t0 * t0;
        num x = b0 * vx + b1 * controlX + b2 * endX;
        num y = b0 * vy + b1 * controlY + b2 * endY;
        _currentSegment.addVertex(x, y);
      }
    }
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {

    // TODO: adjust steps

    if (_currentSegment == null) {

      this.moveTo(endY, endY);

    } else {

      int steps = 10;
      num vx = _currentSegment.lastVertexX;
      num vy = _currentSegment.lastVertexY;

      for(int s = 1; s <= steps; s++) {
        num t0 = s / steps;
        num t1 = 1.0 - t0;
        num b0 = t1 * t1 * t1;
        num b1 = t0 * t1 * t1 * 3.0;
        num b2 = t0 * t0 * t1 * 3.0;
        num b3 = t0 * t0 * t0;
        num x = b0 * vx + b1 * controlX1 + b2 * controlX2 + b3 * endX;
        num y = b0 * vy + b1 * controlY1 + b2 * controlY2 + b3 * endY;
        _currentSegment.addVertex(x, y);
      }
    }
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    // TODO: non-zero winding rule
    for(var segment in _segments) {
      segment.fillColor(renderState, color);
    }
  }




}
