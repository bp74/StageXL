part of stagexl;

class RenderContextCanvas extends RenderContext {

  final CanvasElement _canvasElement;
  final int _backgroundColor;

  String _globalCompositeOperation = CompositeOperation.SOURCE_OVER;
  num _globalAlpha = 1.0;

  CanvasRenderingContext2D _renderingContext;

  RenderContextCanvas(CanvasElement canvasElement, int backgroundColor) :
    _canvasElement = canvasElement,
    _backgroundColor = _ensureInt(backgroundColor) {

    var renderingContext = _canvasElement.context2D;

    if (renderingContext is! CanvasRenderingContext2D) {
      throw new StateError("Failed to get Canvas context.");
    }

    _renderingContext = renderingContext;
    _renderingContext.globalCompositeOperation = _globalCompositeOperation;
    _renderingContext.globalAlpha = _globalAlpha;
  }

  //-----------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get rawContext => _renderingContext;

  String get renderEngine => RenderEngine.Canvas2D;
  Matrix get viewPortMatrix => new Matrix.fromIdentity();

  String get globalCompositeOperation => _globalCompositeOperation;
  set globalCompositeOperation(String value){
    if (value is String && value != _globalCompositeOperation) {
      _globalCompositeOperation = value;
      _renderingContext.globalCompositeOperation = value;
    }
  }

  num get globalAlpha => _globalAlpha;
  set globalAlpha(num value) {
    if (value is num && value != _globalAlpha) {
      _globalAlpha = value;
      _renderingContext.globalAlpha = value;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void clear() {
    _renderingContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _renderingContext.globalAlpha = 1.0;
    if (_backgroundColor & 0xFF000000 == 0) {
      _renderingContext.clearRect(0, 0, _canvasElement.width, _canvasElement.height);
    } else {
      _renderingContext.fillStyle = _color2rgb(_backgroundColor);
      _renderingContext.fillRect(0, 0, _canvasElement.width, _canvasElement.height);
    }
  }

  void renderQuad(RenderTextureQuad renderTextureQuad, Matrix matrix) {

    var context = _renderingContext;
    var source = renderTextureQuad.renderTexture.canvas;
    var rotation = renderTextureQuad.rotation;
    var xyList = renderTextureQuad.xyList;

    if (rotation == 0) {

      var sourceX = xyList[0];
      var sourceY = xyList[1];
      var sourceWidth = xyList[4] - sourceX;
      var sourceHeight = xyList[5] - sourceY;
      var destinationX = renderTextureQuad.offsetX;
      var destinationY = renderTextureQuad.offsetY;
      var destinationWidth= renderTextureQuad.textureWidth;
      var destinationHeight = renderTextureQuad.textureHeight;

      context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);

    } else if (rotation == 1) {

      var sourceX = xyList[6];
      var sourceY = xyList[7];
      var sourceWidth = xyList[2] - sourceX;
      var sourceHeight = xyList[3] - sourceY;
      var destinationX = 0.0 - renderTextureQuad.offsetY - renderTextureQuad.textureHeight;
      var destinationY = renderTextureQuad.offsetX;
      var destinationWidth = renderTextureQuad.textureHeight;
      var destinationHeight = renderTextureQuad.textureWidth;

      context.setTransform(-matrix.c, -matrix.d, matrix.a, matrix.b, matrix.tx, matrix.ty);
      context.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);
    }
  }

  void renderTriangle(num x1, num y1, num x2, num y2, num x3, num y3, Matrix matrix, int color) {
    var context = _renderingContext;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.beginPath();
    context.moveTo(x1, y1);
    context.lineTo(x2, y2);
    context.lineTo(x3, y3);
    context.closePath();
    context.fillStyle = _color2rgba(color);
    context.fill();
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