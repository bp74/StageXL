part of stagexl.drawing;

class GraphicsCommandLineTo extends GraphicsCommand {

  final double x;
  final double y;

  GraphicsCommandLineTo(num x, num y) :
      this.x = x.toDouble(),
      this.y = y.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.lineTo(x, y);
  }
}
