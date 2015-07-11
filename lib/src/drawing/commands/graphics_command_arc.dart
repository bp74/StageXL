part of stagexl.drawing;

class _GraphicsCommandArc extends _GraphicsCommand {

  final double x;
  final double y;
  final double radius;
  final double startAngle;
  final double endAngle;
  final bool antiClockwise;

  _GraphicsCommandArc(
      num x, num y, num radius,
      num startAngle, num endAngle, bool antiClockwise) :

    x = x.toDouble(),
    y = y.toDouble(),
    radius = radius.toDouble(),
    startAngle = startAngle.toDouble(),
    endAngle = endAngle.toDouble(),
    antiClockwise = antiClockwise;

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    var initPoint = new Vector(radius, 0);
    var startPoint = initPoint.rotate(startAngle);
    var endPoint = initPoint.rotate(endAngle);

    if (bounds.hasCursor == false) {
      bounds.updateCursor(x + startPoint.x, y + startPoint.y);
    }

    var angle1 = startAngle;
    var angle2 = endAngle;

    if (antiClockwise) {
      if (angle1 < angle2) angle1 = angle1 + 2 * PI;
    } else {
      if (angle2 < angle1) angle2 = angle2 + 2 * PI;
    }

    var arcAngle = angle2 - angle1;
    var arcSteps = (arcAngle * 30).abs() ~/ PI + 1;

    bounds.updatePath(bounds.cursorX, bounds.cursorY);

    for (var i = 0; i <= arcSteps; i++) {
      var v = initPoint.rotate(angle1 + i * arcAngle / arcSteps);
      bounds.updatePath(x + v.x, y + v.y);
    }

    bounds.updateCursor(x + endPoint.x, y + endPoint.y);
  }

  //---------------------------------------------------------------------------

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

  //---------------------------------------------------------------------------

  @override
  void drawWebGL(RenderState renderState, {GraphicsOptions options}) {
    if(options != null && endAngle == (PI *2).toDouble()){
      int steps = 80;
      var currentX = x + radius;
      var currentY = y;
      var cosR = cos(2 * PI / steps);
      var sinR = sin(2 * PI / steps);
      var tx = x - x * cosR + y * sinR;
      var ty = y - x * sinR - y * cosR;

      for (int s = 0; s < steps; s++) {
        var nextX = currentX * cosR - currentY * sinR + tx;
        var nextY = currentX * sinR + currentY * cosR + ty;
        renderState.renderTriangle(
            x, y, currentX, currentY, nextX, nextY, options.fillColor);
        currentX = nextX;
        currentY = nextY;
      }
    }
  }

}

