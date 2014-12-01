part of stagexl.drawing;

class _GraphicsCommandFillColor extends _GraphicsCommandFill {

  String _color;

  _GraphicsCommandFillColor(String color) {
    _color = color;
  }

  //---------------------------------------------------------------------------

  @override
  void render(CanvasRenderingContext2D context) {
    context.fillStyle = _color;
    context.fill();
  }
}
