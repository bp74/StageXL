part of stagexl.drawing;

abstract class _GraphicsCommandStroke extends _GraphicsCommand {

  num _lineWidth;
  String _lineJoin;
  String _lineCap;

  _GraphicsCommandStroke(num lineWidth, String lineJoin, String lineCap) {
    _lineWidth = lineWidth.toDouble();
    _lineJoin = lineJoin;
    _lineCap = lineCap;
  }

  bool hitTest(CanvasRenderingContext2D context, num localX, num localY) {
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;

    try {
      return context.isPointInStroke(localX, localY);
    } catch (e) {
      return false;
    }
  }

  drawPath(CanvasRenderingContext2D context) {
    // no action
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.stroke(_lineWidth);
  }
}