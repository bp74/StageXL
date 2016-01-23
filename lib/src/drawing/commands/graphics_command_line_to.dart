part of stagexl.drawing;

class GraphicsCommandLineTo extends GraphicsCommand {

  double _x;
  double _y;

  GraphicsCommandLineTo(num x, num y)
      : _x = x.toDouble(),
        _y = y.toDouble();

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

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.lineTo(x, y);
  }

}
