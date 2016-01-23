part of stagexl.drawing;

class GraphicsCommandRectRound extends GraphicsCommand {

  double _x;
  double _y;
  double _width;
  double _height;
  double _ellipseWidth;
  double _ellipseHeight;

  GraphicsCommandRectRound(
      num x, num y, num width, num height,
      num ellipseWidth, num ellipseHeight)

      : _x = x.toDouble(),
        _y = y.toDouble(),
        _width = width.toDouble(),
        _height = height.toDouble(),
        _ellipseWidth = ellipseWidth.toDouble(),
        _ellipseHeight = ellipseHeight.toDouble();

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

  double get ellipseWidth => _ellipseWidth;

  set ellipseWidth(double value) {
    _ellipseWidth = value;
    _invalidate();
  }

  double get ellipseHeight => _ellipseHeight;

  set ellipseHeight(double value) {
    _ellipseHeight = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x + ellipseWidth, y);
    context.lineTo(x + width - ellipseWidth, y);
    context.quadraticCurveTo(x + width, y, x + width, y + ellipseHeight);
    context.lineTo(x + width, y + height - ellipseHeight);
    context.quadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height);
    context.lineTo(x + ellipseWidth, y + height);
    context.quadraticCurveTo(x, y + height, x, y + height - ellipseHeight);
    context.lineTo(x, y + ellipseHeight);
    context.quadraticCurveTo(x, y, x + ellipseWidth, y);
    context.closePath();
  }

}
