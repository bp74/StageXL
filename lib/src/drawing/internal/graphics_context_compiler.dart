part of stagexl.drawing.internal;

class GraphicsContextCompiler extends GraphicsContextBase {

  final List<GraphicsCommand> commands;

  GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    var mesh = new GraphicsPath.clone(_path);
    var command = new GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    var mesh = new GraphicsStroke(_path, width, jointStyle, capsStyle);
    var command = new GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void meshColor(GraphicsCommandMeshColor command) {
    this.commands.add(command);
  }

}
