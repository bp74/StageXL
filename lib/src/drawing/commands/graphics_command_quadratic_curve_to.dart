part of stagexl.drawing;

class _GraphicsCommandQuadraticCurveTo extends _GraphicsCommand {

  final double controlX;
  final double controlY;
  final double endX;
  final double endY;

  _GraphicsCommandQuadraticCurveTo(
      num controlX, num controlY,
      num endX, num endY) :

    controlX = controlX.toDouble(),
    controlY = controlY.toDouble(),
    endX = endX.toDouble(),
    endY = endY.toDouble();

  //---------------------------------------------------------------------------

  // first derivative root finding for quadratic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  double _computeQuadraticBaseValue(double t, double a, double b, double c) {
    double mt = 1.0 - t;
    return mt * mt * a + 2.0 * mt * t * b + t * t * c;
  }

  double _computeQuadraticFirstDerivativeRoot(double a, double b, double c) {
    double t = -1.0;
    double denominator = a - 2.0 * b + c;
    return denominator != 0.0 ? (a - b) / denominator : t;
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(controlX, controlY);
    }

    double sx = bounds.cursorX.toDouble();
    double sy = bounds.cursorY.toDouble();
    double cx = controlX;
    double cy = controlY;
    double ex = endX;
    double ey = endY;

    bounds.updatePath(sx, sy);

    double tx = _computeQuadraticFirstDerivativeRoot(sx, cx, ex);
    double ty = _computeQuadraticFirstDerivativeRoot(sy, cy, ey);
    double mx = (tx >= 0.0 && tx <= 1.0) ? _computeQuadraticBaseValue(tx, sx, cx, ex) : sx;
    double my = (ty >= 0.0 && ty <= 1.0) ? _computeQuadraticBaseValue(ty, sy, cy, ey) : sy;

    bounds.updatePath(mx, my);
    bounds.updatePath(ex, ey);
    bounds.updateCursor(ex, ey);
  }

  //---------------------------------------------------------------------------

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.quadraticCurveTo(controlX, controlY, endX, endY);
  }
}
