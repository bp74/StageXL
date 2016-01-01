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
  void strokeColor(int color, double width, String jointStyle, String capsStyle) {
    var stroke = _stroke ?? new GraphicsStroke(_path, _command);
    stroke.fillColor(renderState, color);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, String jointStyle, String capsStyle) {
    this.strokeColor(0xFFFF00FF, width, jointStyle, capsStyle);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, String jointStyle, String capsStyle) {
    this.strokeColor(0xFFFF00FF, width, jointStyle, capsStyle);
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

