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
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _updateHitForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _updateHitForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _updateHitForStroke();
  }

  //---------------------------------------------------------------------------

  void _updateHitForFill() {
    if (_hit == false) {
      _hit = _path.hitTest(_localX, _localY);
    }
  }

  void _updateHitForStroke() {
    if (_hit == false) {
      var stroke = _stroke ?? new GraphicsStroke(_path, _command);
      _hit = stroke.hitTest(_localX, _localY);
    }
  }

}
