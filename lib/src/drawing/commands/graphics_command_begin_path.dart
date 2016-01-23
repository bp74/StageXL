part of stagexl.drawing;

class GraphicsCommandBeginPath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.beginPath();
  }
}
