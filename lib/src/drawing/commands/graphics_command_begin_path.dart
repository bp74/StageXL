part of '../../drawing.dart';

class GraphicsCommandBeginPath extends GraphicsCommand {
  @override
  void updateContext(GraphicsContext context) {
    context.beginPath();
  }
}
