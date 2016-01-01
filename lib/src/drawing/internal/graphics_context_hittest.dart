part of stagexl.drawing.internal;

class GraphicsContextHitTest extends GraphicsContext {

  bool _hit = false;
  double _localX = 0.0;
  double _localY = 0.0;

  GraphicsContextHitTest(num localX, num localY) :
      _localX = localX.toDouble(),
      _localY = localY.toDouble();

  bool get hit => _hit;

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _updateHitForFill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _updateHitForFill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _updateHitForFill();
  }

  @override
  void strokeColor(int color, double width, String jointStyle, String capsStyle) {
    _updateHitForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, String jointStyle, String capsStyle) {
    _updateHitForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, String jointStyle, String capsStyle) {
    _updateHitForStroke();
  }

  //---------------------------------------------------------------------------

  void _updateHitForFill() {
    _hit = _hit || _path.hitTest(_localX, _localY);
  }

  void _updateHitForStroke() {
    var stroke = _stroke ?? new GraphicsStroke(_path, _command);
    _hit = _hit || stroke.hitTest(_localX, _localY);
  }

}
