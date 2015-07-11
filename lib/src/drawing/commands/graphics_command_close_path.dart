part of stagexl.drawing;

class _GraphicsCommandClosePath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.closePath();
  }
}
