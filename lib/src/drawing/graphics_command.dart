part of stagexl.drawing;

abstract class _GraphicsCommand {

  render(CanvasRenderingContext2D context);

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    render(context);
    return false;
  }

  drawPath(CanvasRenderingContext2D context) {
    render(context);
  }

  updateBounds(_GraphicsBounds bounds) {
    // override if command has an effect on the bounds
  }
}
