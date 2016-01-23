part of stagexl.drawing;

class _GraphicsCommandMeshColor extends GraphicsCommand {

  final _GraphicsMesh mesh;
  final int color;

  _GraphicsCommandMeshColor(this.mesh, this.color);

  @override
  void updateContext(_GraphicsContextBase context) {
    context.meshColor(this);
  }
}


