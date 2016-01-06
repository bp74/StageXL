part of stagexl.drawing.internal;

class GraphicsContextCompiler extends GraphicsContext {

  final List<GraphicsCommand> commands;

  GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _addCommandsForFill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _addCommandsForFill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _addCommandsForFill();
  }

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _addCommandsForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _addCommandsForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _addCommandsForStroke();
  }

  //---------------------------------------------------------------------------

  void _addCommandsForFill() {
    GraphicsCommandFill command = _command;
    command.mesh = new GraphicsPath.clone(_path);
    this.commands.add(command);
  }

  void _addCommandsForStroke() {
    GraphicsCommandStroke command = _command;
    command.mesh = new GraphicsStroke(_path, _command);
    this.commands.add(command);
  }

}
