part of stagexl.engine;

class RenderContextWebGL extends RenderContext {

  static int _globalContextIdentifier = 0;

  final CanvasElement _canvasElement;

  final RenderProgramQuad renderProgramQuad = new RenderProgramQuad();
  final RenderProgramTriangle renderProgramTriangle = new RenderProgramTriangle();
  final RenderProgramMesh renderProgramMesh = new RenderProgramMesh();

  final RenderBufferIndex renderBufferIndexQuads = new RenderBufferIndex.forQuads(2048);
  final RenderBufferIndex renderBufferIndexTriangles = new RenderBufferIndex.forTriangles(2048);
  final RenderBufferVertex renderBufferVertex = new RenderBufferVertex(32768);

  final List<RenderFrameBuffer> _renderFrameBufferPool = new List<RenderFrameBuffer>();
  final Map<int, RenderTexture> _activeRenderTextures = new  Map<int, RenderTexture>();
  final Map<String, RenderProgram> _renderPrograms = new Map<String, RenderProgram>();

  gl.RenderingContext _renderingContext = null;
  Matrix3D _projectionMatrix = new Matrix3D.fromIdentity();

  RenderTexture _activeRenderTexture = null;
  RenderProgram _activeRenderProgram = null;
  RenderFrameBuffer _activeRenderFrameBuffer = null;
  RenderStencilBuffer _activeRenderStencilBuffer = null;
  BlendMode _activeBlendMode = null;

  bool _contextValid = true;
  int _contextIdentifier = 0;
  int _stencilDepth = 0;
  int _viewportWidth = 0;
  int _viewportHeight = 0;

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

    _activeRenderProgram = renderProgramQuad;
    _activeRenderProgram.activate(this);

    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;

