part of stagexl.engine;

abstract class RenderFilter {

  Rectangle<int> get overlap;
  List<int> get renderPassSources;
  List<int> get renderPassTargets;

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass);
}