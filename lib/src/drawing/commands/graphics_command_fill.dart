part of stagexl.drawing;

abstract class _GraphicsCommandFill extends _GraphicsCommand {

  @override
  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    return context.isPointInPath(localX, localY);
  }

  @override
  void drawPath(CanvasRenderingContext2D context) {
    // no action
  }

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.fill();
  }
}
