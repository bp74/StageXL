part of stagexl.drawing.internal;

class GraphicsContextCompiler extends GraphicsContext {

  final List<GraphicsCommand> commands;

  GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _compileCommandForFill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _compileCommandForFill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _compileCommandForFill();
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _compileCommandForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _compileCommandForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _compileCommandForStroke();
  }

  //---------------------------------------------------------------------------

  void _compileCommandForFill() {
    GraphicsCommandFill command = _command;
    command.mesh = new GraphicsPath.clone(_path);
    this.commands.add(command);
  }

  void _compileCommandForStroke() {
    GraphicsCommandStroke command = _command;
    command.mesh = new GraphicsStroke(_path, _command);
    this.commands.add(command);
  }

}
