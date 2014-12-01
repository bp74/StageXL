part of stagexl.drawing;

class _GraphicsCommandFillColor extends _GraphicsCommandFill {

  String _color;

  _GraphicsCommandFillColor(String color) {
    _color = color;
  }

  render(CanvasRenderingContext2D context) {
    context.fillStyle = _color;
    context.fill();
  }
}
