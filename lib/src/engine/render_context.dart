part of stagexl.engine;

class RenderEngine {
  static const String WebGL = "WebGL";
  static const String Canvas2D = "Canvas2D";
}

class RenderContextEvent {

}

abstract class RenderContext {

  final _contextLostEvent = new StreamController<RenderContextEvent>.broadcast();
  final _contextRestoredEvent = new StreamController<RenderContextEvent>.broadcast();

  Stream<RenderContextEvent> get onContextLost => _contextLostEvent.stream;
  Stream<RenderContextEvent> get onContextRestored => _contextRestoredEvent.stream;

  String get renderEngine;

  void reset();
  void clear(int color);
  void flush();

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad);
  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2, num x3, num y3, int color);

  void beginRenderMask(RenderState renderState, RenderMask mask);
  void endRenderMask(RenderState renderState, RenderMask mask);
}
