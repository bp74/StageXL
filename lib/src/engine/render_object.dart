part of stagexl.engine;

/// The abstract [RenderObject] class defines the interface for a class
/// that can be rendered with the [RenderState.renderObject] method. All
/// DisplayObjects do implement this interface and therefore they can be
/// rendered by the engine.
///
abstract class RenderObject {

  Matrix get transformationMatrix;
  BlendMode get blendMode;
  num get alpha;

  List<RenderFilter> get filters;
  RenderTextureQuad get cache;
  RenderMask get mask;

  Rectangle<num> get bounds;

  void render(RenderState renderState);
}