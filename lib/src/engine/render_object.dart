part of stagexl.engine;

/// The abstract [RenderObject] class defines the interface for a class
/// that can be rendered with the [RenderState.renderObject] method. All
/// DisplayObjects do implement this interface and therefore they can be
/// rendered by the engine.

abstract class RenderObject {

  Matrix get transformationMatrix;
  BlendMode get blendMode;
  num get alpha;

  List<RenderFilter> get filters;
  RenderTextureQuad get cache;
  RenderMask get mask;

  Rectangle<num> get bounds;

  void render(RenderState renderState);
  void renderFiltered(RenderState renderState);
}

/// This class is as a wrapper for a [RenderTextureQuad] to be used with
/// the [RenderContext.renderObjectFiltered] method. It is necessary as a
/// fallback if the [RenderTextureQuad] can't be rendered in the fast path.

class _RenderTextureQuadObject implements RenderObject {

  final RenderTextureQuad renderTextureQuad;
  final List<RenderFilter> filters;
  final Matrix transformationMatrix = new Matrix.fromIdentity();
  final BlendMode blendMode = BlendMode.NORMAL;
  final RenderTextureQuad cache = null;
  final RenderMask mask = null;
  final num alpha = 1.0;

  _RenderTextureQuadObject(this.renderTextureQuad, this.filters);

  Rectangle<num> get bounds => new Rectangle<num>(
      renderTextureQuad.offsetX, renderTextureQuad.offsetY,
      renderTextureQuad.textureWidth, renderTextureQuad.textureHeight);

  void render(RenderState renderState) {
    renderState.renderQuad(this.renderTextureQuad);
  }

  void renderFiltered(RenderState renderState) {
    renderState.renderQuad(this.renderTextureQuad);
  }
}
