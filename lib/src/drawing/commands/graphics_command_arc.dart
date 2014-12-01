part of stagexl.drawing;

class _GraphicsCommandArc extends _GraphicsCommand {

  num _x, _y, _radius;
  num _startAngle, _endAngle;
  bool _antiClockwise;

  _GraphicsCommandArc(num x, num y, num radius, num startAngle, num endAngle, bool antiClockwise) {
    _x = x.toDouble();
    _y = y.toDouble();
    _radius = radius.toDouble();
    _startAngle = startAngle.toDouble();
    _endAngle = endAngle.toDouble();
    _antiClockwise = antiClockwise;
  }

  render(CanvasRenderingContext2D context) {
    context.arc(_x, _y, _radius, _startAngle, _endAngle, _antiClockwise);
  }

  updateBounds(_GraphicsBounds bounds) {

    var initPoint = new Vector(_radius, 0);
    var startPoint = initPoint.rotate(_startAngle);
    var endPoint = initPoint.rotate(_endAngle);

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_x + startPoint.x, _y + startPoint.y);
    }

    var angle1 = _startAngle;
    var angle2 = _endAngle;

    if (_antiClockwise) {
      if (angle1 < angle2) angle1 = angle1 + 2 * PI;
    } else {
      if (angle2 < angle1) angle2 = angle2 + 2 * PI;
    }

    var arcAngle = angle2 - angle1;
    var arcSteps = (arcAngle * 30).abs() ~/ PI + 1;

    bounds.updatePath(bounds.cursorX, bounds.cursorY);

    for (var i = 0; i <= arcSteps; i++) {
      var v = initPoint.rotate(angle1 + i * arcAngle / arcSteps);
      bounds.updatePath(_x + v.x, _y + v.y);
    }

    bounds.updateCursor(_x + endPoint.x, _y + endPoint.y);
  }
}

