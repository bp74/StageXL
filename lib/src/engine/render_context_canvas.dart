part of stagexl.engine;

class RenderContextCanvas extends RenderContext {

  final CanvasElement _canvasElement;

  CanvasRenderingContext2D _renderingContext;
  Matrix _identityMatrix = new Matrix.fromIdentity();

  BlendMode _activeBlendMode = BlendMode.NORMAL;
  double _activeAlpha = 1.0;

  RenderContextCanvas(CanvasElement canvasElement) :
    _canvasElement = canvasElement,
    _renderingContext = canvasElement.context2D;

  //-----------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get rawContext => _renderingContext;
  String get renderEngine => RenderEngine.Canvas2D;

  //-----------------------------------------------------------------------------------------------

  void reset() {
    setTransform(_identityMatrix);
    setBlendMode(BlendMode.NORMAL);
    setAlpha(1.0);
  }

  void clear(int color) {

    setTransform(_identityMatrix);
    setBlendMode(BlendMode.NORMAL);
    setAlpha(1.0);

    if (color & 0xFF000000 == 0) {
      _renderingContext.clearRect(0, 0, _canvasElement.width, _canvasElement.height);
    } else {
      _renderingContext.fillStyle = color2rgb(color);
      _renderingContext.fillRect(0, 0, _canvasElement.width, _canvasElement.height);
    }
  }

  void flush() {

  }

  //-----------------------------------------------------------------------------------------------

