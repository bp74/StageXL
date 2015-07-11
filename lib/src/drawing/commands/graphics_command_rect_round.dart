part of stagexl.drawing.internal;

class _GraphicsCommandRectRound extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;
  final double ellipseWidth;
  final double ellipseHeight;

  _GraphicsCommandRectRound(num x, num y, num width, num height, num ellipseWidth, num ellipseHeight) :
      x = x.toDouble(),
      y = y.toDouble(),
      width = width.toDouble(),
      height = height.toDouble(),
      ellipseWidth = ellipseWidth.toDouble(),
      ellipseHeight = ellipseHeight.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.rectRound(x, y, width, height, ellipseWidth, ellipseHeight);
  }
}
