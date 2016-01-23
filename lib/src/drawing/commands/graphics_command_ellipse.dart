part of stagexl.drawing;

class GraphicsCommandEllipse extends GraphicsCommand {

  double _x;
  double _y;
  double _width;
  double _height;

  GraphicsCommandEllipse( num x, num y, num width, num height)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _width = width.toDouble(),
        _height = height.toDouble();

  //---------------------------------------------------------------------------

  double get x => _x;

  set x(double value) {
    _x = value;
    _invalidate();
  }

  double get y => _y;

  set y(double value) {
    _y = value;
    _invalidate();
  }

  double get width => _width;

  set width(double value) {
    _width = value;
    _invalidate();
  }

  double get height => _height;

  set height(double value) {
    _height = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {

    num kappa = 0.5522848;
    num ox = (width / 2) * kappa;
    num oy = (height / 2) * kappa;
    num x1 = x - width / 2;
    num y1 = y - height / 2;
    num x2 = x + width / 2;
    num y2 = y + height / 2;
    num xm = x;
    num ym = y;

    context.moveTo(x1, ym);
    context.bezierCurveTo(x1, ym - oy, xm - ox, y1, xm, y1);
    context.bezierCurveTo(xm + ox, y1, x2, ym - oy, x2, ym);
    context.bezierCurveTo(x2, ym + oy, xm + ox, y2, xm, y2);
    context.bezierCurveTo(xm - ox, y2, x1, ym + oy, x1, ym);
    context.closePath();
  }

}
