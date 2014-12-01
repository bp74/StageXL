part of stagexl.drawing;

class _GraphicsCommandClosePath extends _GraphicsCommand {

  _GraphicsCommandClosePath();

  render(CanvasRenderingContext2D context) {
    context.closePath();
  }
}
