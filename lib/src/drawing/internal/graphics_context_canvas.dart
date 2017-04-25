part of stagexl.drawing;

class _GraphicsContextCanvas extends GraphicsContext {

  final RenderState renderState;
  final RenderContextCanvas _renderContext;
  final CanvasRenderingContext2D _canvasContext;

  _GraphicsContextCanvas(RenderState renderState) :
     renderState = renderState,
    _renderContext = renderState.renderContext as RenderContextCanvas,
    _canvasContext = (renderState.renderContext as RenderContextCanvas).rawContext {
    _renderContext.setTransform(renderState.globalMatrix);
    _renderContext.setAlpha(renderState.globalAlpha);
    _canvasContext.beginPath();
  }

  //---------------------------------------------------------------------------

  @override
  void beginPath() {
    _canvasContext.beginPath();
  }

  @override
  void closePath() {
    _canvasContext.closePath();
  }

  //---------------------------------------------------------------------------

  @override
  void moveTo(double x, double y) {
    _canvasContext.moveTo(x, y);
  }

  @override
  void lineTo(double x, double y) {
    _canvasContext.lineTo(x, y);
  }

  @override
  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _canvasContext.arcTo(controlX, controlY, endX, endY, radius);
  }

  @override
  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _canvasContext.quadraticCurveTo(controlX, controlY, endX, endY);
  }

  @override
  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _canvasContext.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

  @override
  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _canvasContext.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

  @override
  void arcElliptical(double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle, bool antiClockwise) {
    _canvasContext.translate(x, y);
    _canvasContext.rotate(rotation);
    _canvasContext.scale(radiusX, radiusY);
    _canvasContext.arc(0.0, 0.0, 1.0, startAngle, endAngle, antiClockwise);
    _canvasContext.scale(1.0 / radiusX, 1.0 / radiusY);
    _canvasContext.rotate(0.0 - rotation);
    _canvasContext.translate(0.0 - x, 0.0 - y);
  }

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _canvasContext.fillStyle = color2rgba(color);
    _canvasContext.fill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _canvasContext.fillStyle = _getCanvasGradient(gradient);
    _canvasContext.fill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {

    _canvasContext.fillStyle = _getCanvasPattern(pattern);

    var matrix = pattern.matrix;
    if (matrix != null) {
      _canvasContext.save();
      _canvasContext.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      _canvasContext.fill();
      _canvasContext.restore();
    } else {
      _canvasContext.fill();
    }
  }

  //---------------------------------------------------------------------------

  @override
  void strokeColor(int color, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _canvasContext.strokeStyle = color2rgba(color);
    _canvasContext.lineWidth = width;
    _canvasContext.lineJoin = _getLineJoin(jointStyle);
    _canvasContext.lineCap = _getLineCap(capsStyle);
    _canvasContext.stroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, JointStyle jointStyle, CapsStyle capsStyle) {
    _canvasContext.strokeStyle = _getCanvasGradient(gradient);
    _canvasContext.lineWidth = width;
    _canvasContext.lineJoin = _getLineJoin(jointStyle);
    _canvasContext.lineCap = _getLineCap(capsStyle);
    _canvasContext.stroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, JointStyle jointStyle, CapsStyle capsStyle) {

    _canvasContext.strokeStyle = _getCanvasPattern(pattern);
    _canvasContext.lineWidth = width;
    _canvasContext.lineJoin = _getLineJoin(jointStyle);
    _canvasContext.lineCap = _getLineCap(capsStyle);

    var matrix = pattern.matrix;
    if (matrix != null) {
      _canvasContext.save();
      _canvasContext.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      _canvasContext.stroke();
      _canvasContext.restore();
    } else {
      _canvasContext.stroke();
    }
  }

  //---------------------------------------------------------------------------

  String _getLineJoin(JointStyle jointStyle) {
    var lineJoin = "round";
    if (jointStyle == JointStyle.MITER) lineJoin = "miter";
    if (jointStyle == JointStyle.BEVEL) lineJoin = "bevel";
    return lineJoin;
  }

  String _getLineCap(CapsStyle capsStyle) {
    var lineCap = "round";
    if (capsStyle == CapsStyle.NONE) lineCap = "butt";
    if (capsStyle == CapsStyle.SQUARE) lineCap = "square";
    return lineCap;
  }

  CanvasPattern _getCanvasPattern(GraphicsPattern pattern) {
    return pattern.getCanvasPattern(_canvasContext);
  }

  CanvasGradient _getCanvasGradient(GraphicsGradient gradient) {
    return gradient.getCanvasGradient(_canvasContext);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _GraphicsContextCanvasMask extends _GraphicsContextCanvas {

  _GraphicsContextCanvasMask(RenderState renderState) : super(renderState);

  @override
  void fillColor(int color) {
    // do nothing
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    // do nothing
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    // do nothing
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
