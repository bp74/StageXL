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
    _hit = _hit || _getHitForFill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _hit = _hit || _getHitForFill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _hit = _hit || _getHitForFill();
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _hit = _hit || _getHitForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _hit = _hit || _getHitForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _hit = _hit || _getHitForStroke();
  }

  //---------------------------------------------------------------------------

  bool _getHitForFill() {
    GraphicsCommandFill command = _command;
    GraphicsMesh mesh = command.mesh ?? _path;
    return mesh.hitTest(_localX, _localY);
  }

  bool _getHitForStroke() {
    GraphicsCommandStroke command = _command;
    GraphicsMesh mesh = command.mesh ?? new GraphicsStroke(_path, _command);
    return mesh.hitTest(_localX, _localY);
  }

}
