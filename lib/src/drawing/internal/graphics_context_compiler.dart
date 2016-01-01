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
  void strokeColor(int color, double width, String jointStyle, String capsStyle) {
    _addCommandsForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, String jointStyle, String capsStyle) {
    _addCommandsForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, String jointStyle, String capsStyle) {
    _addCommandsForStroke();
  }

  //---------------------------------------------------------------------------

  void _addCommandsForFill() {
    var path = new GraphicsPath.clone(_path);
    var pathCommand = new GraphicsCommandSetPath(path);
    var drawCommand = _command;
    this.commands.add(pathCommand);
    this.commands.add(drawCommand);
  }

  void _addCommandsForStroke() {
    var stroke = new GraphicsStroke(_path, _command);
    var strokeCommand = new GraphicsCommandSetStroke(stroke);
    var drawCommand = _command;
    this.commands.add(strokeCommand);
    this.commands.add(drawCommand);
  }

}
