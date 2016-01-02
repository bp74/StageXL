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
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    var stroke = _stroke ?? new GraphicsStroke(_path, _command);
    stroke.fillColor(renderState, color);
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    this.strokeColor(0xFFFF00FF, width, jointStyle, capsStyle);
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {
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
  void strokeColor(int color, double lineWidth, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, JointStyle jointStyle, CapsStyle capsStyle) {
    // do nothing
  }
}

