part of '../../drawing.dart';

class GraphicsCommandClosePath extends GraphicsCommand {
  @override
  void updateContext(GraphicsContext context) {
    context.closePath();
  }
}
