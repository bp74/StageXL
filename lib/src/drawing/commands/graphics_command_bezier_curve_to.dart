part of stagexl.drawing;

class _GraphicsCommandBezierCurveTo extends _GraphicsCommand {

  final double controlX1;
  final double controlY1;
  final double controlX2;
  final double controlY2;
  final double endX;
  final double endY;

  _GraphicsCommandBezierCurveTo(
      num controlX1, num controlY1,
      num controlX2, num controlY2,
      num endX, num endY) :

    controlX1 = controlX1.toDouble(),
    controlY1 = controlY1.toDouble(),
    controlX2 = controlX2.toDouble(),
    controlY2 = controlY2.toDouble(),
    endX = endX.toDouble(),
    endY = endY.toDouble();


  //---------------------------------------------------------------------------

  // first derivative root finding for cubic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  double _computeCubicBaseValue(double t, double a, double b, double c, double d) {
    double mt = 1.0 - t;
    return mt * mt * mt * a + 3.0 * mt * mt * t * b + 3.0 * mt * t * t * c + t * t * t * d;
  }

  List<double> _computeCubicFirstDerivativeRoots(double a, double b, double c, double d) {
    double tl = -a + 2.0 * b - c;
    double tr = -sqrt(a * (d - c) + b * b - b * (c + d) + c * c);
    double dn = -a + 3.0 * b - 3.0 * c + d;
    return dn != 0.0 ? <double>[(tl + tr) / dn, (tl - tr) / dn] : <double>[-1.0, -1.0];
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(controlX1, controlY1);
    }

    double sx = bounds.cursorX.toDouble();
    double sy = bounds.cursorY.toDouble();
    double ax = controlX1;
    double ay = controlY1;
    double bx = controlX2;
    double by = controlY2;
    double ex = endX;
    double ey = endY;

    // Workaround: if the control points have the same X or Y coordinate,
    // the derivative root calculations returns [-1, -1].
    //..moveTo(230, 150)..bezierCurveTo(250, 180, 320, 180, 340, 150)

    if (ax == bx) ax += 0.0123;
    if (ay == by) ay += 0.0123;

    bounds.updatePath(sx, sy);

    List<double> txs = _computeCubicFirstDerivativeRoots(sx, ax, bx, ex);
    List<double> tys = _computeCubicFirstDerivativeRoots(sy, ay, by, ey);

    for (int i = 0; i < 2; i++) {
      double tx = txs[i];
      double ty = tys[i];
      double mx = (tx >= 0.0 && tx <= 1.0) ? _computeCubicBaseValue(tx, sx, ax, bx, ex) : sx;
      double my = (ty >= 0.0 && ty <= 1.0) ? _computeCubicBaseValue(ty, sy, ay, by, ey) : sy;
      bounds.updatePath(mx, my);
    }

    bounds.updatePath(ex, ey);
    bounds.updateCursor(endX, endY);
  }

  //---------------------------------------------------------------------------

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

}

