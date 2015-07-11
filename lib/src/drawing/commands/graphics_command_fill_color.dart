part of stagexl.drawing;

class _GraphicsCommandFillColor extends GraphicsCommandFill {

  final int color;

  _GraphicsCommandFillColor(this.color);

  @override updateContext(GraphicsContext context) {
    context.fillColor(color);
  }

  /*
  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.fillStyle = color2rgba(color);
    context.fill();
  }
  */
}
