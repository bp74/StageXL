part of stagexl.engine;

class RenderContextWebGL extends RenderContext {
  static int _globalContextIdentifier = 0;
  final CanvasElement _canvasElement;

  late final gl.RenderingContext _renderingContext;
  final Matrix3D _projectionMatrix = Matrix3D.fromIdentity();
  final List<_MaskState> _maskStates = <_MaskState>[];

  late RenderProgram _activeRenderProgram;
  RenderFrameBuffer? _activeRenderFrameBuffer;
  RenderStencilBuffer? _activeRenderStencilBuffer;
  BlendMode? _activeBlendMode;

  bool _contextValid = true;
  int _contextIdentifier = 0;

  //---------------------------------------------------------------------------

  final RenderProgramSimple renderProgramSimple = RenderProgramSimple();
  final RenderProgramTinted renderProgramTinted = RenderProgramTinted();
  final RenderProgramTriangle renderProgramTriangle = RenderProgramTriangle();

  final RenderBufferIndex renderBufferIndex = RenderBufferIndex(16384);
  final RenderBufferVertex renderBufferVertex = RenderBufferVertex(32768);

  final List<RenderTexture?> _activeRenderTextures = List.filled(8, null);
  final List<RenderFrameBuffer> _renderFrameBufferPool = <RenderFrameBuffer>[];
  final Map<String, RenderProgram> _renderPrograms = <String, RenderProgram>{};

  //---------------------------------------------------------------------------

