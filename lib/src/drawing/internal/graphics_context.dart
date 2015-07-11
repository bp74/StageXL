part of stagexl.drawing.internal;

abstract class GraphicsContext {

  GraphicsPath _path = null;

  void applyGraphicsCommands(List<GraphicsCommand> commands) {
    for(int i = 0; i < commands.length; i++) {
      var command = commands[i];
      command.updateContext(this);
    }
  }

  //---------------------------------------------------------------------------

  void beginPath() {
    _path = new GraphicsPath();
  }

  void closePath() {
    // TODO: Close path
  }

  //---------------------------------------------------------------------------

  void moveTo(double x, double y) {
    _pathCheck();
    _path.moveTo(x, y);
  }

  void lineTo(double x, double y) {
    _pathCheck();
    _path.lineTo(x, y);
  }

  void rect(double x, double y, double width, double height) {
    _pathCheck();
    _path.moveTo(x, y);
    _path.lineTo(x, y);
    _path.lineTo(x + width, y);
    _path.lineTo(x + width, y + height);
    _path.lineTo(x, y + height);
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _pathCheck();
    // TODO: implement arc path
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _pathCheck();
    // TODO: implement arcTo path
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _pathCheck();
    // TODO: implement quadraticCurveTo path
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _pathCheck();
    // TODO: implement bezierCurveTo path
  }

  //---------------------------------------------------------------------------

  void fillColor(int color) {
    // override in derived class
  }

  void fillGradient(GraphicsGradient gradient) {
    // override in derived class
  }

  void fillPattern(GraphicsPattern pattern) {
    // override in derived class
  }

  //---------------------------------------------------------------------------

  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // override in derived class
  }

  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // override in derived class
  }

  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // override in derived class
  }

  //---------------------------------------------------------------------------

  void _pathCheck() {
    if (_path == null) _path = new GraphicsPath();
  }

}








