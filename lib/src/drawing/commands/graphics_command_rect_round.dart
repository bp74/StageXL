part of stagexl.drawing.commands;

class GraphicsCommandRectRound extends GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;
  final double ellipseWidth;
  final double ellipseHeight;

  GraphicsCommandRectRound(
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
    context.moveTo(x + ellipseWidth, y);
    context.lineTo(x + width - ellipseWidth, y);
    context.quadraticCurveTo(x + width, y, x + width, y + ellipseHeight);
    context.lineTo(x + width, y + height - ellipseHeight);
    context.quadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height);
    context.lineTo(x + ellipseWidth, y + height);
    context.quadraticCurveTo(x, y + height, x, y + height - ellipseHeight);
    context.lineTo(x, y + ellipseHeight);
    context.quadraticCurveTo(x, y, x + ellipseWidth, y);
    context.closePath();
  }
}
