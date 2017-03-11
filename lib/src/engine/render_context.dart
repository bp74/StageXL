part of stagexl.engine;

/// The implementation kind of the render context.

enum RenderEngine { WebGL , Canvas2D  }

/// The base class for all events fired by a render context.

class RenderContextEvent { }

/// The interface for all implementations of a render context.

abstract class RenderContext {

  final RenderStatistics renderStatistics = new RenderStatistics();

  final _contextLostEvent = new StreamController<RenderContextEvent>.broadcast();
  final _contextRestoredEvent = new StreamController<RenderContextEvent>.broadcast();

  Stream<RenderContextEvent> get onContextLost => _contextLostEvent.stream;
  Stream<RenderContextEvent> get onContextRestored => _contextRestoredEvent.stream;

  RenderEngine get renderEngine;

  void reset();
  void clear(int color);
  void flush();

  void beginRenderMask(RenderState renderState, RenderMask mask);
  void endRenderMask(RenderState renderState, RenderMask mask);

  //---------------------------------------------------------------------------

  void renderTextureQuad(
     RenderState renderState, RenderTextureQuad renderTextureQuad);

  void renderGradientMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, GraphicsGradient gradient);

  void renderPatternMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, GraphicsPattern pattern);

  void renderTextureMesh(
      RenderState renderState, RenderTexture renderTexture,
      Int16List ixList, Float32List vxList);

  void renderTriangle(
      RenderState renderState,
      num x1, num y1, num x2, num y2, num x3, num y3, int color);

  void renderTriangleMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, int color);

  void renderTextureQuadFiltered(
      RenderState renderState, RenderTextureQuad renderTextureQuad,
      List<RenderFilter> renderFilters);

  void renderObjectFiltered(
      RenderState renderState, RenderObject renderObject);

}
