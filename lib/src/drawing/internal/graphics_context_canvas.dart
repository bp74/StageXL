part of stagexl.drawing.internal;

class GraphicsContextCanvas extends GraphicsContext {

  final RenderState renderState;
  final RenderContextCanvas _renderContext;
  final CanvasRenderingContext2D _canvasContext;

  GraphicsContextCanvas(RenderState renderState) :
     renderState = renderState,
    _renderContext = renderState.renderContext,
    _canvasContext = (renderState.renderContext as RenderContextCanvas).rawContext {
    _renderContext.setTransform(renderState.globalMatrix);
    _renderContext.setAlpha(renderState.globalAlpha);
    _canvasContext.beginPath();
  }

  //---------------------------------------------------------------------------

  void beginPath() {
    _canvasContext.beginPath();
  }

  void closePath() {
    _canvasContext.closePath();
  }

  //---------------------------------------------------------------------------

  void moveTo(double x, double y) {
    _canvasContext.moveTo(x, y);
  }

  void lineTo(double x, double y) {
    _canvasContext.lineTo(x, y);
  }

  void rect(double x, double y, double width, double height) {
    _canvasContext.rect(x, y, width, height);
  }

  void rectRound(double x, double y, double width, double height, double ellipseWidth, double ellipseHeight) {
    _canvasContext.moveTo(x + ellipseWidth, y);
    _canvasContext.lineTo(x + width - ellipseWidth, y);
    _canvasContext.quadraticCurveTo(x + width, y, x + width, y + ellipseHeight);
    _canvasContext.lineTo(x + width, y + height - ellipseHeight);
    _canvasContext.quadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height);
    _canvasContext.lineTo(x + ellipseWidth, y + height);
    _canvasContext.quadraticCurveTo(x, y + height, x, y + height - ellipseHeight);
    _canvasContext.lineTo(x, y + ellipseHeight);
    _canvasContext.quadraticCurveTo(x, y, x + ellipseWidth, y);
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, bool antiClockwise) {
    _canvasContext.arc(x, y, radius, startAngle, endAngle, antiClockwise);
  }

  void arcTo(double controlX, double controlY, double endX, double endY, double radius) {
    _canvasContext.arcTo(controlX, controlY, endX, endY, radius);
  }

  void circle(double x, double y, double radius, bool antiClockwise) {
    _canvasContext.moveTo(x + radius, y);
    _canvasContext.arc(x, y, radius, 0, 2 * math.PI, antiClockwise);
  }

  void ellipse(double x, double y, double width, double height) {

    num kappa = 0.5522848;
    num ox = (width / 2) * kappa;
    num oy = (height / 2) * kappa;
    num x1 = x - width / 2;
    num y1 = y - height / 2;
    num x2 = x + width / 2;
    num y2 = y + height / 2;
    num xm = x;
    num ym = y;

    _canvasContext.moveTo(x1, ym);
    _canvasContext.bezierCurveTo(x1, ym - oy, xm - ox, y1, xm, y1);
    _canvasContext.bezierCurveTo(xm + ox, y1, x2, ym - oy, x2, ym);
    _canvasContext.bezierCurveTo(x2, ym + oy, xm + ox, y2, xm, y2);
    _canvasContext.bezierCurveTo(xm - ox, y2, x1, ym + oy, x1, ym);
  }

  void quadraticCurveTo(double controlX, double controlY, double endX, double endY) {
    _canvasContext.quadraticCurveTo(controlX, controlY, endX, endY);
  }

  void bezierCurveTo(double controlX1, double controlY1, double controlX2, double controlY2, double endX, double endY) {
    _canvasContext.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
  }

  //---------------------------------------------------------------------------

  void fillColor(int color) {
    _canvasContext.fillStyle = color2rgba(color);
    _canvasContext.fill();
  }

  void fillGradient(GraphicsGradient gradient) {
    _canvasContext.fillStyle = gradient.getCanvasGradient(_canvasContext);
    _canvasContext.fill();
  }

  void fillPattern(GraphicsPattern pattern) {

    _canvasContext.fillStyle = pattern.getCanvasPattern(_canvasContext);

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

  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    _canvasContext.strokeStyle = color2rgba(color);
    _canvasContext.lineWidth = lineWidth;
    _canvasContext.lineJoin = lineJoin;
    _canvasContext.lineCap = lineCap;
    _canvasContext.stroke();
  }

  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    _canvasContext.strokeStyle = gradient.getCanvasGradient(_canvasContext);
    _canvasContext.lineWidth = lineWidth;
    _canvasContext.lineJoin = lineJoin;
    _canvasContext.lineCap = lineCap;
    _canvasContext.stroke();
  }

  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {

    _canvasContext.strokeStyle = pattern.getCanvasPattern(_canvasContext);
    _canvasContext.lineWidth = lineWidth;
    _canvasContext.lineJoin = lineJoin;
    _canvasContext.lineCap = lineCap;

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

}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GraphicsContextCanvasMask extends GraphicsContextCanvas {

  GraphicsContextCanvasMask(RenderState renderState) : super(renderState);

  void fillColor(int color) {
    // do nothing
  }

  void fillGradient(GraphicsGradient gradient) {
    // do nothing
  }

  void fillPattern(GraphicsPattern pattern) {
    // do nothing
  }

  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }

  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }

  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // do nothing
  }
}
