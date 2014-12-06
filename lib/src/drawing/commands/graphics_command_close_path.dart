part of stagexl.drawing;

class _GraphicsCommandClosePath extends _GraphicsCommand {

  _GraphicsCommandClosePath();

  @override
  void draw(CanvasRenderingContext2D context) {
    context.closePath();
  }
}
