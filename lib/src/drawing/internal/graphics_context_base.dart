part of stagexl.drawing;

abstract class _GraphicsContextBase extends GraphicsContext {

  _GraphicsPath _path = new _GraphicsPath();

  @override
  void beginPath() {
    _path = new _GraphicsPath();
  }

  @override
  void closePath() {
    _path.close();
  }

  @override
  void moveTo(double x, double y) {
    _path.moveTo(x, y);
  }

  @override
  void lineTo(double x, double y) {
    _path.lineTo(x, y);
  }

  @override
  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _path.arcTo(controlX, controlY, endX, endY, radius);
  }

  @override
  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _path.quadraticCurveTo(controlX, controlY, endX, endY);
  }

  @override
  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _path.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

  @override
  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _path.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

  @override
  void arcElliptical(
      double x, double y, double radiusX, double radiusY, double rotation,
      double startAngle, double endAngle, bool antiClockwise) {

    _path.arcElliptical(x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
  }

  //---------------------------------------------------------------------------

  @override
  void fillGradient(GraphicsGradient gradient) {
    // TODO: Currently fillGradient is only supported in Canvas2D
    this.fillColor(0xFFFF00FF);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    // TODO: Currently fillPattern is only supported in Canvas2D
    this.fillColor(0xFFFF00FF);
  }

  //---------------------------------------------------------------------------

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    // TODO: Currently strokeGradient is only supported in Canvas2D
    this.strokeColor(0xFFFF00FF, width, jointStyle, capsStyle);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    // TODO: Currently strokePattern is only supported in Canvas2D
    this.strokeColor(0xFFFF00FF, width, jointStyle, capsStyle);
  }

  //---------------------------------------------------------------------------

  void meshColor(_GraphicsCommandMeshColor command);

}
