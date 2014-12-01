part of stagexl.drawing;

class _GraphicsCommandBezierCurveTo extends _GraphicsCommand {

  num _controlX1, _controlY1;
  num _controlX2, _controlY2;
  num _endX, _endY;

  _GraphicsCommandBezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) {
    _controlX1 = controlX1.toDouble();
    _controlY1 = controlY1.toDouble();
    _controlX2 = controlX2.toDouble();
    _controlY2 = controlY2.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
  }

  //---------------------------------------------------------------------------

  // first derivative root finding for cubic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  num _computeCubicBaseValue(num t, num a, num b, num c, num d) {
    num mt = 1 - t;
    return mt * mt * mt * a + 3 * mt * mt * t * b + 3 * mt * t * t * c + t * t * t * d;
  }

  List<num> _computeCubicFirstDerivativeRoots(num a, num b, num c, num d) {

    num tl = -a + 2 * b - c;
    num tr = -sqrt(-a * (c - d) + b * b - b * (c + d) + c * c);
    num dn = -a + 3 * b - 3 * c + d;

    return (dn != 0) ? <num>[(tl + tr) / dn, (tl - tr) / dn] : <num>[-1, -1];
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_controlX1, _controlY1);
    }

    var start = new Vector(bounds.cursorX, bounds.cursorY);
    var control1 = new Vector(_controlX1, _controlY1);
    var control2 = new Vector(_controlX2, _controlY2);
    var end = new Vector(_endX, _endY);

    // Workaround: if the control points have the same X or Y coordinate,
    // the derivative root calculations returns [-1, -1].
    //..moveTo(230, 150)..bezierCurveTo(250, 180, 320, 180, 340, 150)
    if (control1.x == control2.x) control1 = control1 + new Vector(0.0123, 0.0);
    if (control1.y == control2.y) control1 = control1 + new Vector(0.0, 0.0123);

    bounds.updatePath(start.x, start.y);

    List<num> txs = _computeCubicFirstDerivativeRoots(start.x, control1.x, control2.x, end.x);
    List<num> tys = _computeCubicFirstDerivativeRoots(start.y, control1.y, control2.y, end.y);

    for (int i = 0; i < 2; i++) {
      num tx = txs[i].toDouble();
      num ty = tys[i].toDouble();
      num xm = (tx >= 0 && tx <= 1) ? _computeCubicBaseValue(tx, start.x, control1.x, control2.x, end.x) : start.x;
      num ym = (ty >= 0 && ty <= 1) ? _computeCubicBaseValue(ty, start.y, control1.y, control2.y, end.y) : start.y;
      bounds.updatePath(xm, ym);
    }

    bounds.updatePath(end.x, end.y);
    bounds.updateCursor(_endX, _endY);
  }

  //---------------------------------------------------------------------------

  @override
  void render(CanvasRenderingContext2D context) {
    context.bezierCurveTo(_controlX1, _controlY1, _controlX2, _controlY2, _endX, _endY);
  }

}

