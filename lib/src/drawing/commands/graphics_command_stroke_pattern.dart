part of stagexl.drawing;

class GraphicsCommandStrokePattern extends GraphicsCommandStroke {

  GraphicsPattern _pattern;

  GraphicsCommandStrokePattern(GraphicsPattern pattern,
      num width, JointStyle jointStyle, CapsStyle capsStyle)

      : _pattern = pattern,
        super(width, jointStyle, capsStyle);

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
