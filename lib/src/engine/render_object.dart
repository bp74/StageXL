part of stagexl.engine;

/// The abstract [RenderObject] class defines the interface for a class
/// that can be rendered with the [RenderState.renderObject] method. All
/// display objects do implement this interface and therefore they can be
/// rendered by the engine.

abstract class RenderObject {

  Matrix get transformationMatrix;
  BlendMode get blendMode;
  num get alpha;

  List<RenderFilter> get filters;
  RenderTextureQuad get cache;
  RenderMask get mask;

  Rectangle<num> get bounds;

  void render(RenderState renderState);
  void renderFiltered(RenderState renderState);
}

/// The abstract [RenderObject3D] class adds a 3D projection matrix to
/// the [RenderObject] class. Only display objects with 3D capabilities
/// will implement this class.

abstract class RenderObject3D extends RenderObject {
  Matrix3D get transformationMatrix3D;
  Matrix3D get projectionMatrix3D;
}

/// This class is as a wrapper for a [RenderTextureQuad] to be used with
/// the [RenderContext.renderObjectFiltered] method. It is necessary as a
/// fallback if the [RenderTextureQuad] can't be rendered in the fast path.

class _RenderTextureQuadObject implements RenderObject {

  final RenderTextureQuad renderTextureQuad;

  @override
  final List<RenderFilter> filters;

  @override
  final Matrix transformationMatrix = new Matrix.fromIdentity();

  @override
  final BlendMode blendMode = BlendMode.NORMAL;

  @override
  final RenderTextureQuad cache;

  @override
  final RenderMask mask;

  @override
  final num alpha = 1.0;

  _RenderTextureQuadObject(this.renderTextureQuad, this.filters)
      : mask = null,
        cache = null;

  @override
  Rectangle<num> get bounds {
    num w = renderTextureQuad.targetWidth;
    num h = renderTextureQuad.targetHeight;
    return new Rectangle<num>(0.0, 0.0, w, h);
  }

  @override
  void render(RenderState renderState) {
    renderState.renderTextureQuad(this.renderTextureQuad);
  }

  @override
  void renderFiltered(RenderState renderState) {
    renderState.renderTextureQuad(this.renderTextureQuad);
  }
}
