part of stagexl.drawing;

/// The base class for all graphics stroke commands

abstract class GraphicsCommandStroke extends GraphicsCommand {

  double _width = 1.0;
  JointStyle _jointStyle = JointStyle.MITER;
  CapsStyle _capsStyle = CapsStyle.NONE;

  GraphicsCommandStroke(double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _width = width;
    _jointStyle = jointStyle;
    _capsStyle = capsStyle;
  }

  //---------------------------------------------------------------------------

  double get width => _width;

  set width(double value) {
    _width = value;
    this.invalidate();
  }

  JointStyle get jointStyle => _jointStyle;

  set jointStyle(JointStyle value) {
    _jointStyle = value;
    this.invalidate();
  }

  CapsStyle get capsStyle => _capsStyle;

  set capsStyle(CapsStyle value) {
    _capsStyle = value;
    this.invalidate();
  }
}
