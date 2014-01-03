part of stagexl;

abstract class RenderContext {

  void clear();
  void flush();
  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad);

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix);
  void endRenderMask(Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix);
  void endRenderShadow(Shadow shadow);
}