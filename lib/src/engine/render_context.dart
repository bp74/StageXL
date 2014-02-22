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

  void reset();
  void clear(int color);
  void flush();

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad);
  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2, num x3, num y3, int color);

  void beginRenderMask(RenderState renderState, Mask mask);
  void endRenderMask(RenderState renderState, Mask mask);

  void beginRenderShadow(RenderState renderState, Shadow shadow);
  void endRenderShadow(RenderState renderState, Shadow shadow);
}