part of stagexl.drawing;

class GraphicsCommandStrokeColor extends GraphicsCommandStroke {

  final int color;

  GraphicsCommandStrokeColor(
      this.color, num width, JointStyle jointStyle, CapsStyle capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeColor(color, width, jointStyle, capsStyle);
  }
}
