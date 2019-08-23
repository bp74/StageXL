part of stagexl.drawing;

class _GraphicsContextCompiler extends _GraphicsContextBase {
  final List<GraphicsCommand> commands;

  _GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    var mesh = _GraphicsPath.clone(_path);
    var command = _GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    var mesh = _GraphicsPath.clone(_path);
    var command = _GraphicsCommandMeshGradient(mesh, gradient);
    this.commands.add(command);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    var mesh = _GraphicsPath.clone(_path);
    var command = _GraphicsCommandMeshPattern(mesh, pattern);
    this.commands.add(command);
  }

  @override
  void strokeColor(
      int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    var mesh = _GraphicsStroke(_path, width, jointStyle, capsStyle);
    var command = _GraphicsCommandMeshColor(mesh, color);
    this.commands.add(command);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    _GraphicsMesh mesh = _GraphicsStroke(_path, width, jointStyle, capsStyle);
    var command = _GraphicsCommandMeshGradient(mesh, gradient);
    this.commands.add(command);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    _GraphicsMesh mesh = _GraphicsStroke(_path, width, jointStyle, capsStyle);
    var command = _GraphicsCommandMeshPattern(mesh, pattern);
    this.commands.add(command);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    this.commands.add(command);
  }

  @override
  void meshGradient(_GraphicsCommandMeshGradient command) {
    this.commands.add(command);
  }

  @override
  void meshPattern(_GraphicsCommandMeshPattern command) {
    this.commands.add(command);
  }
}
