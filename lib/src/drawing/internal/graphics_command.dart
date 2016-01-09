part of stagexl.drawing.internal;

class GraphicsCommandMeshColor extends GraphicsCommand {

  final GraphicsMesh mesh;
  final int color;

  GraphicsCommandMeshColor(this.mesh, this.color);

  @override
  void updateContext(GraphicsContextBase context) {
    context.meshColor(this);
  }
}


