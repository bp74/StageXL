part of stagexl;

abstract class RenderContext {

  void clear();
  void flush();

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha);
  void renderTriangle(Point p1, Point p2, Point p3, Matrix matrix, int color);

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix);
  void endRenderMask(Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix);
  void endRenderShadow(Shadow shadow);
}