part of stagexl.drawing;

class GraphicsCommandArcElliptical extends GraphicsCommand {

  double _x;
  double _y;
  double _radiusX;
  double _radiusY;
  double _rotation;
  double _startAngle;
  double _endAngle;
  bool _antiClockwise;

  GraphicsCommandArcElliptical(
      num x, num y, num radiusX, num radiusY, num rotation,
      num startAngle, num endAngle, bool antiClockwise)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _radiusX = radiusX.toDouble(),
        _radiusY = radiusY.toDouble(),
        _rotation = rotation.toDouble(),
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

  double get radiusX => _radiusX;

  set radiusX(double value) {
    _radiusX = value;
    _invalidate();
  }

  double get radiusY => _radiusY;

  set radiusY(double value) {
    _radiusY = value;
    _invalidate();
  }

  double get rotation => _rotation;

  set rotation(double value) {
    _rotation = value;
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
    context.arcElliptical(
        x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
  }
}
