part of stagexl.drawing;

abstract class _GraphicsCommand {

  void updateBounds(_GraphicsBounds bounds) {
    // override if command.
  }

  void draw(CanvasRenderingContext2D context) {
    // override if command.
  }

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    draw(context);
    return false;
  }

  void render(CanvasRenderingContext2D context) {
    draw(context);
  }

  void renderMask(CanvasRenderingContext2D context) {
    draw(context);
  }

}
