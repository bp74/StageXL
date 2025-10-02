part of '../engine.dart';

class RenderContextCanvas extends RenderContext {
  final web.HTMLCanvasElement _canvasElement;
  final web.CanvasRenderingContext2D _renderingContext;

  final Matrix _identityMatrix = Matrix.fromIdentity();
  BlendMode _activeBlendMode = BlendMode.NORMAL;
  double _activeAlpha = 1;

  RenderContextCanvas(web.HTMLCanvasElement canvasElement)
      : _canvasElement = canvasElement,
        _renderingContext = canvasElement.context2D {
    reset();
  }

  //---------------------------------------------------------------------------

  web.CanvasRenderingContext2D get rawContext => _renderingContext;

  @override
  RenderEngine get renderEngine => RenderEngine.Canvas2D;

  //---------------------------------------------------------------------------
  @override
  Object? getParameter(int parameter) => null;

  @override
  void reset() {
    setTransform(_identityMatrix);
    setBlendMode(BlendMode.NORMAL);
    setAlpha(1);
  }

  @override
  void clear(int color) {
    setTransform(_identityMatrix);
    setBlendMode(BlendMode.NORMAL);
    setAlpha(1);

    final alpha = colorGetA(color);

    if (alpha < 255) {
      _renderingContext.clearRect(
          0, 0, _canvasElement.width, _canvasElement.height);
    }

    if (alpha > 0) {
      _renderingContext.fillStyle = color2rgba(color).toJS;
      _renderingContext.fillRect(
          0, 0, _canvasElement.width, _canvasElement.height);
    }
  }

  @override
  void flush() {
    // nothing to do
  }

  //---------------------------------------------------------------------------

