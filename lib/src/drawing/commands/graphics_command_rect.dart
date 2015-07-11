part of stagexl.drawing;

class _GraphicsCommandRect extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;

  _GraphicsCommandRect(num x, num y, num width, num height) :
      this.x = x.toDouble(),
      this.y = y.toDouble(),
      this.width = width.toDouble(),
      this.height = height.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.rect(x, y, width, height);
  }
}
