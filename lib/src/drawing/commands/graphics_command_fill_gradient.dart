part of stagexl.drawing;

class GraphicsCommandFillGradient extends GraphicsCommandFill {

  GraphicsGradient _gradient;

  GraphicsCommandFillGradient(GraphicsGradient gradient)
      : _gradient = gradient;

  //---------------------------------------------------------------------------

  GraphicsGradient get gradient => _gradient;

  set gradient(GraphicsGradient value) {
    _gradient = value;
    _invalidate();
  }

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillGradient(gradient);
  }

}
