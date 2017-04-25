part of stagexl.drawing;

class _GraphicsCommandMeshColor extends GraphicsCommand {

  final _GraphicsMesh mesh;
  final int color;

  _GraphicsCommandMeshColor(this.mesh, this.color);

  @override
  void updateContext(GraphicsContext context) {
    if (context is _GraphicsContextBase) {
      context.meshColor(this);
    }
  }
}

class _GraphicsCommandMeshGradient extends GraphicsCommand {

  final _GraphicsMesh mesh;
  final GraphicsGradient gradient;

  _GraphicsCommandMeshGradient(this.mesh, this.gradient);

  @override
  void updateContext(GraphicsContext context) {
    if (context is _GraphicsContextBase) {
      context.meshGradient(this);
    }
  }
}

class _GraphicsCommandMeshPattern extends GraphicsCommand {

  final _GraphicsMesh mesh;
  final GraphicsPattern pattern;

  _GraphicsCommandMeshPattern(this.mesh, this.pattern);

  @override
  void updateContext(GraphicsContext context) {
    if (context is _GraphicsContextBase) {
      context.meshPattern(this);
    }
  }
}
