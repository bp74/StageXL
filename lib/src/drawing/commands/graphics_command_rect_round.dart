part of stagexl.drawing.internal;

class _GraphicsCommandRectRound extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;
  final double ellipseWidth;
  final double ellipseHeight;

  _GraphicsCommandRectRound(
      num x, num y, num width, num height,
      num ellipseWidth, num ellipseHeight) :

      this.x = x.toDouble(),
      this.y = y.toDouble(),
      this.width = width.toDouble(),
      this.height = height.toDouble(),
      this.ellipseWidth = ellipseWidth.toDouble(),
      this.ellipseHeight = ellipseHeight.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.rectRound(x, y, width, height, ellipseWidth, ellipseHeight);
  }
}
