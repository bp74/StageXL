part of stagexl.drawing;

abstract class _GraphicsMesh {

  final List<_GraphicsMeshSegment> segments = new List<_GraphicsMeshSegment>();

  bool hitTest(double x, double y);
  void fillColor(RenderState renderState, int color);
}
