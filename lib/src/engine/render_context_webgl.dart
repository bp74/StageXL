part of stagexl.engine;

class RenderContextWebGL extends RenderContext {

  static int _globalContextIdentifier = 0;
  final CanvasElement _canvasElement;

  gl.RenderingContext _renderingContext;
  final Matrix3D _projectionMatrix = new Matrix3D.fromIdentity();
  final List<_MaskState> _maskStates = new List<_MaskState>();

  RenderProgram _activeRenderProgram;
  RenderFrameBuffer _activeRenderFrameBuffer;
  RenderStencilBuffer _activeRenderStencilBuffer;
  BlendMode _activeBlendMode;

  bool _contextValid = true;
  int _contextIdentifier = 0;

  //---------------------------------------------------------------------------

  final RenderProgramSimple renderProgramSimple = new RenderProgramSimple();
  final RenderProgramTinted renderProgramTinted = new RenderProgramTinted();
  final RenderProgramTriangle renderProgramTriangle = new RenderProgramTriangle();

  final RenderBufferIndex renderBufferIndex = new RenderBufferIndex(16384);
  final RenderBufferVertex renderBufferVertex = new RenderBufferVertex(32768);

  final List<RenderTexture> _activeRenderTextures = new  List<RenderTexture>(8);
  final List<RenderFrameBuffer> _renderFrameBufferPool = new List<RenderFrameBuffer>();
  final Map<String, RenderProgram> _renderPrograms = new Map<String, RenderProgram>();

  //---------------------------------------------------------------------------

  RenderContextWebGL(CanvasElement canvasElement, {
    bool alpha: false, bool antialias: false }) : _canvasElement = canvasElement {

    _canvasElement.onWebGlContextLost.listen(_onContextLost);
    _canvasElement.onWebGlContextRestored.listen(_onContextRestored);

    var renderingContext = _canvasElement.getContext3d(
        alpha: alpha, antialias: antialias,
        depth: false, stencil: true,
        premultipliedAlpha: true, preserveDrawingBuffer: false);

    if (renderingContext is! gl.RenderingContext) {
      throw new StateError("Failed to get WebGL context.");
    }

    _renderingContext = renderingContext;
    _renderingContext.enable(gl.BLEND);
    _renderingContext.disable(gl.STENCIL_TEST);
    _renderingContext.disable(gl.DEPTH_TEST);
    _renderingContext.disable(gl.CULL_FACE);
    _renderingContext.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
    _renderingContext.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);

    _activeRenderProgram = renderProgramSimple;
    _activeRenderProgram.activate(this);

    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;

