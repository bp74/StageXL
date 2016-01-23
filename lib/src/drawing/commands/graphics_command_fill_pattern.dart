part of stagexl.drawing;

class GraphicsCommandFillPattern extends GraphicsCommandFill {

  GraphicsPattern _pattern;

  GraphicsCommandFillPattern(GraphicsPattern pattern)
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
    context.fillPattern(pattern);
  }

}
