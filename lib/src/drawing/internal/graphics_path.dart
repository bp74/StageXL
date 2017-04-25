part of stagexl.drawing;

class _GraphicsPath extends _GraphicsMesh<_GraphicsPathSegment> {

  _GraphicsPathSegment _currentSegment;

  _GraphicsPath();

  _GraphicsPath.clone(_GraphicsPath path) {
    for (_GraphicsPathSegment segment in path.segments) {
      if (segment.indexCount == 0) segment.calculateIndices();
      segments.add(new _GraphicsPathSegment.clone(segment));
    }
  }

  //---------------------------------------------------------------------------

  void close() {
    if (_currentSegment != null) {
      _currentSegment.closed = true;
      _currentSegment = null;
    }
  }

  void moveTo(double x, double y) {
    _currentSegment = new _GraphicsPathSegment();
    _currentSegment.addVertex(x, y);
    segments.add(_currentSegment);
  }

  void lineTo(double x, double y) {
    if (_currentSegment == null) {
      this.moveTo(x, y);
    } else {
      _currentSegment.addVertex(x, y);
    }
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {

    if (_currentSegment == null) {

      this.moveTo(controlX, controlY);

    } else {

      var v1x = controlX - _currentSegment.lastVertexX;
      var v1y = controlY - _currentSegment.lastVertexY;
      var v1l = sqrt(v1x * v1x + v1y * v1y);
      var v1a = atan2(v1y, v1x);

      var v2x = endX - controlX;
      var v2y = endY - controlY;
      var v2l = sqrt(v2x * v2x + v2y * v2y);
      var v2a = atan2(v2y, v2x);

      var t = tan((v1a - v2a) / 2.0);
      var l = t > 0.0 ? radius : 0.0 - radius;
      var point1x = controlX - t * l * v1x / v1l;
      var point1y = controlY - t * l * v1y / v1l;
      var point2x = controlX + t * l * v2x / v2l;
      var point2y = controlY + t * l * v2y / v2l;
      var centerX = point1x + l * v1y / v1l;
      var centerY = point1y - l * v1x / v1l;

      if (centerX.isNaN || centerY.isNaN) {
        this.lineTo(controlX, controlY);
      } else {
        var angle1 = atan2(point1y - centerY, point1x - centerX);
        var angle2 = atan2(point2y - centerY, point2x - centerX);
        this.arc(centerX, centerY, radius, angle1, angle2, t > 0.0);
      }
    }
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {

    // TODO: adjust steps

    if (_currentSegment == null) {

      this.moveTo(endY, endY);

    } else {

      int steps = 20;
      num vx = _currentSegment.lastVertexX;
      num vy = _currentSegment.lastVertexY;

      for (int s = 1; s <= steps; s++) {
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

      int steps = 20;
      num vx = _currentSegment.lastVertexX;
      num vy = _currentSegment.lastVertexY;

      for (int s = 1; s <= steps; s++) {
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

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {

    num tau = 2.0 * PI;
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
    num cosR = cos(delta / steps);
    num sinR = sin(delta / steps);
    num tx = x - x * cosR + y * sinR;
    num ty = y - x * sinR - y * cosR;
    num ax = x + cos(start) * radius;
    num ay = y + sin(start) * radius;

    this.lineTo(ax, ay);

    for (int s = 1; s <= steps; s++) {
      num bx = ax * cosR - ay * sinR + tx;
      num by = ax * sinR + ay * cosR + ty;
      _currentSegment.addVertex(ax = bx, ay = by);
    }
  }

  void arcElliptical(
      double x, double y, double radiusX, double radiusY, double rotation,
      double startAngle, double endAngle, bool antiClockwise) {

    num tau = 2.0 * PI;
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
    num sinRotationX = radiusX * sin(rotation);
    num cosRotationX = radiusX * cos(rotation);
    num sinRotationY = radiusY * sin(rotation);
    num cosRotationY = radiusY * cos(rotation);
    num angleDelta = delta / steps;
    num angle = startAngle;

    for (int s = 0; s <= steps; s++, angle += angleDelta) {
      num cx = cos(angle);
      num cy = sin(angle);
      num rx = x + cx * cosRotationX - cy * sinRotationY;
      num ry = y + cx * sinRotationX + cy * cosRotationY;
      this.lineTo(rx, ry);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  void fillColor(RenderState renderState, int color) {
    // TODO: non-zero winding rule
    for (_GraphicsPathSegment segment in segments) {
      if (segment.indexCount == 0) segment.calculateIndices();
      segment.fillColor(renderState, color);
    }
  }

  @override
  void fillGradient(RenderState renderState, GraphicsGradient gradient) {
    // TODO: non-zero winding rule
    for (_GraphicsPathSegment segment in segments) {
      if (segment.indexCount == 0) segment.calculateIndices();
      segment.fillGradient(renderState, gradient);
    }
  }

  @override
  void fillPattern(RenderState renderState, GraphicsPattern pattern) {
    // TODO: non-zero winding rule
    for (_GraphicsPathSegment segment in segments) {
      if (segment.indexCount == 0) segment.calculateIndices();
      segment.fillPattern(renderState, pattern);
    }
  }

  @override
  bool hitTest(double x, double y) {
    int windingCount = 0;
    for (_GraphicsPathSegment segment in segments) {
      if (segment.checkBounds(x, y) == false) continue;
      if (segment.indexCount == 0) segment.calculateIndices();
      windingCount += segment.windingCountHitTest(x, y);
    }
    return windingCount != 0;
  }

}
