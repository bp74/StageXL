part of stagexl.drawing.internal;

abstract class GraphicsCommand {

  void updateContext(GraphicsContext context) {
    // override in command.
  }

  //---------------------------------------------------------------------------
/*
  @deprecated
  void updateBounds(GraphicsBounds bounds) {
    // override in command.
  }

  @deprecated
  void drawCanvas(CanvasRenderingContext2D context) {
    // override in command.
  }

  @deprecated
  void drawWebGL(RenderState renderState) {
    // override in command.
  }

  @deprecated
  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    drawCanvas(context);
    return false;
  }

  @deprecated
  void renderCanvas(CanvasRenderingContext2D context) {
    drawCanvas(context);
  }

  @deprecated
  void renderMaskCanvas(CanvasRenderingContext2D context) {
    drawCanvas(context);
  }
*/
}
