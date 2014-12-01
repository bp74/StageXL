part of stagexl.drawing;

class _GraphicsCommandFillGradient extends _GraphicsCommandFill {

  GraphicsGradient _gradient;

  _GraphicsCommandFillGradient(GraphicsGradient gradient) {
    _gradient = gradient;
  }

  render(CanvasRenderingContext2D context) {
    context.fillStyle = _gradient.getCanvasGradient(context);
    context.fill();
  }
}
