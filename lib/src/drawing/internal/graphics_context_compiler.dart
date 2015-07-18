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
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    _addCommandsForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    _addCommandsForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    _addCommandsForStroke();
  }

  //---------------------------------------------------------------------------

  void _addCommandsForFill() {
    var path = _path.clone();
    var pathCommand = new GraphicsCommandSetPath(path);
    var drawCommand = _command;
    this.commands.add(pathCommand);
    this.commands.add(drawCommand);
  }

  void _addCommandsForStroke() {
    // TODO: revisit this code once we have stroke paths.
    var path = _path.clone();
    var pathCommand = new GraphicsCommandSetPath(path);
    var drawCommand = _command;
    this.commands.add(pathCommand);
    this.commands.add(drawCommand);
  }

}
