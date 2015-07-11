part of stagexl.drawing.internal;

class _GraphicsCommandEllipse extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;

  _GraphicsCommandEllipse(num x, num y, num width, num height) :
      x = x.toDouble(),
      y = y.toDouble(),
      width = width.toDouble(),
      height = height.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.ellipse(x, y, width, height);
  }
}
