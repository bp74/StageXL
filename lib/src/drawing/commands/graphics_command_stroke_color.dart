part of stagexl.drawing.commands;

class GraphicsCommandStrokeColor extends GraphicsCommand {

  final int color;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  GraphicsCommandStrokeColor(
      int color, num lineWidth, String lineJoin, String lineCap) :

      this.color = color.toInt(),
      this.lineWidth = lineWidth.toDouble(),
      this.lineJoin = lineJoin,
      this.lineCap = lineCap;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeColor(color, lineWidth, lineJoin, lineCap);
  }
}
