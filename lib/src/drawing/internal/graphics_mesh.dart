part of stagexl.drawing;

abstract class _GraphicsMesh<T extends _GraphicsMeshSegment> {

  final List<T> segments = new List<T>();

  bool hitTest(double x, double y);
  void fillColor(RenderState renderState, int color);
}