  @override
  void beginRenderMask(RenderState renderState, RenderMask mask) {
    final matrix = renderState.globalMatrix;
    _renderingContext.setTransform(
        matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _renderingContext.beginPath();
    mask.renderMask(renderState);
    _renderingContext.save();
    _renderingContext.clip();
  }

  @override
  void endRenderMask(RenderState renderState, RenderMask mask) {
    _renderingContext.restore();
    _renderingContext.globalAlpha = _activeAlpha;
    _renderingContext.globalCompositeOperation =
        _activeBlendMode.compositeOperation;
    if (mask.border) {
      _renderingContext.strokeStyle = color2rgba(mask.borderColor).toJS;
      _renderingContext.lineWidth = mask.borderWidth;
      _renderingContext.lineCap = 'round';
      _renderingContext.lineJoin = 'round';
      _renderingContext.stroke();
    }
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureQuad(
      RenderState renderState, RenderTextureQuad renderTextureQuad) {
    if (renderTextureQuad.hasCustomVertices) {
      final renderTexture = renderTextureQuad.renderTexture;
      final ixList = renderTextureQuad.ixList;
      final vxList = renderTextureQuad.vxList;
      renderTextureMesh(renderState, renderTexture, ixList, vxList);
      return;
    }

    final context = _renderingContext;
    final source = renderTextureQuad.renderTexture.source ??
        renderTextureQuad.renderTexture.imageBitmap!;

    final rotation = renderTextureQuad.rotation;
    final sourceRect = renderTextureQuad.sourceRectangle;
    final vxList = renderTextureQuad.vxListQuad;
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    // Note: We need to use js_util.callMethod for the drawImage calls,
    // since Dart SDK does not support ImageBitmap as a CanvasImageSource

    if (rotation == 0) {
      context.setTransform(
          matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.drawImage(
          source,
          sourceRect.left,
          sourceRect.top,
          sourceRect.width,
          sourceRect.height,
          vxList[0],
          vxList[1],
          vxList[8] - vxList[0],
          vxList[9] - vxList[1]);
    } else if (rotation == 1) {
      context.setTransform((-matrix.c).toJS, -matrix.d, matrix.a, matrix.b,
          matrix.tx, matrix.ty);
      context.drawImage(
          source,
          sourceRect.left,
          sourceRect.top,
          sourceRect.width,
          sourceRect.height,
          0.0 - vxList[13],
          vxList[12],
          vxList[9] - vxList[1],
          vxList[8] - vxList[0]);
    } else if (rotation == 2) {
      context.setTransform((-matrix.a).toJS, -matrix.b, -matrix.c, -matrix.d,
          matrix.tx, matrix.ty);
      context.drawImage(
          source,
          sourceRect.left,
          sourceRect.top,
          sourceRect.width,
          sourceRect.height,
          0.0 - vxList[8],
          0.0 - vxList[9],
          vxList[8] - vxList[0],
          vxList[9] - vxList[1]);
    } else if (rotation == 3) {
      context.setTransform(
          matrix.c.toJS, matrix.d, -matrix.a, -matrix.b, matrix.tx, matrix.ty);
      context.drawImage(
          source,
          sourceRect.left,
          sourceRect.top,
          sourceRect.width,
          sourceRect.height,
          vxList[5],
          0.0 - vxList[4],
          vxList[9] - vxList[1],
          vxList[8] - vxList[0]);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureMesh(RenderState renderState, RenderTexture renderTexture,
      Int16List ixList, Float32List vxList) {
    final context = _renderingContext;
    final source = renderTexture.source;
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final blendMode = renderState.globalBlendMode;
    final iw = 1.0 / renderTexture.width;
    final ih = 1.0 / renderTexture.height;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    context.setTransform(
        matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    for (var i = 0; i < ixList.length - 2; i += 3) {
      final i1 = ixList[i + 0] << 2;
      final i2 = ixList[i + 1] << 2;
      final i3 = ixList[i + 2] << 2;

      final num x1 = vxList[i1 + 0];
      final num y1 = vxList[i1 + 1];
      final num u1 = vxList[i1 + 2];
      final num v1 = vxList[i1 + 3];

      num x2 = vxList[i2 + 0];
      num y2 = vxList[i2 + 1];
      num u2 = vxList[i2 + 2];
      num v2 = vxList[i2 + 3];

      num x3 = vxList[i3 + 0];
      num y3 = vxList[i3 + 1];
      num u3 = vxList[i3 + 2];
      num v3 = vxList[i3 + 3];

      context.save();
      context.beginPath();
      context.moveTo(x1, y1);
      context.lineTo(x2, y2);
      context.lineTo(x3, y3);
      context.closePath();
      context.clip();

      x2 -= x1;
      y2 -= y1;
      x3 -= x1;
      y3 -= y1;
      u2 -= u1;
      v2 -= v1;
      u3 -= u1;
      v3 -= v1;

      final id = 1.0 / (u2 * v3 - u3 * v2);
      final ma = id * (v3 * x2 - v2 * x3);
      final mb = id * (v3 * y2 - v2 * y3);
      final mc = id * (u2 * x3 - u3 * x2);
      final md = id * (u2 * y3 - u3 * y2);
      final mx = x1 - ma * u1 - mc * v1;
      final my = y1 - mb * u1 - md * v1;

      context.transform(ma * iw, mb * iw, mc * ih, md * ih, mx, my);
      context.drawImage(source!, 0, 0);
      context.restore();
    }
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureMapping(
      RenderState renderState,
      RenderTexture renderTexture,
      Matrix mappingMatrix,
      Int16List ixList,
      Float32List vxList) {
    // do nothing, this is used by webGL to implement canvas patterns
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2,
      num x3, num y3, int color) {
    final context = _renderingContext;
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    context.setTransform(
        matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

    context.beginPath();
    context.moveTo(x1, y1);
    context.lineTo(x2, y2);
    context.lineTo(x3, y3);
    context.closePath();
    context.fillStyle = color2rgba(color).toJS;
    context.fill();
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangleMesh(RenderState renderState, Int16List ixList,
      Float32List vxList, int color) {
    final context = _renderingContext;
    final matrix = renderState.globalMatrix;
    final alpha = renderState.globalAlpha;
    final blendMode = renderState.globalBlendMode;

    if (_activeAlpha != alpha) {
      _activeAlpha = alpha;
      context.globalAlpha = alpha;
    }

    if (_activeBlendMode != blendMode) {
      _activeBlendMode = blendMode;
      context.globalCompositeOperation = blendMode.compositeOperation;
    }

    context.setTransform(
        matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.beginPath();

    for (var i = 0; i < ixList.length - 2; i += 3) {
      final i0 = ixList[i + 0] << 1;
      final i1 = ixList[i + 1] << 1;
      final i2 = ixList[i + 2] << 1;
      final x1 = vxList[i0 + 0];
      final y1 = vxList[i0 + 1];
      final x2 = vxList[i1 + 0];
      final y2 = vxList[i1 + 1];
      final x3 = vxList[i2 + 0];
      final y3 = vxList[i2 + 1];
      context.moveTo(x1, y1);
      context.lineTo(x2, y2);
      context.lineTo(x3, y3);
    }

    context.fillStyle = color2rgba(color).toJS;
    context.fill();
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureQuadFiltered(RenderState renderState,
      RenderTextureQuad renderTextureQuad, List<RenderFilter> renderFilters) {
    // It would be to slow to render filters in real time using the
    // Canvas2D context. This is only feasible with the WebGL context.
    this.renderTextureQuad(renderState, renderTextureQuad);
  }

  //---------------------------------------------------------------------------

  @override
  void renderObjectFiltered(
      RenderState renderState, RenderObject renderObject) {
    // It would be to slow to render filters in real time using the
    // Canvas2D context. This is only feasible with the WebGL context.
    renderObject.render(renderState);
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void setTransform(Matrix matrix) {
    _renderingContext.setTransform(
        matrix.a.toJS, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
  }

  void setAlpha(double alpha) {
    _activeAlpha = alpha;
    _renderingContext.globalAlpha = alpha;
  }

  void setBlendMode(BlendMode blendMode) {
    _activeBlendMode = blendMode;
    _renderingContext.globalCompositeOperation = blendMode.compositeOperation;
  }
}
