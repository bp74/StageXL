part of stagexl.drawing;

class _GraphicsCommandArcTo extends GraphicsCommand {

  final double controlX;
  final double controlY;
  final double endX;
  final double endY;
  final double radius;

  _GraphicsCommandArcTo(
      num controlX, num controlY,
      num endX, num endY, num radius) :

      this.controlX = controlX.toDouble(),
      this.controlY = controlY.toDouble(),
      this.endX = endX.toDouble(),
      this.endY = endY.toDouble(),
      this.radius = radius.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.arcTo(controlX, controlY, endX, endY, radius);
  }

}
