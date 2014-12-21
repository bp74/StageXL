part of stagexl.drawing;

abstract class _GraphicsCommand {

  void updateBounds(_GraphicsBounds bounds) {
    // override in command.
  }

  void drawCanvas(CanvasRenderingContext2D context) {
    // override in command.
  }

  void drawWebGL(RenderState renderState) {
    // override in command.
  }

  //---------------------------------------------------------------------------

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    drawCanvas(context);
    return false;
  }

  //---------------------------------------------------------------------------

  void renderCanvas(CanvasRenderingContext2D context) {
    drawCanvas(context);
  }

  void renderMaskCanvas(CanvasRenderingContext2D context) {
    drawCanvas(context);
  }
}
