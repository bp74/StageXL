part of stagexl;

abstract class RenderContext {

  void clear();
  void flush();
  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad);

}