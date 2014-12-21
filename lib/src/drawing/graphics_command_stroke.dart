part of stagexl.drawing;

abstract class _GraphicsCommandStroke extends _GraphicsCommand {

  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  _GraphicsCommandStroke(num lineWidth, String lineJoin, String lineCap) :

    lineWidth = lineWidth.toDouble(),
    lineJoin = lineJoin,
    lineCap = lineCap;

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.stroke(lineWidth);
  }

  @override
  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {

    context.lineWidth = lineWidth;
    context.lineJoin = lineJoin;
    context.lineCap = lineCap;

    // if a browser does not support isPointInStroke we
    // assume that in most cases it isn't a hit.

    try {
      return context.isPointInStroke(localX, localY);
    } catch (e) {
      return false;
    }
  }

  @override
  void renderMaskCanvas(CanvasRenderingContext2D context) {
    // no action
  }
}
