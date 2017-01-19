part of stagexl.drawing;

abstract class GraphicsContext {

  void beginPath();

  void closePath();

  //---------------------------------------------------------------------------

  void moveTo(double x, double y);

  void lineTo(double x, double y);

  void arcTo(double controlX, double controlY, double endX, double endY, double radius);

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY);

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY);

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise);

  void arcElliptical(double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle, bool antiClockwise);

  //---------------------------------------------------------------------------

  void fillColor(int color);

  void fillGradient(GraphicsGradient gradient);

  void fillPattern(GraphicsPattern pattern);

  //---------------------------------------------------------------------------

  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle);

  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle);

  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle);

}
