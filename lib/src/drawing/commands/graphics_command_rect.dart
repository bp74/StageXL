part of stagexl.drawing;

class GraphicsCommandRect extends GraphicsCommand {

  double _x;
  double _y;
  double _width;
  double _height;

  GraphicsCommandRect(num x, num y, num width, num height)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _width = width.toDouble(),
        _height = height.toDouble();

  //---------------------------------------------------------------------------

  double get x => _x;

  set x(double value) {
    _x = value;
    _invalidate();
  }

  double get y => _y;

  set y(double value) {
    _y = value;
    _invalidate();
  }

  double get width => _width;

  set width(double value) {
    _width = value;
    _invalidate();
  }

  double get height => _height;

  set height(double value) {
    _height = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x, y);
    context.lineTo(x + width, y);
    context.lineTo(x + width, y + height);
    context.lineTo(x, y + height);
    context.closePath();
  }

}
