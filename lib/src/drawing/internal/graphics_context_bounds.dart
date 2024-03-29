part of '../../drawing.dart';

class _GraphicsContextBounds extends _GraphicsContextBase {
  double _minX = 0.0 + double.maxFinite;
  double _minY = 0.0 + double.maxFinite;
  double _maxX = 0.0 - double.maxFinite;
  double _maxY = 0.0 - double.maxFinite;

  //---------------------------------------------------------------------------

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;

  Rectangle<num> get bounds {
    if (minX < maxX && minY < maxY) {
      return Rectangle<num>(minX, minY, maxX - minX, maxY - minY);
    } else {
      return Rectangle<num>(0.0, 0.0, 0.0, 0.0);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    final _GraphicsMesh mesh = _path;
    _updateBoundsForMesh(mesh);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    final _GraphicsMesh mesh = _path;
    _updateBoundsForMesh(mesh);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    final _GraphicsMesh mesh = _path;
    _updateBoundsForMesh(mesh);
  }

  @override
  void strokeColor(
      int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    _updateBoundsForMesh(mesh);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    _updateBoundsForMesh(mesh);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    _updateBoundsForMesh(mesh);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    final mesh = command.mesh;
    _updateBoundsForMesh(mesh);
  }

  @override
  void meshGradient(_GraphicsCommandMeshGradient command) {
    final mesh = command.mesh;
    _updateBoundsForMesh(mesh);
  }

  @override
  void meshPattern(_GraphicsCommandMeshPattern command) {
    final mesh = command.mesh;
    _updateBoundsForMesh(mesh);
  }

  //---------------------------------------------------------------------------

  void _updateBoundsForMesh(_GraphicsMesh mesh) {
    for (var meshSegment in mesh.segments) {
      _minX = _minX > meshSegment.minX ? meshSegment.minX : _minX;
      _minY = _minY > meshSegment.minY ? meshSegment.minY : _minY;
      _maxX = _maxX < meshSegment.maxX ? meshSegment.maxX : _maxX;
      _maxY = _maxY < meshSegment.maxY ? meshSegment.maxY : _maxY;
    }
  }
}
