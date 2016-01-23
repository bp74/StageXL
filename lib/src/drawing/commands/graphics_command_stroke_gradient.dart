part of stagexl.drawing;

class GraphicsCommandStrokeGradient extends GraphicsCommandStroke {

  GraphicsGradient _gradient;

  GraphicsCommandStrokeGradient(GraphicsGradient gradient,
      num width, JointStyle jointStyle, CapsStyle capsStyle)

      : _gradient = gradient,
        super(width, jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  GraphicsGradient get gradient => _gradient;

  set gradient(GraphicsGradient value) {
    _gradient = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeGradient(gradient, width, jointStyle, capsStyle);
  }

}