  void renderQuad(
    RenderState renderState, RenderTextureQuad renderTextureQuad) {

    var context = _renderingContext;
    var source = renderTextureQuad.renderTexture.source;
    var rotation = renderTextureQuad.rotation;
    var xyList = renderTextureQuad.xyList;
    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

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

    } else if (rotation == 2) {

      var sourceX = xyList[4];
      var sourceY = xyList[5];
      var sourceWidth = xyList[0] - sourceX;
      var sourceHeight = xyList[1] - sourceY;
      var destinationX = 0.0 - renderTextureQuad.offsetX - renderTextureQuad.textureWidth;
      var destinationY = 0.0 - renderTextureQuad.offsetY- renderTextureQuad.textureHeight;
      var destinationWidth= renderTextureQuad.textureWidth;
      var destinationHeight = renderTextureQuad.textureHeight;

      context.setTransform(-matrix.a, -matrix.b, -matrix.c, -matrix.d, matrix.tx, matrix.ty);
      context.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);

    } else if (rotation == 3) {

      var sourceX = xyList[2];
      var sourceY = xyList[3];
      var sourceWidth = xyList[6] - sourceX;
      var sourceHeight = xyList[7] - sourceY;
      var destinationX = renderTextureQuad.offsetY;
      var destinationY = 0.0 - renderTextureQuad.offsetX - renderTextureQuad.textureWidth;
      var destinationWidth = renderTextureQuad.textureHeight;
      var destinationHeight = renderTextureQuad.textureWidth;

      context.setTransform(matrix.c, matrix.d, -matrix.a, -matrix.b, matrix.tx, matrix.ty);
      context.drawImageScaledFromSource(source,
          sourceX, sourceY, sourceWidth, sourceHeight,
          destinationX, destinationY, destinationWidth, destinationHeight);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(
    RenderState renderState,
    num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    var context = _renderingContext;
    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    context.beginPath();
    context.moveTo(x1, y1);
    context.lineTo(x2, y2);
    context.lineTo(x3, y3);
    context.closePath();
    context.fillStyle = color2rgba(color);
    context.fill();
  }

  //-----------------------------------------------------------------------------------------------

  void renderMesh(
    RenderState renderState, RenderTexture renderTexture,
    int indexCount, Int16List indexList,
    int vertexCount, Float32List xyList, Float32List uvList) {

    var context = _renderingContext;
    var source = renderTexture.source;
    var sourceWidth = renderTexture.storeWidth;
    var sourceHeight = renderTexture.storeHeight;
    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;
    var blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    for(int i = 0; i < indexList.length - 2; i += 3) {

      if (i > indexCount - 3) break;

      int i1 = indexList[i + 0] * 2;
      num x1 = xyList[i1 + 0];
      num y1 = xyList[i1 + 1];
      num u1 = uvList[i1 + 0] * sourceWidth;
      num v1 = uvList[i1 + 1] * sourceHeight;

      int i2 = indexList[i + 1] * 2;
      num x2 = xyList[i2 + 0];
      num y2 = xyList[i2 + 1];
      num u2 = uvList[i2 + 0] * sourceWidth;
      num v2 = uvList[i2 + 1] * sourceHeight;

      int i3 = indexList[i + 2] * 2;
      num x3 = xyList[i3 + 0];
      num y3 = xyList[i3 + 1];
      num u3 = uvList[i3 + 0] * sourceWidth;
      num v3 = uvList[i3 + 1] * sourceHeight;

      num mm = v1 * (u3 - u2) + v2 * (u1 - u3) + v3 * (u2 - u1);
      num ma = x1 * (v2 - v3) + x2 * (v3 - v1) + x3 * (v1 - v2);
      num mb = y1 * (v2 - v3) + y2 * (v3 - v1) + y3 * (v1 - v2);
      num mc = x1 * (u3 - u2) + x2 * (u1 - u3) + x3 * (u2 - u1);
      num md = y1 * (u3 - u2) + y2 * (u1 - u3) + y3 * (u2 - u1);
      num mx = x1 * (v3 * u2 - v2 * u3) + x2 * (v1 * u3 - v3 * u1) + x3 * (v2 * u1 - v1 * u2);
      num my = y1 * (v3 * u2 - v2 * u3) + y2 * (v1 * u3 - v3 * u1) + y3 * (v2 * u1 - v1 * u2);

      context.save();
      context.beginPath();
      context.moveTo(x1, y1);
      context.lineTo(x2, y2);
      context.lineTo(x3, y3);
      context.clip();
      context.transform(ma / mm, mb / mm, mc / mm, md / mm, mx / mm, my / mm);
      context.drawImage(source, 0, 0);
      context.restore();
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderObjectFiltered(RenderState renderState, RenderObject renderObject) {

    // It would be to slow to render filters in real time using the
    // Canvas2D context. This is only feasible with the WebGL context.

    renderObject.render(renderState);
  }

  void renderQuadFiltered(
    RenderState renderState, RenderTextureQuad renderTextureQuad,
    List<RenderFilter> renderFilter) {

    // It would be to slow to render filters in real time using the
    // Canvas2D context. This is only feasible with the WebGL context.

    this.renderQuad(renderState, renderTextureQuad);
  }

  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, RenderMask mask) {
    var matrix = renderState.globalMatrix;
    _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _renderingContext.beginPath();
    mask.renderMask(renderState);
    _renderingContext.save();
    _renderingContext.clip();
  }

  void endRenderMask(RenderState renderState, RenderMask mask) {
    _renderingContext.restore();
    _renderingContext.globalAlpha = _activeAlpha;
    _renderingContext.globalCompositeOperation = _activeBlendMode.compositeOperation;
    if (mask.border) {
      _renderingContext.strokeStyle = color2rgba(mask.borderColor);
      _renderingContext.lineWidth = mask.borderWidth;
      _renderingContext.lineCap = "round";
      _renderingContext.lineJoin = "round";
      _renderingContext.stroke();
    }
  }

  //-----------------------------------------------------------------------------------------------

  void setTransform(Matrix matrix) {
    _renderingContext.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
  }

  void setAlpha(num alpha) {
    _activeAlpha = alpha;
    _renderingContext.globalAlpha = alpha;
  }

  void setBlendMode(BlendMode blendMode) {
    _activeBlendMode = blendMode;
    _renderingContext.globalCompositeOperation = blendMode.compositeOperation;
  }

}