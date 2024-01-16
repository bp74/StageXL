part of '../../drawing.dart';

class GraphicsCommandStrokePattern extends GraphicsCommandStroke {
  GraphicsPattern _pattern;

  GraphicsCommandStrokePattern(
      GraphicsPattern pattern, super.width, super.jointStyle, super.capsStyle)
      : _pattern = pattern;

  //---------------------------------------------------------------------------

  GraphicsPattern get pattern => _pattern;

  set pattern(GraphicsPattern value) {
    _pattern = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokePattern(pattern, width, jointStyle, capsStyle);
  }
}
