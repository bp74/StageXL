part of stagexl;

class RenderEngine {
  static const String WebGL = "WebGL";
  static const String Canvas2D = "Canvas2D";
}

abstract class RenderContext {

  String get renderEngine;

  void clear();
  void flush();

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha);
  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color);

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix);
  void endRenderMask(Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix);
  void endRenderShadow(Shadow shadow);

  Matrix get viewPortMatrix;
}