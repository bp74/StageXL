part of stagexl.drawing;

abstract class _GraphicsCommandFill extends _GraphicsCommand {

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    return context.isPointInPath(localX, localY);
  }

  drawPath(CanvasRenderingContext2D context) {
    // no action
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.fill();
  }
}
