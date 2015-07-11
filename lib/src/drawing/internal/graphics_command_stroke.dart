part of stagexl.drawing.internal;

abstract class GraphicsCommandStroke extends GraphicsCommand {

  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  GraphicsCommandStroke(num lineWidth, String lineJoin, String lineCap) :

    lineWidth = lineWidth.toDouble(),
    lineJoin = lineJoin,
    lineCap = lineCap;

  //---------------------------------------------------------------------------

  /*
  @override
  void updateBounds(GraphicsBounds bounds) {
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
  */
}
