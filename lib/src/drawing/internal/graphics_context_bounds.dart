part of stagexl.drawing.internal;

class GraphicsContextBounds extends GraphicsContextBase {

  double _minX = 0.0 + double.MAX_FINITE;
  double _minY = 0.0 + double.MAX_FINITE;
  double _maxX = 0.0 - double.MAX_FINITE;
  double _maxY = 0.0 - double.MAX_FINITE;

  //---------------------------------------------------------------------------

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;

  Rectangle<num> get bounds {
    if (minX < maxX && minY < maxY) {
      return new Rectangle<double>(minX, minY, maxX - minX, maxY - minY);
    } else {
      return new Rectangle<double>(0.0, 0.0, 0.0, 0.0);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    GraphicsMesh mesh = new GraphicsPath.clone(_path);
    mesh.segments.forEach(_updateBoundsForMesh);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    GraphicsMesh mesh = new GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.segments.forEach(_updateBoundsForMesh);
  }

  @override
  void meshColor(GraphicsCommandMeshColor command) {
    GraphicsMesh mesh = command.mesh;
    mesh.segments.forEach(_updateBoundsForMesh);
  }

  //---------------------------------------------------------------------------

  void _updateBoundsForMesh(GraphicsMeshSegment mesh) {
    _minX = _minX > mesh.minX ? mesh.minX : _minX;
    _minY = _minY > mesh.minY ? mesh.minY : _minY;
    _maxX = _maxX < mesh.maxX ? mesh.maxX : _maxX;
    _maxY = _maxY < mesh.maxY ? mesh.maxY : _maxY;
  }

}