    this.reset();
  }

  //---------------------------------------------------------------------------

  gl.RenderingContext get rawContext => _renderingContext;

  @override
  RenderEngine get renderEngine => RenderEngine.WebGL;

  RenderTexture get activeRenderTexture => _activeRenderTextures[0];
  RenderProgram get activeRenderProgram => _activeRenderProgram;
  RenderFrameBuffer get activeRenderFrameBuffer => _activeRenderFrameBuffer;
  Matrix3D get activeProjectionMatrix => _projectionMatrix;
  BlendMode get activeBlendMode => _activeBlendMode;

  bool get contextValid => _contextValid;
  int get contextIdentifier => _contextIdentifier;

  //---------------------------------------------------------------------------

  @override
  void reset() {
    var viewportWidth = _canvasElement.width;
    var viewportHeight = _canvasElement.height;
    _activeRenderFrameBuffer = null;
    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
    _renderingContext.viewport(0, 0, viewportWidth, viewportHeight);
    _projectionMatrix.setIdentity();
    _projectionMatrix.scale(2.0 / viewportWidth, - 2.0 / viewportHeight, 1.0);
    _projectionMatrix.translate(-1.0, 1.0, 0.0);
    _activeRenderProgram.projectionMatrix = _projectionMatrix;
  }

  @override
  void clear(int color) {
    _getMaskStates().clear();
    _updateScissorTest(null);
    _updateStencilTest(0);
    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0;
    _renderingContext.colorMask(true, true, true, true);
    _renderingContext.clearColor(r * a, g * a, b * a, a);
    _renderingContext.clear(gl.COLOR_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
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
      var scissor = mask.getScissorRectangle(renderState);
      if (scissor != null) {
        var last = _getLastScissorValue();
        var next = last == null ? scissor : scissor.intersection(last);
        _getMaskStates().add(new _ScissorMaskState(mask, next));
        _updateScissorTest(next);
        return;
      }
    }

    // update the stencil buffer for this mask

    var stencil = _getLastStencilValue() + 1;

    _renderingContext.enable(gl.STENCIL_TEST);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.INCR);
    _renderingContext.stencilFunc(gl.EQUAL, stencil - 1, 0xFF);
    _renderingContext.colorMask(false, false, false, false);
    mask.renderMask(renderState);

    _activeRenderProgram.flush();
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    _renderingContext.colorMask(true, true, true, true);
    _getMaskStates().add(new _StencilMaskState(mask, stencil));
    _updateStencilTest(stencil);
  }

  @override
  void endRenderMask(RenderState renderState, RenderMask mask) {

    _activeRenderProgram.flush();

    var maskState = _getMaskStates().removeLast();
    if (maskState is _ScissorMaskState) {

      _updateScissorTest(_getLastScissorValue());

    } else if (maskState is _StencilMaskState) {

      _renderingContext.enable(gl.STENCIL_TEST);
      _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.DECR);
      _renderingContext.stencilFunc(gl.EQUAL, maskState.value, 0xFF);
      _renderingContext.colorMask(false, false, false, false);
      mask.renderMask(renderState);

      _activeRenderProgram.flush();
      _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
      _renderingContext.colorMask(true, true, true, true);
      _updateStencilTest(maskState.value - 1);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  void renderTextureQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad) {

    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTextureQuad.renderTexture);
    renderProgramSimple.renderTextureQuad(renderState, renderTextureQuad);
  }

  @override
  void renderTextureMesh(
      RenderState renderState, RenderTexture renderTexture,
      Int16List ixList, Float32List vxList) {

    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTexture);
    renderProgramSimple.renderTextureMesh(renderState, ixList, vxList);
  }

  @override
  void renderTextureMapping(
      RenderState renderState,
      RenderTexture renderTexture, Matrix mappingMatrix,
      Int16List ixList, Float32List vxList) {

    activateRenderProgram(renderProgramSimple);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTexture);
    renderProgramSimple.renderTextureMapping(renderState, mappingMatrix, ixList, vxList);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangle(
    RenderState renderState,
    num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangle(
        renderState, x1, y1, x2, y2, x3, y3, color);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTriangleMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, int color) {

    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangleMesh(renderState, ixList, vxList, color);
  }

  //---------------------------------------------------------------------------

  @override
  void renderTextureQuadFiltered(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad,
      List<RenderFilter> renderFilters) {

    var firstFilter = renderFilters.length == 1 ? renderFilters[0] : null;

    if (renderFilters.length == 0) {
      // Don't render anything
    } else if (firstFilter is RenderFilter && firstFilter.isSimple) {
      firstFilter.renderFilter(renderState, renderTextureQuad, 0);
    } else {
      var renderObject = new _RenderTextureQuadObject(renderTextureQuad, renderFilters);
      this.renderObjectFiltered(renderState, renderObject);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void renderObjectFiltered(RenderState renderState, RenderObject renderObject) {

    var bounds = renderObject.bounds;
    var filters = renderObject.filters;
    var pixelRatio = math.sqrt(renderState.globalMatrix.det.abs());

    var boundsLeft = bounds.left.floor();
    var boundsTop = bounds.top.floor();
    var boundsRight = bounds.right.ceil();
    var boundsBottom = bounds.bottom.ceil();

    for (int i = 0; i < filters.length; i++) {
      var overlap = filters[i].overlap;
      boundsLeft += overlap.left;
      boundsTop += overlap.top;
      boundsRight += overlap.right;
      boundsBottom += overlap.bottom;
    }

    boundsLeft = (boundsLeft * pixelRatio).floor();
    boundsTop = (boundsTop * pixelRatio).floor();
    boundsRight = (boundsRight * pixelRatio).ceil();
    boundsBottom = (boundsBottom * pixelRatio).ceil();

    var boundsWidth = boundsRight - boundsLeft;
    var boundsHeight = boundsBottom - boundsTop;

    var initialRenderFrameBuffer = this.activeRenderFrameBuffer;
    var initialProjectionMatrix = this.activeProjectionMatrix.clone();

    var filterRenderState = new RenderState(this);
    var filterProjectionMatrix = new Matrix3D.fromIdentity();
    var filterRenderFrameBuffer = this.getRenderFrameBuffer(boundsWidth, boundsHeight);
    var renderFrameBufferMap = new Map<int, RenderFrameBuffer>();

    filterProjectionMatrix.translate(-boundsLeft, -boundsTop, 0.0);
    filterProjectionMatrix.scale(2.0 / boundsWidth, 2.0 / boundsHeight, 1.0);
    filterProjectionMatrix.translate(-1.0, -1.0, 0.0);
    filterRenderState.globalMatrix.scale(pixelRatio, pixelRatio);
    renderFrameBufferMap[0] = filterRenderFrameBuffer;

    //----------------------------------------------

    this.activateRenderFrameBuffer(filterRenderFrameBuffer);
    this.activateProjectionMatrix(filterProjectionMatrix);
    this.activateBlendMode(BlendMode.NORMAL);
    this.clear(0);

    if (filters.length == 0) {
      // Don't render anything
    } else if (filters[0].isSimple && renderObject is _RenderTextureQuadObject) {
      var renderTextureQuad = renderObject.renderTextureQuad;
      renderTextureQuadFiltered(filterRenderState, renderTextureQuad, [filters[0]]);
      filters = filters.sublist(1);
    } else {
      renderObject.render(filterRenderState);
    }

    //----------------------------------------------

    for (int i = 0; i < filters.length; i++) {

      RenderTextureQuad sourceRenderTextureQuad;
      RenderFrameBuffer sourceRenderFrameBuffer;
      RenderFilter filter = filters[i];

      List<int> renderPassSources = filter.renderPassSources;
      List<int> renderPassTargets = filter.renderPassTargets;

      for (int pass = 0; pass < renderPassSources.length; pass++) {

        int renderPassSource = renderPassSources[pass];
        int renderPassTarget = renderPassTargets[pass];

        // get sourceRenderTextureQuad

        if (renderFrameBufferMap.containsKey(renderPassSource)) {
          sourceRenderFrameBuffer = renderFrameBufferMap[renderPassSource];
          sourceRenderTextureQuad = new RenderTextureQuad(
              sourceRenderFrameBuffer.renderTexture,
              new Rectangle<int>(0, 0, boundsWidth, boundsHeight),
              new Rectangle<int>(-boundsLeft, -boundsTop, boundsWidth, boundsHeight),
              0, pixelRatio);
        } else {
          throw new StateError("Invalid renderPassSource!");
        }

        // get targetRenderFrameBuffer

        if (i == filters.length - 1 && renderPassTarget == renderPassTargets.last) {
          filterRenderFrameBuffer = null;
          filterRenderState = renderState;
          this.activateRenderFrameBuffer(initialRenderFrameBuffer);
          this.activateProjectionMatrix(initialProjectionMatrix);
          this.activateBlendMode(filterRenderState.globalBlendMode);
        } else if (renderFrameBufferMap.containsKey(renderPassTarget)) {
          filterRenderFrameBuffer = renderFrameBufferMap[renderPassTarget];
          this.activateRenderFrameBuffer(filterRenderFrameBuffer);
          this.activateBlendMode(BlendMode.NORMAL);
        } else {
          filterRenderFrameBuffer = this.getRenderFrameBuffer(boundsWidth, boundsHeight);
          renderFrameBufferMap[renderPassTarget] = filterRenderFrameBuffer;
          this.activateRenderFrameBuffer(filterRenderFrameBuffer);
          this.activateBlendMode(BlendMode.NORMAL);
          this.clear(0);
        }

        // render filter

        filter.renderFilter(filterRenderState, sourceRenderTextureQuad, pass);

        // release obsolete source RenderFrameBuffer

        if (renderPassSources.skip(pass + 1).every((rps) => rps != renderPassSource)) {
          renderFrameBufferMap.remove(renderPassSource);
          this.releaseRenderFrameBuffer(sourceRenderFrameBuffer);
        }
      }

      renderFrameBufferMap.clear();
      renderFrameBufferMap[0] = filterRenderFrameBuffer;
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  T getRenderProgram<T extends RenderProgram>(String name, T ifAbsent()) {
    return _renderPrograms.putIfAbsent(name, ifAbsent) as T;
  }

  RenderFrameBuffer getRenderFrameBuffer(int width, int height) {
    if (_renderFrameBufferPool.length == 0) {
      return new RenderFrameBuffer.rawWebGL(width, height);
    } else {
      var renderFrameBuffer = _renderFrameBufferPool.removeLast();
      var renderTexture = renderFrameBuffer.renderTexture;
      var renderStencilBuffer = renderFrameBuffer.renderStencilBuffer;
      if (renderTexture.width != width || renderTexture.height != height) {
        releaseRenderTexture(renderTexture);
        renderTexture.resize(width, height);
        renderStencilBuffer.resize(width, height);
      }
      return renderFrameBuffer;
    }
  }

  void releaseRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (renderFrameBuffer is RenderFrameBuffer) {
      _activeRenderProgram.flush();
      _renderFrameBufferPool.add(renderFrameBuffer);
    }
  }

  void releaseRenderTexture(RenderTexture renderTexture) {
    for (int i = 0; i < _activeRenderTextures.length; i++) {
      if (identical(renderTexture, _activeRenderTextures[i])) {
        _activeRenderTextures[i] = null;
        _renderingContext.activeTexture(gl.TEXTURE0 + i);
        _renderingContext.bindTexture(gl.TEXTURE_2D, null);
      }
    }
  }

  //---------------------------------------------------------------------------

  void activateRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (!identical(renderFrameBuffer, _activeRenderFrameBuffer)) {
      if (renderFrameBuffer is RenderFrameBuffer) {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = renderFrameBuffer;
        _activeRenderFrameBuffer.activate(this);
      } else {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = null;
        _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
      }
      var viewportWidth = _getViewportWidth();
      var viewportHeight = _getViewportHeight();
      _renderingContext.viewport(0, 0, viewportWidth, viewportHeight);
      _updateScissorTest(_getLastScissorValue());
      _updateStencilTest(_getLastStencilValue());
    }
  }

  void activateRenderStencilBuffer(RenderStencilBuffer renderStencilBuffer) {
    if (!identical(renderStencilBuffer, _activeRenderStencilBuffer)) {
      _activeRenderProgram.flush();
      _activeRenderStencilBuffer = renderStencilBuffer;
      _activeRenderStencilBuffer.activate(this);
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
      _renderingContext.blendFunc(blendMode.srcFactor, blendMode.dstFactor);
    }
  }

  void activateRenderTexture(RenderTexture renderTexture) {
    if (!identical(renderTexture, _activeRenderTextures[0])) {
      _activeRenderProgram.flush();
      _activeRenderTextures[0] = renderTexture;
      renderTexture.activate(this, gl.TEXTURE0);
    }
  }

  void activateRenderTextureAt(RenderTexture renderTexture, int index) {
    if (!identical(renderTexture, _activeRenderTextures[index])) {
      _activeRenderProgram.flush();
      _activeRenderTextures[index] = renderTexture;
      renderTexture.activate(this, gl.TEXTURE0 + index);
    }
  }

  void activateProjectionMatrix(Matrix3D matrix) {
    _projectionMatrix.copyFrom(matrix);
    _activeRenderProgram.flush();
    _activeRenderProgram.projectionMatrix = _projectionMatrix;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  int _getViewportWidth() {
    var rfb = _activeRenderFrameBuffer;
    return rfb is RenderFrameBuffer ? rfb.width : _canvasElement.width;
  }

  int _getViewportHeight() {
    var rfb = _activeRenderFrameBuffer;
    return rfb is RenderFrameBuffer ? rfb.height : _canvasElement.height;
  }

  List<_MaskState> _getMaskStates() {
    var rfb = _activeRenderFrameBuffer;
    return rfb is RenderFrameBuffer ? rfb._maskStates : _maskStates;
  }

  int _getLastStencilValue() {
    var maskStates = _getMaskStates();
    for (int i = maskStates.length - 1; i >= 0; i--) {
      var maskState = maskStates[i];
      if (maskState is _StencilMaskState) return maskState.value;
    }
    return 0;
  }

  Rectangle<num> _getLastScissorValue() {
    var maskStates = _getMaskStates();
    for (int i = maskStates.length - 1; i >= 0; i--) {
      var maskState = maskStates[i];
      if (maskState is _ScissorMaskState) return maskState.value;
    }
    return null;
  }

  void _updateStencilTest(int value) {
    if (value == 0) {
      _renderingContext.disable(gl.STENCIL_TEST);
    } else {
      _renderingContext.enable(gl.STENCIL_TEST);
      _renderingContext.stencilFunc(gl.EQUAL, value, 0xFF);
    }
  }

  void _updateScissorTest(Rectangle<num> value) {
    if (value == null) {
      _renderingContext.disable(gl.SCISSOR_TEST);
    } else {
      int viewportHeight = _getViewportHeight();
      int x1 = value.left.round();
      int y1 = viewportHeight - value.bottom.round();
      int x2 = value.right.round();
      int y2 = viewportHeight - value.top.round();
      _renderingContext.enable(gl.SCISSOR_TEST);
      _renderingContext.scissor(x1, y1, maxInt(x2 - x1, 0), maxInt(y2 - y1, 0));
    }
  }

  //---------------------------------------------------------------------------

  void _onContextLost(gl.ContextEvent contextEvent) {
    contextEvent.preventDefault();
    _contextValid = false;
    _contextLostEvent.add(new RenderContextEvent());
  }

  void _onContextRestored(gl.ContextEvent contextEvent) {
    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;
    _contextRestoredEvent.add(new RenderContextEvent());
  }
}
