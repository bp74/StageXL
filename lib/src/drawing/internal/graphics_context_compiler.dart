part of stagexl.drawing;

class _GraphicsContextCompiler extends _GraphicsContextBase {

  final List<GraphicsCommand> commands;

  _GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    var mesh = new _GraphicsPath.clone(_path);
    var command = new _GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    var mesh = new _GraphicsStroke(_path, width, jointStyle, capsStyle);
    var command = new _GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    this.commands.add(command);
  }

}
