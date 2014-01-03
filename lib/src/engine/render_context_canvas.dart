part of stagexl;

class RenderContextCanvas extends RenderContext {

  CanvasElement _canvasElement;
  CanvasRenderingContext2D _renderingContext;

  RenderContextCanvas(CanvasElement canvasElement) : _canvasElement = canvasElement {
    _renderingContext = canvasElement.context2D;
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
    _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    if (rotation == 0) {

      _renderingContext.drawImageScaledFromSource(canvas,
          renderTextureQuad.x1, renderTextureQuad.y1, width, height,
          offsetX, offsetY, width, height);

    } else if (rotation == 1) {

      _renderingContext.transform(0.0, -1.0, 1.0, 0.0, 0.0, 0.0);
      _renderingContext.drawImageScaledFromSource(canvas,
          renderTextureQuad.x3, renderTextureQuad.y1, height, width,
          0.0 - offsetY - height, offsetX, height, width);
    }
  }

  void flush() {

  }
}