part of stagexl.drawing;

class GraphicsCommandFillColor extends GraphicsCommandFill {

  int _color;

  GraphicsCommandFillColor(int color)
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
    context.fillColor(color);
  }

}
