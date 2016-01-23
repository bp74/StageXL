part of stagexl.drawing;

class _GraphicsContextRender extends _GraphicsContextBase {

  final RenderState renderState;

  _GraphicsContextRender(this.renderState);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, color);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _GraphicsMesh mesh = new _GraphicsStroke(_path, width, jointStyle, capsStyle);
    mesh.fillColor(renderState, color);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    _GraphicsMesh mesh = command.mesh;
    mesh.fillColor(renderState, command.color);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GraphicsContextRenderMask extends _GraphicsContextRender {

  GraphicsContextRenderMask(RenderState renderState) : super(renderState);

  @override
  void fillColor(int color) {
    _GraphicsMesh mesh = _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void strokeColor(int color, double lineWidth, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    _GraphicsMesh mesh = command.mesh;
    if (mesh is _GraphicsStroke) return;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

}

