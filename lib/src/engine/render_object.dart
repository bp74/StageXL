part of stagexl.engine;

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