part of stagexl.drawing.internal;

abstract class GraphicsMesh {

  final List<GraphicsMeshSegment> segments = new List<GraphicsMeshSegment>();

  bool hitTest(double x, double y);
  void fillColor(RenderState renderState, int color);
}
