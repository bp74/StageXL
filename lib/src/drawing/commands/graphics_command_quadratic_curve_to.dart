part of stagexl.drawing;

class _GraphicsCommandQuadraticCurveTo extends _GraphicsCommand {

  num _controlX, _controlY;
  num _endX, _endY;

  _GraphicsCommandQuadraticCurveTo(num controlX, num controlY, num endX, num endY) {
    _controlX = controlX.toDouble();
    _controlY = controlY.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
  }

  //---------------------------------------------------------------------------

  // first derivative root finding for quadratic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  num _computeQuadraticBaseValue(num t, num a, num b, num c) {
    num mt = 1 - t;
    return mt * mt * a + 2 * mt * t * b + t * t * c;
  }

  num _computeQuadraticFirstDerivativeRoot(num a, num b, num c) {
    num t = -1;
    num denominator = a - 2 * b + c;
    return (denominator != 0) ? (a - b) / denominator : t;
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_controlX, _controlY);
    }

    var start = new Vector(bounds.cursorX, bounds.cursorY);
    var control = new Vector(_controlX, _controlY);
    var end = new Vector(_endX, _endY);

    bounds.updatePath(start.x, start.y);

    num tx = _computeQuadraticFirstDerivativeRoot(start.x, control.x, end.x);
    num ty = _computeQuadraticFirstDerivativeRoot(start.y, control.y, end.y);
    num xm = (tx >= 0 && tx <= 1) ? _computeQuadraticBaseValue(tx, start.x, control.x, end.x) : start.x;
    num ym = (ty >= 0 && ty <= 1) ? _computeQuadraticBaseValue(ty, start.y, control.y, end.y) : start.y;

    bounds.updatePath(xm, ym);
    bounds.updatePath(end.x, end.y);
    bounds.updateCursor(_endX, _endY);
  }

  //---------------------------------------------------------------------------

  @override
  void render(CanvasRenderingContext2D context) {
    context.quadraticCurveTo(_controlX, _controlY, _endX, _endY);
  }

}
