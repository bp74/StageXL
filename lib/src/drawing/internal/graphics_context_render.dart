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
    this.fillColor(0xFFFF00FF);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    this.fillColor(0xFFFF00FF);
  }

  //---------------------------------------------------------------------------

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    for (var segment in _path.segments) {
      var stroke = segment.calculateStroke(lineWidth, lineJoin, lineCap);
      stroke.fillColor(renderState, color);
    }
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    this.strokeColor(0xFFFF00FF, lineWidth, lineJoin, lineCap);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    this.strokeColor(0xFFFF00FF, lineWidth, lineJoin, lineCap);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GraphicsContextRenderMask extends GraphicsContextRender {

  GraphicsContextRenderMask(RenderState renderState) : super(renderState);

  @override
  void fillColor(int color) {
    _path.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _path.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _path.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }
}

