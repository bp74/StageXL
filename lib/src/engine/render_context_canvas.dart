part of stagexl;

class RenderContextCanvas extends RenderContext {

  CanvasElement _canvasElement;
  CanvasRenderingContext2D _renderingContext;

  String get engine => "Canvas2D";

  RenderContextCanvas(CanvasElement canvasElement) : _canvasElement = canvasElement {

    var renderingContext = _canvasElement.context2D;

    if (renderingContext is! CanvasRenderingContext2D) {
      throw new StateError("Failed to get Canvas context.");
    }

    _renderingContext = renderingContext;
  }

  //-----------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get rawContext => _renderingContext;

  Matrix get viewPortMatrix => new Matrix.fromIdentity();

  //-----------------------------------------------------------------------------------------------

  void clear() {
    _renderingContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _renderingContext.clearRect(0, 0, _canvasElement.width, _canvasElement.height);
  }

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix, num alpha) {

    var source = renderTextureQuad.renderTexture.canvas;
    var rotation = renderTextureQuad.rotation;
    var xyList = renderTextureQuad.xyList;

    _renderingContext.globalAlpha = alpha;

    if (rotation == 0) {

      var sourceX = xyList[0];
      var sourceY = xyList[1];
      var sourceWidth = xyList[4] - sourceX;
      var sourceHeight = xyList[5] - sourceY;
      var destinationX = renderTextureQuad.offsetX;
      var destinationY = renderTextureQuad.offsetY;
      var destinationWidth= renderTextureQuad.width;
      var destinationHeight = renderTextureQuad.height;

      _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      _renderingContext.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);

    } else if (rotation == 1) {

      var sourceX = xyList[6];
      var sourceY = xyList[7];
      var sourceWidth = xyList[2] - sourceX;
      var sourceHeight = xyList[3] - sourceY;
      var destinationX = 0.0 - renderTextureQuad.offsetY - renderTextureQuad.height;
      var destinationY = renderTextureQuad.offsetX;
      var destinationWidth = renderTextureQuad.height;
      var destinationHeight = renderTextureQuad.width;

      _renderingContext.setTransform(-matrix.c, -matrix.d, matrix.a, matrix.b, matrix.tx, matrix.ty);
      _renderingContext.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);
    }
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {

  }

  void flush() {

  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, Mask mask, Matrix matrix) {

    _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _renderingContext.beginPath();

    mask._drawCanvasPath(_renderingContext);

    _renderingContext.save();
    _renderingContext.clip();
  }

  void endRenderMask(Mask mask) {

    _renderingContext.restore();

    if (mask.border) {
      _renderingContext.strokeStyle = _color2rgba(mask.borderColor);
      _renderingContext.lineWidth = mask.borderWidth;
      _renderingContext.lineCap = "round";
      _renderingContext.lineJoin = "round";
      _renderingContext.stroke();
    }
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderShadow(RenderState renderState, Shadow shadow, Matrix matrix) {

    _renderingContext.save();
    _renderingContext.shadowColor = _color2rgba(shadow.color);
    _renderingContext.shadowBlur = sqrt(matrix.det) * shadow.blur;
    _renderingContext.shadowOffsetX = shadow.offsetX * matrix.a + shadow.offsetY * matrix.c;
    _renderingContext.shadowOffsetY = shadow.offsetX * matrix.b + shadow.offsetY * matrix.d;
  }

  void endRenderShadow(Shadow shadow) {

    _renderingContext.restore();
  }
}