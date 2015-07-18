part of stagexl.drawing.internal;

class GraphicsContextCompiler extends GraphicsContext {

  final List<GraphicsCommand> commands;

  GraphicsContextCompiler(this.commands);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _addCompiledCommands();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _addCompiledCommands();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _addCompiledCommands();
  }

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    _addCompiledCommands();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    _addCompiledCommands();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    _addCompiledCommands();
  }

  //---------------------------------------------------------------------------

  void _addCompiledCommands() {
    var path = _path.clone();
    var pathCommand = new GraphicsCommandSetPath(path);
    var drawCommand = _command;
    this.commands.add(pathCommand);
    this.commands.add(drawCommand);
  }
}
