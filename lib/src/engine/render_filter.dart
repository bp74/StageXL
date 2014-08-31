part of stagexl.engine;

/// The abstract [RenderFilter] class defines the interface for filters
/// that can be rendered by the engine.
///
abstract class RenderFilter {

  Rectangle<int> get overlap;
  List<int> get renderPassSources;
  List<int> get renderPassTargets;

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass);
}