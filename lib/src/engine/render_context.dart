part of stagexl;

class RenderEngine {
  static const String WebGL = "WebGL";
  static const String Canvas2D = "Canvas2D";
}

abstract class RenderContext extends EventDispatcher {

  static const EventStreamProvider<Event> contextLostEvent = const EventStreamProvider<Event>("contextLost");
  static const EventStreamProvider<Event> contextRestoredEvent = const EventStreamProvider<Event>("contextRestored");

  EventStream<Event> get onContextLost => RenderContext.contextLostEvent.forTarget(this);
  EventStream<Event> get onContextRestored => RenderContext.contextRestoredEvent.forTarget(this);

  String get renderEngine;
  Matrix get viewPortMatrix;

  String get globalCompositeOperation;
  set globalCompositeOperation(String value);

  num get globalAlpha;
  set globalAlpha(num value);

  void clear();
  void flush();

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix);
  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color);

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix);
  void endRenderMask(Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix);
  void endRenderShadow(Shadow shadow);
}