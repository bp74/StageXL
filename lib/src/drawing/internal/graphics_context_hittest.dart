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
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement hittest strokeColor
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement hittest strokeGradient
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement hittest strokePattern
  }

  //---------------------------------------------------------------------------

  void _updateHitForFill() {
    _hit = _hit || _path.hitTest(_localX, _localY);
  }


}
