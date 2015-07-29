part of stagexl.drawing.commands;

class GraphicsCommandClosePath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.closePath();
  }
}
