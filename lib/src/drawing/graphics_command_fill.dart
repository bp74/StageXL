part of stagexl.drawing;

abstract class _GraphicsCommandFill extends _GraphicsCommand {

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.fill();
  }

  @override
  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {

    // if a browser does not support isPointInPath we
    // assume that in most cases it is a hit.

    try {
      return context.isPointInPath(localX, localY);
    } catch (e) {
      return true;
    }
  }

  @override
  void renderMaskCanvas(CanvasRenderingContext2D context) {
    // no action
  }
}