  RenderContextWebGL(CanvasElement canvasElement,
      {bool alpha = false, bool antialias = false})
      : _canvasElement = canvasElement {
    _canvasElement.onWebGlContextLost.listen(_onContextLost);
    _canvasElement.onWebGlContextRestored.listen(_onContextRestored);

    final renderingContext = _canvasElement.getContext3d(
        alpha: alpha, antialias: antialias, depth: false, stencil: true);

    if (renderingContext is! gl.RenderingContext) {
      throw StateError('Failed to get WebGL context.');
    }

    _renderingContext = renderingContext;
    _renderingContext.enable(gl.WebGL.BLEND);
    _renderingContext.disable(gl.WebGL.STENCIL_TEST);
    _renderingContext.disable(gl.WebGL.DEPTH_TEST);
    _renderingContext.disable(gl.WebGL.CULL_FACE);
    _renderingContext.pixelStorei(gl.WebGL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
    _renderingContext.blendFunc(gl.WebGL.ONE, gl.WebGL.ONE_MINUS_SRC_ALPHA);

    _activeRenderProgram = renderProgramSimple;
    _activeRenderProgram.activate(this);

    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;

    reset();
  }

  //---------------------------------------------------------------------------

  gl.RenderingContext get rawContext => _renderingContext;

  @override
  RenderEngine get renderEngine => RenderEngine.WebGL;

  @override
  Object? get maxTextureSize => _renderingContext.getParameter(gl.WebGL.MAX_TEXTURE_SIZE);

  RenderTexture? get activeRenderTexture => _activeRenderTextures[0];
  RenderProgram get activeRenderProgram => _activeRenderProgram;
  RenderFrameBuffer? get activeRenderFrameBuffer => _activeRenderFrameBuffer;
  Matrix3D get activeProjectionMatrix => _projectionMatrix;
  BlendMode? get activeBlendMode => _activeBlendMode;

  bool get contextValid => _contextValid;
  int get contextIdentifier => _contextIdentifier;

  //---------------------------------------------------------------------------
  @override
  Object? getParameter(int parameter) => _renderingContext.getParameter(parameter);

  @override
  void reset() {
    final viewportWidth = _canvasElement.width!;
    final viewportHeight = _canvasElement.height!;
    _activeRenderFrameBuffer = null;
    _renderingContext.bindFramebuffer(gl.WebGL.FRAMEBUFFER, null);
    _renderingContext.viewport(0, 0, viewportWidth, viewportHeight);
    _projectionMatrix.setIdentity();
    _projectionMatrix.scale(2.0 / viewportWidth, -2.0 / viewportHeight, 1.0);
    _projectionMatrix.translate(-1.0, 1.0, 0.0);
    _activeRenderProgram.projectionMatrix = _projectionMatrix;
  }

  @override
  void clear(int color) {
    _getMaskStates().clear();
    _updateScissorTest(null);
    _updateStencilTest(0);
    final num r = colorGetR(color) / 255.0;
    final num g = colorGetG(color) / 255.0;
    final num b = colorGetB(color) / 255.0;
    final num a = colorGetA(color) / 255.0;
    _renderingContext.colorMask(true, true, true, true);
    _renderingContext.clearColor(r * a, g * a, b * a, a);
    _renderingContext
        .clear(gl.WebGL.COLOR_BUFFER_BIT | gl.WebGL.STENCIL_BUFFER_BIT);
  }

  @override
  void flush() {
    _activeRenderProgram.flush();
  }

  //---------------------------------------------------------------------------

  @override
  void beginRenderMask(RenderState renderState, RenderMask mask) {
    _activeRenderProgram.flush();

    // try to use the scissor rectangle for this mask

    if (mask is ScissorRenderMask) {
      final scissor = mask.getScissorRectangle(renderState);
      if (scissor != null) {
        final last = _getLastScissorValue();
        final next = last == null ? scissor : scissor.intersection(last);
        _getMaskStates().add(_ScissorMaskState(mask, next));
        _updateScissorTest(next);
        return;
      }
    }

    // update the stencil buffer for this mask

    final stencil = _getLastStencilValue() + 1;

    _renderingContext.enable(gl.WebGL.STENCIL_TEST);
    _renderingContext.stencilOp(gl.WebGL.KEEP, gl.WebGL.KEEP, gl.WebGL.INCR);
    _renderingContext.stencilFunc(gl.WebGL.EQUAL, stencil - 1, 0xFF);
    _renderingContext.colorMask(false, false, false, false);
    mask.renderMask(renderState);

    _activeRenderProgram.flush();
    _renderingContext.stencilOp(gl.WebGL.KEEP, gl.WebGL.KEEP, gl.WebGL.KEEP);
    _renderingContext.colorMask(true, true, true, true);
    _getMaskStates().add(_StencilMaskState(mask, stencil));
    _updateStencilTest(stencil);
  }

  @override
  void endRenderMask(RenderState renderState, RenderMask mask) {
    _activeRenderProgram.flush();

    final maskState = _getMaskStates().removeLast();
    if (maskState is _ScissorMaskState) {
      _updateScissorTest(_getLastScissorValue());
    } else if (maskState is _StencilMaskState) {
      _renderingContext.enable(gl.WebGL.STENCIL_TEST);
      _renderingContext.stencilOp(gl.WebGL.KEEP, gl.WebGL.KEEP, gl.WebGL.DECR);
      _renderingContext.stencilFunc(gl.WebGL.EQUAL, maskState.value, 0xFF);
      _renderingContext.colorMask(false, false, false, false);
      mask.renderMask(renderState);

      _activeRenderProgram.flush();
      _renderingContext.stencilOp(gl.WebGL.KEEP, gl.WebGL.KEEP, gl.WebGL.KEEP);
      _renderingContext.colorMask(true, true, true, true);
      _updateStencilTest(maskState.value - 1);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  void renderTextureQuad(
      RenderState renderState, RenderTextureQuad renderTextureQuad) {
    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTextureQuad.renderTexture);
    renderProgramSimple.renderTextureQuad(renderState, renderTextureQuad);
  }

  @override
  void renderTextureMesh(RenderState renderState, RenderTexture renderTexture,
      Int16List ixList, Float32List vxList) {
    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTexture);
    renderProgramSimple.renderTextureMesh(renderState, ixList, vxList);
  }

  @override
  void renderTextureMapping(
      RenderState renderState,
      RenderTexture renderTexture,
      Matrix mappingMatrix,
      Int16List ixList,
      Float32List vxList) {
    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTexture);
    renderProgramSimple.renderTextureMapping(
        renderState, mappingMatrix, ixList, vxList);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangle(RenderState renderState, num x1, num y1, num x2, num y2,
      num x3, num y3, int color) {
    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangle(
        renderState, x1, y1, x2, y2, x3, y3, color);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangleMesh(RenderState renderState, Int16List ixList,
      Float32List vxList, int color) {
    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangleMesh(
        renderState, ixList, vxList, color);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureQuadFiltered(RenderState renderState,
      RenderTextureQuad renderTextureQuad, List<RenderFilter> renderFilters) {
    final firstFilter = renderFilters.length == 1 ? renderFilters[0] : null;

    if (renderFilters.isEmpty) {
      // Don't render anything
    } else if (firstFilter is RenderFilter && firstFilter.isSimple) {
      firstFilter.renderFilter(renderState, renderTextureQuad, 0);
    } else {
      final renderObject =
          _RenderTextureQuadObject(renderTextureQuad, renderFilters);
      renderObjectFiltered(renderState, renderObject);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void renderObjectFiltered(
      RenderState renderState, RenderObject renderObject) {
    final bounds = renderObject.bounds;
    var filters = renderObject.filters;
    final pixelRatio = math.sqrt(renderState.globalMatrix.det.abs());

    var boundsLeft = bounds.left.floor();
    var boundsTop = bounds.top.floor();
    var boundsRight = bounds.right.ceil();
    var boundsBottom = bounds.bottom.ceil();

    for (var i = 0; i < filters.length; i++) {
      final overlap = filters[i].overlap;
      boundsLeft += overlap.left;
      boundsTop += overlap.top;
      boundsRight += overlap.right;
      boundsBottom += overlap.bottom;
    }

    boundsLeft = (boundsLeft * pixelRatio).floor();
    boundsTop = (boundsTop * pixelRatio).floor();
    boundsRight = (boundsRight * pixelRatio).ceil();
    boundsBottom = (boundsBottom * pixelRatio).ceil();

    final boundsWidth = boundsRight - boundsLeft;
    final boundsHeight = boundsBottom - boundsTop;

    final initialRenderFrameBuffer = activeRenderFrameBuffer;
    final initialProjectionMatrix = activeProjectionMatrix.clone();
    RenderFrameBuffer? filterRenderFrameBuffer =
        getRenderFrameBuffer(boundsWidth, boundsHeight);

    final filterProjectionMatrix = Matrix3D.fromIdentity();
    filterProjectionMatrix.scale(2.0 / boundsWidth, 2.0 / boundsHeight, 1.0);
    filterProjectionMatrix.translate(-1.0, -1.0, 0.0);

    var filterRenderState = RenderState(this);
    filterRenderState.globalMatrix.scale(pixelRatio, pixelRatio);
    filterRenderState.globalMatrix.translate(-boundsLeft, -boundsTop);

    final renderFrameBufferMap = <int, RenderFrameBuffer?>{};
    renderFrameBufferMap[0] = filterRenderFrameBuffer;

    //----------------------------------------------

    activateRenderFrameBuffer(filterRenderFrameBuffer);
    activateProjectionMatrix(filterProjectionMatrix);
    activateBlendMode(BlendMode.NORMAL);
    clear(0);

    if (filters.isEmpty) {
      // Don't render anything
    } else if (filters[0].isSimple &&
        renderObject is _RenderTextureQuadObject) {
      final renderTextureQuad = renderObject.renderTextureQuad;
      renderTextureQuadFiltered(
          filterRenderState, renderTextureQuad, [filters[0]]);
      filters = filters.sublist(1);
    } else {
      renderObject.render(filterRenderState);
    }

    //----------------------------------------------

    for (var i = 0; i < filters.length; i++) {
      RenderTextureQuad sourceRenderTextureQuad;
      final filter = filters[i];

      final renderPassSources = filter.renderPassSources;
      final renderPassTargets = filter.renderPassTargets;

      for (var pass = 0; pass < renderPassSources.length; pass++) {
        final renderPassSource = renderPassSources[pass];
        final renderPassTarget = renderPassTargets[pass];

        final RenderFrameBuffer sourceRenderFrameBuffer;

        // get sourceRenderTextureQuad

        if (renderFrameBufferMap.containsKey(renderPassSource)) {
          sourceRenderFrameBuffer = renderFrameBufferMap[renderPassSource]!;
          if (sourceRenderFrameBuffer.renderTexture == null) {
            throw StateError('Invalid renderPassSource!');
          }
          sourceRenderTextureQuad = RenderTextureQuad(
              sourceRenderFrameBuffer.renderTexture!,
              Rectangle<int>(0, 0, boundsWidth, boundsHeight),
              Rectangle<int>(
                  -boundsLeft, -boundsTop, boundsWidth, boundsHeight),
              0,
              pixelRatio);
        } else {
          throw StateError('Invalid renderPassSource!');
        }

        // get targetRenderFrameBuffer

        if (i == filters.length - 1 &&
            renderPassTarget == renderPassTargets.last) {
          filterRenderFrameBuffer = null;
          filterRenderState = renderState;
          activateRenderFrameBuffer(initialRenderFrameBuffer);
          activateProjectionMatrix(initialProjectionMatrix);
          activateBlendMode(filterRenderState.globalBlendMode);
        } else if (renderFrameBufferMap.containsKey(renderPassTarget)) {
          filterRenderFrameBuffer = renderFrameBufferMap[renderPassTarget];
          activateRenderFrameBuffer(filterRenderFrameBuffer);
          activateBlendMode(BlendMode.NORMAL);
        } else {
          filterRenderFrameBuffer =
              getRenderFrameBuffer(boundsWidth, boundsHeight);
          renderFrameBufferMap[renderPassTarget] = filterRenderFrameBuffer;
          activateRenderFrameBuffer(filterRenderFrameBuffer);
          activateBlendMode(BlendMode.NORMAL);
          clear(0);
        }

        // render filter

        filter.renderFilter(filterRenderState, sourceRenderTextureQuad, pass);

        // release obsolete source RenderFrameBuffer

        if (renderPassSources
            .skip(pass + 1)
            .every((rps) => rps != renderPassSource)) {
          renderFrameBufferMap.remove(renderPassSource);
          releaseRenderFrameBuffer(sourceRenderFrameBuffer);
        }
      }

      renderFrameBufferMap.clear();
      renderFrameBufferMap[0] = filterRenderFrameBuffer;
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  T getRenderProgram<T extends RenderProgram>(
          String name, T Function() ifAbsent) =>
      _renderPrograms.putIfAbsent(name, ifAbsent) as T;

  RenderFrameBuffer getRenderFrameBuffer(int width, int height) {
    if (_renderFrameBufferPool.isEmpty) {
      return RenderFrameBuffer.rawWebGL(width, height);
    } else {
      final renderFrameBuffer = _renderFrameBufferPool.removeLast();
      final renderTexture = renderFrameBuffer.renderTexture!;
      final renderStencilBuffer = renderFrameBuffer.renderStencilBuffer;
      if (renderTexture.width != width || renderTexture.height != height) {
        releaseRenderTexture(renderTexture);
        renderTexture.resize(width, height);
        renderStencilBuffer!.resize(width, height);
      }
      return renderFrameBuffer;
    }
  }

  void releaseRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    _activeRenderProgram.flush();
    _renderFrameBufferPool.add(renderFrameBuffer);
  }

  void releaseRenderTexture(RenderTexture renderTexture) {
    for (var i = 0; i < _activeRenderTextures.length; i++) {
      if (identical(renderTexture, _activeRenderTextures[i])) {
        _activeRenderTextures[i] = null;
        _renderingContext.activeTexture(gl.WebGL.TEXTURE0 + i);
        _renderingContext.bindTexture(gl.WebGL.TEXTURE_2D, null);
      }
    }
  }

  //---------------------------------------------------------------------------

  void activateRenderFrameBuffer(RenderFrameBuffer? renderFrameBuffer) {
    if (!identical(renderFrameBuffer, _activeRenderFrameBuffer)) {
      if (renderFrameBuffer is RenderFrameBuffer) {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = renderFrameBuffer;
        _activeRenderFrameBuffer!.activate(this);
        _renderingContext.viewport(
            0, 0, renderFrameBuffer.width!, renderFrameBuffer.height!);
      } else {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = null;
        _renderingContext.bindFramebuffer(gl.WebGL.FRAMEBUFFER, null);
        _renderingContext.viewport(
            0, 0, _canvasElement.width!, _canvasElement.height!);
      }
      _updateScissorTest(_getLastScissorValue());
      _updateStencilTest(_getLastStencilValue());
    }
  }

  void activateRenderStencilBuffer(RenderStencilBuffer renderStencilBuffer) {
    if (!identical(renderStencilBuffer, _activeRenderStencilBuffer)) {
      _activeRenderProgram.flush();
      _activeRenderStencilBuffer = renderStencilBuffer;
      _activeRenderStencilBuffer!.activate(this);
    }
  }

  void activateRenderProgram(RenderProgram renderProgram) {
    if (!identical(renderProgram, _activeRenderProgram)) {
      _activeRenderProgram.flush();
      _activeRenderProgram = renderProgram;
      _activeRenderProgram.activate(this);
      _activeRenderProgram.projectionMatrix = _projectionMatrix;
    }
  }

  void activateBlendMode(BlendMode blendMode) {
    if (!identical(blendMode, _activeBlendMode)) {
      _activeRenderProgram.flush();
      _activeBlendMode = blendMode;
      _activeBlendMode!.blend(_renderingContext);
    }
  }

  void activateRenderTexture(RenderTexture renderTexture) {
    if (!identical(renderTexture, _activeRenderTextures[0])) {
      _activeRenderProgram.flush();
      _activeRenderTextures[0] = renderTexture;
      renderTexture.activate(this, gl.WebGL.TEXTURE0);
    }
  }

  void activateRenderTextureAt(RenderTexture renderTexture, int index) {
    if (!identical(renderTexture, _activeRenderTextures[index])) {
      _activeRenderProgram.flush();
      _activeRenderTextures[index] = renderTexture;
      renderTexture.activate(this, gl.WebGL.TEXTURE0 + index);
    }
  }

  void activateProjectionMatrix(Matrix3D matrix) {
    _projectionMatrix.copyFrom(matrix);
    _activeRenderProgram.flush();
    _activeRenderProgram.projectionMatrix = _projectionMatrix;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  List<_MaskState> _getMaskStates() {
    final rfb = _activeRenderFrameBuffer;
    return rfb is RenderFrameBuffer ? rfb._maskStates : _maskStates;
  }

  int _getLastStencilValue() {
    final maskStates = _getMaskStates();
    for (var i = maskStates.length - 1; i >= 0; i--) {
      final maskState = maskStates[i];
      if (maskState is _StencilMaskState) return maskState.value;
    }
    return 0;
  }

  Rectangle<num>? _getLastScissorValue() {
    final maskStates = _getMaskStates();
    for (var i = maskStates.length - 1; i >= 0; i--) {
      final maskState = maskStates[i];
      if (maskState is _ScissorMaskState) return maskState.value;
    }
    return null;
  }

  void _updateStencilTest(int value) {
    if (value == 0) {
      _renderingContext.disable(gl.WebGL.STENCIL_TEST);
    } else {
      _renderingContext.enable(gl.WebGL.STENCIL_TEST);
      _renderingContext.stencilFunc(gl.WebGL.EQUAL, value, 0xFF);
    }
  }

  void _updateScissorTest(Rectangle<num>? value) {
    if (value == null) {
      _renderingContext.disable(gl.WebGL.SCISSOR_TEST);
    } else if (_activeRenderFrameBuffer is RenderFrameBuffer) {
      final x1 = value.left.round();
      final y1 = value.top.round();
      final x2 = value.right.round();
      final y2 = value.bottom.round();
      _renderingContext.enable(gl.WebGL.SCISSOR_TEST);
      _renderingContext.scissor(
          x1, y1, math.max(x2 - x1, 0), math.max(y2 - y1, 0));
    } else {
      final x1 = value.left.round();
      final y1 = _canvasElement.height! - value.bottom.round();
      final x2 = value.right.round();
      final y2 = _canvasElement.height! - value.top.round();
      _renderingContext.enable(gl.WebGL.SCISSOR_TEST);
      _renderingContext.scissor(
          x1, y1, math.max(x2 - x1, 0), math.max(y2 - y1, 0));
    }
  }

  //---------------------------------------------------------------------------

  void _onContextLost(gl.ContextEvent contextEvent) {
    contextEvent.preventDefault();
    _contextValid = false;
    _contextLostEvent.add(RenderContextEvent());
  }

  void _onContextRestored(gl.ContextEvent contextEvent) {
    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;
    _contextRestoredEvent.add(RenderContextEvent());
  }
}
