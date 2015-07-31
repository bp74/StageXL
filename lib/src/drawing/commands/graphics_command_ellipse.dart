part of stagexl.drawing.commands;

class GraphicsCommandEllipse extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;

  GraphicsCommandEllipse(
      num x, num y, num width, num height) :

      this.x = x.toDouble(),
      this.y = y.toDouble(),
      this.width = width.toDouble(),
      this.height = height.toDouble();

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
  }
}
