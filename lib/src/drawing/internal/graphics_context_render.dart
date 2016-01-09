part of stagexl.drawing.internal;

class GraphicsContextRender extends GraphicsContextBase {

  final RenderState renderState;
  GraphicsContextRender(this.renderState);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, color);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    GraphicsMesh mesh = new GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.fillColor(renderState, color);
  }

  @override
  void meshColor(GraphicsCommandMeshColor command) {
    GraphicsMesh mesh = command.mesh;
    mesh.fillColor(renderState, command.color);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GraphicsContextRenderMask extends GraphicsContextRender {

  GraphicsContextRenderMask(RenderState renderState) : super(renderState);

  @override
  void fillColor(int color) {
    GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void strokeColor(int color, double lineWidth, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void meshColor(GraphicsCommandMeshColor command) {
    GraphicsMesh mesh = command.mesh;
    if (mesh is GraphicsStroke) return;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

}

