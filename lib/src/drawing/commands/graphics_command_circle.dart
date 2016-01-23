part of stagexl.drawing;

class GraphicsCommandCircle extends GraphicsCommand {

  double _x;
  double _y;
  double _radius;
  bool _antiClockwise;

  GraphicsCommandCircle(num x, num y, num radius, bool antiClockwise)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _radius = radius.toDouble(),
        _antiClockwise = antiClockwise;

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

  double get radius => _radius;

  set radius(double value) {
    _radius = value;
    _invalidate();
  }

  bool get antiClockwise => _antiClockwise;

  set antiClockwise(bool value) {
    _antiClockwise = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x + radius, y);
    context.arc(x, y, radius, 0.0, 2 * PI, antiClockwise);
    context.closePath();
  }

}
