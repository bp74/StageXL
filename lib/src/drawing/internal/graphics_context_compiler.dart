part of '../../drawing.dart';

class _GraphicsContextCompiler extends _GraphicsContextBase {
  final List<GraphicsCommand> commands;

  _GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    final mesh = _GraphicsPath.clone(_path);
    final command = _GraphicsCommandMeshColor(mesh, color);
    commands.add(command);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    final mesh = _GraphicsPath.clone(_path);
    final command = _GraphicsCommandMeshGradient(mesh, gradient);
    commands.add(command);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    final mesh = _GraphicsPath.clone(_path);
    final command = _GraphicsCommandMeshPattern(mesh, pattern);
    commands.add(command);
  }

  @override
  void strokeColor(
      int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    final mesh = _GraphicsStroke(_path, width, jointStyle, capsStyle);
    final command = _GraphicsCommandMeshColor(mesh, color);
    commands.add(command);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    final command = _GraphicsCommandMeshGradient(mesh, gradient);
    commands.add(command);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width,
      JointStyle jointStyle, CapsStyle capsStyle) {
    final _GraphicsMesh mesh =
        _GraphicsStroke(_path, width, jointStyle, capsStyle);
    final command = _GraphicsCommandMeshPattern(mesh, pattern);
    commands.add(command);
  }

  @override
  void meshColor(_GraphicsCommandMeshColor command) {
    commands.add(command);
  }

  @override
  void meshGradient(_GraphicsCommandMeshGradient command) {
    commands.add(command);
  }

  @override
  void meshPattern(_GraphicsCommandMeshPattern command) {
    commands.add(command);
  }
}
