part of stagexl.drawing.internal;

abstract class GraphicsContext {

  GraphicsPath _path = new GraphicsPath();
  GraphicsCommand _command = null;

  void applyGraphicsCommands(List<GraphicsCommand> commands) {
    for(int i = 0; i < commands.length; i++) {
      _command = commands[i];
      _command.updateContext(this);
    }
  }

  //---------------------------------------------------------------------------

  void beginPath() {
    _path = new GraphicsPath();
  }

  void closePath() {
    _path.close();
  }

  void setPath(GraphicsPath path) {
    _path = path;
  }

  //---------------------------------------------------------------------------

  void moveTo(double x, double y) {
    _path.moveTo(x, y);
  }

  void lineTo(double x, double y) {
    _path.lineTo(x, y);
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _path.arcTo(controlX, controlY, endX, endY, radius);
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _path.quadraticCurveTo(controlX, controlY, endX, endY);
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _path.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

  void rect(double x, double y, double width, double height) {
    _path.rect(x, y, width, height);
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _path.arc(x, y, radius, startAngle, endAngle, antiClockwise);
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

}








