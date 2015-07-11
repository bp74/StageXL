part of stagexl.drawing.internal;

abstract class GraphicsContext {

  GraphicsPath _path = new GraphicsPath();

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
    _path.moveTo(x, y);
  }

  void lineTo(double x, double y) {
    _path.lineTo(x, y);
  }

  void rect(double x, double y, double width, double height) {
    _path.moveTo(x, y);
    _path.lineTo(x, y);
    _path.lineTo(x + width, y);
    _path.lineTo(x + width, y + height);
    _path.lineTo(x, y + height);
  }

  void rectRound(double x, double y, double width, double height, double ellipseWidth, double ellipseHeight) {
    _path.moveTo(x + ellipseWidth, y);
    _path.lineTo(x + width - ellipseWidth, y);
    _path.quadraticCurveTo(x + width, y, x + width, y + ellipseHeight);
    _path.lineTo(x + width, y + height - ellipseHeight);
    _path.quadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height);
    _path.lineTo(x + ellipseWidth, y + height);
    _path.quadraticCurveTo(x, y + height, x, y + height - ellipseHeight);
    _path.lineTo(x, y + ellipseHeight);
    _path.quadraticCurveTo(x, y, x + ellipseWidth, y);
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _path.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _path.arcTo(controlX, controlY, endX, endY, radius);
  }

  void circle(double x, double y, double radius, bool antiClockwise) {
    _path.circle(x, y, radius, antiClockwise);
  }

  void ellipse(double x, double y, double width, double height) {
    _path.ellipse(x, y, width, height);
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _path.quadraticCurveTo(controlX, controlY, endX, endY);
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _path.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
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








