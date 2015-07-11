part of stagexl.drawing;

class _GraphicsCommandBeginPath extends GraphicsCommand {

  @override
  void updateContext(GraphicsContext context) {
    context.beginPath();
  }
}
