part of stagexl.display;

abstract class BitmapFilter extends RenderFilter {

  BitmapFilter clone();

  Rectangle<int> get overlap => new Rectangle<int>(0, 0, 0, 0);
  List<int> get renderPassSources => const [0];
  List<int> get renderPassTargets => const [1];

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {
  }

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    renderState.renderQuad(renderTextureQuad);
  }
}
