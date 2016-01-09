part of stagexl.drawing.internal;

class GraphicsContextHitTest extends GraphicsContextBase {

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
    GraphicsMesh mesh = _path;
    _hit = _hit || mesh.hitTest(_localX, _localY);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    GraphicsMesh mesh = new GraphicsStroke(_path, width, jointStyle, capsStyle);
    _hit = _hit || mesh.hitTest(_localX, _localY);
  }

  @override
  void meshColor(GraphicsCommandMeshColor command) {
    GraphicsMesh mesh = command.mesh;
    _hit = _hit || mesh.hitTest(_localX, _localY);
  }

}
