part of stagexl.engine;

/// The abstract [RenderMask] class defines the interface for masks
/// that can be rendered by the engine.

abstract class RenderMask {

  bool get relativeToParent;

  bool get border;
  int get borderColor;
  int get borderWidth;

  void renderMask(RenderState renderState);
}

//------------------------------------------------------------------------------

/// A specialized [RenderMask] that supports the WebGL scissor feature.

abstract class ScissorRenderMask implements RenderMask {
  Rectangle<num> getScissorRectangle(RenderState renderState);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class _MaskState {
  final RenderMask mask;
  _MaskState(this.mask);
}

class _StencilMaskState extends _MaskState {
  final int value;
  _StencilMaskState(RenderMask mask, this.value) : super(mask);
}

class _ScissorMaskState extends _MaskState {
  final Rectangle<num> value;
  _ScissorMaskState(RenderMask mask, this.value) : super(mask);
}
