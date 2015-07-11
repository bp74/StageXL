part of stagexl.drawing;

class _GraphicsCommandClosePath extends GraphicsCommand {

  _GraphicsCommandClosePath();

  @override
  void updateContext(GraphicsContext context) {
    context.closePath();
  }

  /*
  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.closePath();
  }
  */
}
