part of stagexl.drawing;

class GraphicsCommandStrokeColor extends GraphicsCommandStroke {

  int _color;

  GraphicsCommandStrokeColor(int color,
      num width, JointStyle jointStyle, CapsStyle capsStyle)

      : _color = color,
        super(width, jointStyle, capsStyle);

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
