part of stagexl.drawing;

class GraphicsCommandArc extends GraphicsCommand {

  double _x;
  double _y;
  double _radius;
  double _startAngle;
  double _endAngle;
  bool _antiClockwise;

  GraphicsCommandArc(
      num x, num y, num radius,
      num startAngle, num endAngle, bool antiClockwise)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _radius = radius.toDouble(),
        _startAngle = startAngle.toDouble(),
        _endAngle = endAngle.toDouble(),
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

  double get startAngle => _startAngle;

  set startAngle(double value) {
    _startAngle = value;
    _invalidate();
  }

  double get endAngle => _endAngle;

  set endAngle(double value) {
    _endAngle = value;
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
    context.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

}
