part of stagexl.drawing.internal;

abstract class GraphicsCommandStroke extends GraphicsCommand {

  final double width;
  final String jointStyle;
  final String capsStyle;

  GraphicsCommandStroke(this.width, this.jointStyle, this.capsStyle);

}
