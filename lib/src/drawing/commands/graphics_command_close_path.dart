part of stagexl.drawing;

class GraphicsCommandClosePath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.closePath();
  }
}
