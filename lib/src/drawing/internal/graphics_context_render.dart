part of stagexl.drawing.internal;

class GraphicsContextRender extends GraphicsContext {

  final RenderState renderState;
  GraphicsContextRender(this.renderState);

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    GraphicsCommandFill command = _command;
    GraphicsMesh mesh = command.mesh ?? _path;
    mesh.fillColor(renderState, color);
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
    GraphicsCommandStroke command = _command;
    GraphicsMesh mesh = command.mesh ?? new GraphicsStroke(_path, _command);
    mesh.fillColor(renderState, color);
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
    GraphicsCommandFill command = _command;
    GraphicsMesh mesh = command.mesh ?? _path;
    mesh.fillColor(renderState, 0xFFFF00FF);
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    this.fillColor(0xFFFF00FF);
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    this.fillColor(0xFFFF00FF);
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

