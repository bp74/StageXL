part of stagexl.drawing;

class GraphicsCommandBezierCurveTo extends GraphicsCommand {

  double _controlX1;
  double _controlY1;
  double _controlX2;
  double _controlY2;
  double _endX;
  double _endY;

  GraphicsCommandBezierCurveTo(
      num controlX1, num controlY1,
      num controlX2, num controlY2,
      num endX, num endY)

      : _controlX1 = controlX1.toDouble(),
        _controlY1 = controlY1.toDouble(),
        _controlX2 = controlX2.toDouble(),
        _controlY2 = controlY2.toDouble(),
        _endX = endX.toDouble(),
        _endY = endY.toDouble();

  //---------------------------------------------------------------------------

  double get controlX1 => _controlX1;

  set controlX1(double value) {
    _controlX1 = value;
    _invalidate();
  }

  double get controlY1 => _controlY1;

  set controlY1(double value) {
    _controlY1 = value;
    _invalidate();
  }

  double get controlX2 => _controlX2;

  set controlX2(double value) {
    _controlX2 = value;
    _invalidate();
  }

  double get controlY2 => _controlY2;

  set controlY2(double value) {
    _controlY2 = value;
    _invalidate();
  }

  double get endX => _endX;

  set endX(double value) {
    _endX = value;
    _invalidate();
  }

  double get endY => _endY;

  set endY(double value) {
    _endY = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

}

