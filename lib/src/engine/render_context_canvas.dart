part of stagexl;

class RenderContextCanvas extends RenderContext {

  CanvasElement _canvasElement;
  CanvasRenderingContext2D _renderingContext;

  RenderContextCanvas(CanvasElement canvasElement) : _canvasElement = canvasElement {

    var renderingContext = _canvasElement.context2D;

    if (renderingContext is! CanvasRenderingContext2D) {
      throw new StateError("Failed to get Canvas context.");
    }

    _renderingContext = renderingContext;
  }

  //-----------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get rawContext => _renderingContext;

  //-----------------------------------------------------------------------------------------------

  void clear() {

    _renderingContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _renderingContext.clearRect(0, 0, _canvasElement.width, _canvasElement.height);
  }

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    var matrix = renderState.globalMatrix;

    var canvas = renderTextureQuad.renderTexture.canvas;
    var width = renderTextureQuad.width;
    var height = renderTextureQuad.height;
    var offsetX = renderTextureQuad.offsetX;
    var offsetY = renderTextureQuad.offsetY;
    var rotation = renderTextureQuad.rotation;

    _renderingContext.globalAlpha = renderState.globalAlpha;
    _renderingContext.globalCompositeOperation = renderState.globalCompositeOperation;

    if (rotation == 0) {

      _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      _renderingContext.drawImageScaledFromSource(canvas,
          renderTextureQuad.x1, renderTextureQuad.y1, width, height,
          offsetX, offsetY, width, height);

    } else if (rotation == 1) {

      _renderingContext.setTransform(matrix.c, -matrix.d, matrix.a, matrix.b, matrix.tx, matrix.ty);
      _renderingContext.drawImageScaledFromSource(canvas,
          renderTextureQuad.x3, renderTextureQuad.y1, height, width,
          0.0 - offsetY - height, offsetX, height, width);
    }
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

  }

  void endRenderShadow(Shadow shadow) {

  }
}