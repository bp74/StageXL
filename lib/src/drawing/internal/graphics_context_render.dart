part of stagexl.drawing.internal;

class GraphicsContextRender extends GraphicsContext {

  final RenderState renderState;
  GraphicsContextRender(this.renderState);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _path.fillColor(renderState, color);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    // TODO: implement render fillGradient
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    // TODO: implement render fillPattern
  }

  //---------------------------------------------------------------------------

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement render strokeColor
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement render strokeGradient
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // TODO: implement render strokePattern
  }

}
