part of stagexl.drawing;

class GraphicsCommandMoveTo extends GraphicsCommand {

  final double x;
  final double y;

  GraphicsCommandMoveTo(num x, num y) :
      this.x = x.toDouble(),
      this.y = y.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x, y);
  }
}
