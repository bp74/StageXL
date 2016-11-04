part of stagexl.display;

abstract class BitmapFilter extends RenderFilter {

  BitmapFilter clone();

  @override
  Rectangle<int> get overlap => new Rectangle<int>(0, 0, 0, 0);

  @override
  List<int> get renderPassSources => const [0];

  @override
  List<int> get renderPassTargets => const [1];

  void apply(BitmapData bitmapData, [Rectangle<num> rectangle]) {
    // do nothing by default
  }

  @override
  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    renderState.renderTextureQuad(renderTextureQuad);
  }
}
