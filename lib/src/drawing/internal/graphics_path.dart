part of stagexl.drawing.internal;

class GraphicsPath {

  List<GraphicsPathSegment> _segments = new List<GraphicsPathSegment>();
  GraphicsPathSegment _currentSegment = null;

  GraphicsPath clone() {
    var clonedPath = new GraphicsPath();
    for(int i = 0; i < _segments.length; i++) {
      var segment = _segments[i];
      if (segment.indexCount == 0) segment.calculateIndices();
      clonedPath._segments.add(segment.clone());
    }
    return clonedPath;
  }

  Iterable<GraphicsPathSegment> get segments => _segments;

  //---------------------------------------------------------------------------

  void close() {
    if (_currentSegment != null && _currentSegment.vertexCount > 0) {
      var x = _currentSegment.firstVertexX;
      var y = _currentSegment.firstVertexY;
      _currentSegment.addVertex(x, y);
    }
  }

  void moveTo(double x, double y) {
    _currentSegment = new GraphicsPathSegment(16, 32);
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

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {

    if (_currentSegment == null) {

      moveTo(controlX, controlY);

    } else {

      num v1x = controlX - _currentSegment.lastVertexX;
      num v1y = controlY - _currentSegment.lastVertexY;
      num v2x = endX - controlX;
      num v2y = endY - controlY;
      num l1 = math.sqrt(v1x * v1x + v1y * v1y);
      num l2 = math.sqrt(v2x * v2x + v2y * v2y);
      num rads = math.atan2(v1y, v1x) - math.atan2(v2y, v2x);

      num tn = math.tan(rads / 2.0);
      num ra = tn > 0.0 ? radius : 0.0 - radius;
      num tangent1x = controlX - v1x * tn * ra / l1;
      num tangent1y = controlY - v1y * tn * ra / l1;
      num tangent2x = controlX + v2x * tn * ra / l2;
      num tangent2y = controlY + v2y * tn * ra / l2;
      num centerX = tangent1x + v1y * ra / l1;
      num centerY = tangent1y - v1x * ra / l1;

      num angle1 = math.atan2(tangent1y - centerY, tangent1x - centerX);
      num angle2 = math.atan2(tangent2y - centerY, tangent2x - centerX);
      this.arc(centerX, centerY, radius, angle1, angle2, tn > 0.0);
    }
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

  void rect(double x, double y, double width, double height) {
    this.moveTo(x, y);
    this.lineTo(x + width, y);
    this.lineTo(x + width, y + height);
    this.lineTo(x, y + height);
  }

  void rectRound(double x, double y, double width, double height, double ellipseWidth, double ellipseHeight) {
    this.moveTo(x + ellipseWidth, y);
    this.lineTo(x + width - ellipseWidth, y);
    this.quadraticCurveTo(x + width, y, x + width, y + ellipseHeight);
    this.lineTo(x + width, y + height - ellipseHeight);
    this.quadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height);
    this.lineTo(x + ellipseWidth, y + height);
    this.quadraticCurveTo(x, y + height, x, y + height - ellipseHeight);
    this.lineTo(x, y + ellipseHeight);
    this.quadraticCurveTo(x, y, x + ellipseWidth, y);
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {

    num tau = 2.0 * math.PI;
    num start = (startAngle % tau);
    num delta = (endAngle % tau) - start;

    if (antiClockwise && endAngle > startAngle) {
      if (delta >= 0.0) delta -= tau;
    } else if (antiClockwise && startAngle - endAngle >= tau) {
      delta = 0.0 - tau;
    } else if (antiClockwise) {
      delta = (delta % tau) - tau;
    } else if (endAngle < startAngle) {
      if (delta <= 0.0) delta += tau;
    } else if (endAngle - startAngle >= tau) {
      delta = 0.0 + tau;
    } else {
      delta %= tau;
    }

    int steps = (60 * delta / tau).abs().ceil();
    var cosR = math.cos(delta / steps);
    var sinR = math.sin(delta / steps);
    var tx = x - x * cosR + y * sinR;
    var ty = y - x * sinR - y * cosR;
    var ax = x + math.cos(start) * radius;
    var ay = y + math.sin(start) * radius;

    this.lineTo(ax, ay);

    for (int s = 1; s <= steps; s++) {
      var bx = ax * cosR - ay * sinR + tx;
      var by = ax * sinR + ay * cosR + ty;
      _currentSegment.addVertex(ax = bx, ay = by);
    }
  }

  void circle(double x, double y, double radius, bool antiClockwise) {
    this.moveTo(x + radius, y);
    this.arc(x, y, radius, 0.0, 2 * math.PI, antiClockwise);
  }

  void ellipse(double x, double y, double width, double height) {

    num kappa = 0.5522848;
    num ox = (width / 2) * kappa;
    num oy = (height / 2) * kappa;
    num x1 = x - width / 2;
    num y1 = y - height / 2;
    num x2 = x + width / 2;
    num y2 = y + height / 2;
    num xm = x;
    num ym = y;

    this.moveTo(x1, ym);
    this.bezierCurveTo(x1, ym - oy, xm - ox, y1, xm, y1);
    this.bezierCurveTo(xm + ox, y1, x2, ym - oy, x2, ym);
    this.bezierCurveTo(x2, ym + oy, xm + ox, y2, xm, y2);
    this.bezierCurveTo(xm - ox, y2, x1, ym + oy, x1, ym);
  }

  //---------------------------------------------------------------------------

  void fillColor(RenderState renderState, int color) {
    // TODO: non-zero winding rule
    for(int i = 0; i < _segments.length; i++) {
      var segment = _segments[i];
      if (segment.indexCount == 0) segment.calculateIndices();
      segment.fillColor(renderState, color);
    }
  }

  bool hitTest(double x, double y) {
    int windingCount = 0;
    for(int i = 0; i < _segments.length; i++) {
      var segment = _segments[i];
      if (segment.indexCount == 0) segment.calculateIndices();
      if (segment.hitTest(x, y)) windingCount += segment.clockwise ? 1 : -1;
    }
    return windingCount != 0;
  }


}
