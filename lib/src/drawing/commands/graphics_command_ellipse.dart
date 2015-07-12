part of stagexl.drawing;

class _GraphicsCommandEllipse extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;

  _GraphicsCommandEllipse(
      num x, num y, num width, num height) :

      this.x = x.toDouble(),
      this.y = y.toDouble(),
      this.width = width.toDouble(),
      this.height = height.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.ellipse(x, y, width, height);
  }
}
