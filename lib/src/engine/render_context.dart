part of stagexl;

abstract class RenderContext {

  void clear();
  void flush();

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha);
  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color);

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix);
  void endRenderMask(Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix);
  void endRenderShadow(Shadow shadow);
}