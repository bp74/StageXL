part of '../../drawing.dart';

class GraphicsCommandStrokeGradient extends GraphicsCommandStroke {
  GraphicsGradient _gradient;

  GraphicsCommandStrokeGradient(
      GraphicsGradient gradient, super.width, super.jointStyle, super.capsStyle)
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
    context.strokeGradient(gradient, width, jointStyle, capsStyle);
  }
}
