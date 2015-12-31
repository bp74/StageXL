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
    _addCommandsForStroke(lineWidth, lineJoin, lineCap);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    _addCommandsForStroke(lineWidth, lineJoin, lineCap);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    _addCommandsForStroke(lineWidth, lineJoin, lineCap);
  }

  //---------------------------------------------------------------------------

  void _addCommandsForFill() {
    var path = _path.clone();
    var pathCommand = new GraphicsCommandSetPath(path);
    var drawCommand = _command;
    this.commands.add(pathCommand);
    this.commands.add(drawCommand);
  }

  void _addCommandsForStroke(double lineWidth, String lineJoin, String lineCap) {
    var stroke = _path.calculateStroke(lineWidth, lineJoin, lineCap);
    var strokeCommand = new GraphicsCommandSetStroke(stroke);
    var drawCommand = _command;
    this.commands.add(strokeCommand);
    this.commands.add(drawCommand);
  }

}
