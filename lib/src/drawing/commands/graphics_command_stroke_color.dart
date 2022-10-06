part of stagexl.drawing;

class GraphicsCommandStrokeColor extends GraphicsCommandStroke {
  int _color;

  GraphicsCommandStrokeColor(
      int color, super.width, super.jointStyle, super.capsStyle)
      : _color = color;

  //---------------------------------------------------------------------------

  int get color => _color;

  set color(int value) {
    _color = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeColor(color, width, jointStyle, capsStyle);
  }
}
