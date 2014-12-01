part of stagexl.drawing;

abstract class _GraphicsCommand {

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    render(context);
    return false;
  }

  void drawPath(CanvasRenderingContext2D context) {
    render(context);
  }

  void updateBounds(_GraphicsBounds bounds) {
    // override if command has an effect on the bounds
  }

  void render(CanvasRenderingContext2D context);
}