    this.reset();
  }

  //-----------------------------------------------------------------------------------------------

  gl.RenderingContext get rawContext => _renderingContext;
  RenderEngine get renderEngine => RenderEngine.WebGL;

  RenderTexture get activeRenderTexture => _activeRenderTexture;
  RenderProgram get activeRenderProgram => _activeRenderProgram;
  RenderFrameBuffer get activeRenderFrameBuffer => _activeRenderFrameBuffer;
  Matrix3D get activeProjectionMatrix => _projectionMatrix;
  BlendMode get activeBlendMode => _activeBlendMode;

  bool get contextValid => _contextValid;
  int get contextIdentifier => _contextIdentifier;

  //-----------------------------------------------------------------------------------------------

  void reset() {

    _viewportWidth = _canvasElement.width;
    _viewportHeight = _canvasElement.height;

    _activeRenderFrameBuffer = null;
    _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
    _renderingContext.viewport(0, 0, _viewportWidth, _viewportHeight);

    _projectionMatrix.setIdentity();
    _projectionMatrix.scale(2.0 / _viewportWidth, - 2.0 / _viewportHeight, 1.0);
    _projectionMatrix.translate(-1.0, 1.0, 0.0);

    _activeRenderProgram.projectionMatrix = _projectionMatrix;
  }

  void clear(int color) {

    num r = colorGetR(color) / 255.0;
    num g = colorGetG(color) / 255.0;
    num b = colorGetB(color) / 255.0;
    num a = colorGetA(color) / 255.0;

    _renderingContext.colorMask(true, true, true, true);
    _renderingContext.clearColor(r, g, b, a);
    _renderingContext.clear(gl.COLOR_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
    _updateStencilDepth(0);
  }

  void flush() {
    _activeRenderProgram.flush();
  }

  RenderProgram getRenderProgram(String name, RenderProgram ifAbsent()) {
    return _renderPrograms.putIfAbsent(name, ifAbsent);
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  void renderQuad(
    RenderState renderState, RenderTextureQuad renderTextureQuad) {

    activateRenderProgram(renderProgramQuad);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTextureQuad.renderTexture);
    renderProgramQuad.renderQuad(renderState, renderTextureQuad);
  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(
    RenderState renderState,
    num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangle(renderState, x1, y1, x2, y2, x3, y3, color);
  }

  //-----------------------------------------------------------------------------------------------

  void renderMesh(
    RenderState renderState, RenderTexture renderTexture,
    int indexCount, Int16List indexList,
    int vertexCount, Float32List xyList, Float32List uvList) {

    activateRenderProgram(renderProgramMesh);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTexture);

    renderProgramMesh.renderMesh(
        renderState,
        indexCount, indexList,
        vertexCount, xyList, uvList,
        1.0, 1.0, 1.0, 1.0);
  }

  //-----------------------------------------------------------------------------------------------

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
    var filterRenderFrameBuffer = this.getRenderFrameBuffer();
    var renderFrameBufferMap = new Map<int, RenderFrameBuffer>();

    filterProjectionMatrix.translate(-boundsLeft, -boundsTop, 0.0);
    filterProjectionMatrix.scale(2.0 / boundsWidth, 2.0 / boundsHeight, 1.0);
    filterProjectionMatrix.translate(-1.0, -1.0, 0.0);

    filterRenderFrameBuffer.resize(boundsWidth, boundsHeight);
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
      renderQuadFiltered(filterRenderState, renderTextureQuad, [filters[0]]);
      filters = filters.sublist(1);
    } else {
      renderObject.render(filterRenderState);
    }

    //----------------------------------------------

    for (int i = 0; i < filters.length; i++) {

      RenderTextureQuad sourceRenderTextureQuad = null;
      RenderFrameBuffer sourceRenderFrameBuffer = null;
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
          filterRenderFrameBuffer = this.getRenderFrameBuffer();
          filterRenderFrameBuffer.resize(boundsWidth, boundsHeight);
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
          this.flush();
          this.releaseRenderFrameBuffer(sourceRenderFrameBuffer);
        }
      }

      renderFrameBufferMap.clear();
      renderFrameBufferMap[0] = filterRenderFrameBuffer;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderQuadFiltered(
    RenderState renderState, RenderTextureQuad renderTextureQuad,
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

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  void beginRenderMask(RenderState renderState, RenderMask mask) {
    _renderMask(renderState, mask, 1);
  }

  void endRenderMask(RenderState renderState, RenderMask mask) {
    _renderMask(renderState, mask, -1);
  }

  void _renderMask(RenderState renderState, RenderMask mask, int depthDelta) {

    var rfb = _activeRenderFrameBuffer;
    var stencilDepth = rfb != null ? rfb.renderStencilBuffer.depth : _stencilDepth;

    _activeRenderProgram.flush();
    _renderingContext.enable(gl.STENCIL_TEST);
    _renderingContext.stencilFunc(gl.EQUAL, stencilDepth, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, depthDelta == 1 ? gl.INCR : gl.DECR);
    _renderingContext.stencilMask(0xFF);
    _renderingContext.colorMask(false, false, false, false);

    mask.renderMask(renderState);

    _activeRenderProgram.flush();
    _renderingContext.stencilFunc(gl.EQUAL, stencilDepth + depthDelta, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    _renderingContext.stencilMask(0x00);
    _renderingContext.colorMask(true, true, true, true);

    _updateStencilDepth(stencilDepth + depthDelta);
  }

  //-----------------------------------------------------------------------------------------------

  RenderFrameBuffer getRenderFrameBuffer() {
    if (_renderFrameBufferPool.length > 0) {
      return _renderFrameBufferPool.removeLast();
    } else {
      return new RenderFrameBuffer.rawWebGL(1, 1);
    }
  }

  void releaseRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (renderFrameBuffer is RenderFrameBuffer) {
      _renderFrameBufferPool.add(renderFrameBuffer);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activateRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (!identical(renderFrameBuffer, _activeRenderFrameBuffer)) {
      if (renderFrameBuffer is RenderFrameBuffer) {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = renderFrameBuffer;
        _activeRenderFrameBuffer.activate(this);
        _renderingContext.viewport(0, 0, renderFrameBuffer.width, renderFrameBuffer.height);
        _updateStencilTest(renderFrameBuffer.renderStencilBuffer.depth);
      } else {
        _activeRenderProgram.flush();
        _activeRenderFrameBuffer = null;
        _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, null);
        _renderingContext.viewport(0, 0, _viewportWidth, _viewportHeight);
        _updateStencilTest(_stencilDepth);
      }
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
    if (!identical(renderTexture, _activeRenderTexture)) {
      _activeRenderProgram.flush();
      _activeRenderTexture = renderTexture;
      _activeRenderTexture.activate(this, gl.TEXTURE0);
    }
  }

  void activateRenderTextureAt(RenderTexture renderTexture, int index) {
    if (index < 0 || index > 7) {
      throw new RangeError.range(index, 0, 7, "index");
    } else if (index == 0) {
      activateRenderTexture(renderTexture);
    } else if (!identical(renderTexture, _activeRenderTextures[index])) {
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

  //-----------------------------------------------------------------------------------------------

  _onContextLost(gl.ContextEvent contextEvent) {
    contextEvent.preventDefault();
    _contextValid = false;
    _contextLostEvent.add(new RenderContextEvent());
  }

  _onContextRestored(gl.ContextEvent contextEvent) {
    _contextValid = true;
    _contextIdentifier = ++_globalContextIdentifier;
    _contextRestoredEvent.add(new RenderContextEvent());
  }

  //-----------------------------------------------------------------------------------------------

  _updateStencilDepth(int stencilDepth) {
    if (_activeRenderFrameBuffer is RenderFrameBuffer) {
      _activeRenderFrameBuffer.renderStencilBuffer.depth = stencilDepth;
      _updateStencilTest(stencilDepth);
    } else {
      _stencilDepth = stencilDepth;
      _updateStencilTest(stencilDepth);
    }
  }

  _updateStencilTest(int stencilDepth) {
    if (stencilDepth == 0) {
      _renderingContext.disable(gl.STENCIL_TEST);
    } else {
      _renderingContext.enable(gl.STENCIL_TEST);
      _renderingContext.stencilFunc(gl.EQUAL, stencilDepth, 0xFF);
    }
  }

}
