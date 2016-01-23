part of stagexl.drawing;

/// The base class for all graphics stroke commands

abstract class GraphicsCommandStroke extends GraphicsCommand {

  double _width;
  JointStyle _jointStyle;
  CapsStyle _capsStyle;

  GraphicsCommandStroke(num width, JointStyle jointStyle, CapsStyle capsStyle)

      : _width = width.toDouble(),
        _jointStyle = jointStyle,
        _capsStyle = capsStyle;

  //---------------------------------------------------------------------------

  double get width => _width;

  set width(double value) {
    _width = value;
    _invalidate();
  }

  JointStyle get jointStyle => _jointStyle;

  set jointStyle(JointStyle value) {
    _jointStyle = value;
    _invalidate();
  }

  CapsStyle get capsStyle => _capsStyle;

  set capsStyle(CapsStyle value) {
    _capsStyle = value;
    _invalidate();
  }
}
