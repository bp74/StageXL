part of stagexl.drawing.commands;

class GraphicsCommandQuadraticCurveTo extends GraphicsCommand {

  final double controlX;
  final double controlY;
  final double endX;
  final double endY;

  GraphicsCommandQuadraticCurveTo(
      num controlX, num controlY, num endX, num endY) :

      this.controlX = controlX.toDouble(),
      this.controlY = controlY.toDouble(),
      this.endX = endX.toDouble(),
      this.endY = endY.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.quadraticCurveTo(controlX, controlY, endX, endY);
  }
}
