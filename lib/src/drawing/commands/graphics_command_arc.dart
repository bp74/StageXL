part of stagexl.drawing;

class GraphicsCommandArc extends GraphicsCommand {

  final double x;
  final double y;
  final double radius;
  final double startAngle;
  final double endAngle;
  final bool antiClockwise;

  GraphicsCommandArc(
      num x, num y, num radius,
      num startAngle, num endAngle, bool antiClockwise) :

      this.x = x.toDouble(),
      this.y = y.toDouble(),
      this.radius = radius.toDouble(),
      this.startAngle = startAngle.toDouble(),
      this.endAngle = endAngle.toDouble(),
      this.antiClockwise = antiClockwise;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

}
