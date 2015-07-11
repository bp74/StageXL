part of stagexl.drawing;

class _GraphicsCommandMoveTo extends GraphicsCommand {

  final double x;
  final double y;

  _GraphicsCommandMoveTo(num x, num y) :
      this.x = x.toDouble(),
      this.y = y.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x, y);
  }
}
