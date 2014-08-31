part of stagexl.engine;

/// The abstract [RenderMask] class defines the interface for masks
/// that can be rendered by the engine.
///
abstract class RenderMask {

  bool get relativeToParent;

  bool get border;
  int get borderColor;
  int get borderWidth;

  void renderMask(RenderState renderState);
}