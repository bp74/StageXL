part of stagexl.drawing.internal;

class _GraphicsCommandCircle extends GraphicsCommand {

  final double x;
  final double y;
  final double radius;
  final bool antiClockwise;

  _GraphicsCommandCircle(num x, num y, num radius, bool antiClockwise) :
      x = x.toDouble(),
      y = y.toDouble(),
      radius = radius.toDouble(),
      antiClockwise = antiClockwise;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.circle(x, y, radius, antiClockwise);
  }
}
