part of stagexl.drawing.commands;

class GraphicsCommandBeginPath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.beginPath();
  }
}
