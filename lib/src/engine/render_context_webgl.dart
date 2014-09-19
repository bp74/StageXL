part of stagexl.engine;

class RenderContextWebGL extends RenderContext {

  static int _globalContextIdentifier = 0;

  final CanvasElement _canvasElement;

  final RenderProgramQuad renderProgramQuad = new RenderProgramQuad();
  final RenderProgramTriangle renderProgramTriangle = new RenderProgramTriangle();
  final RenderProgramMesh renderProgramMesh = new RenderProgramMesh();

  final List<RenderFrameBuffer> _renderFrameBufferPool = new List<RenderFrameBuffer>();

  gl.RenderingContext _renderingContext = null;
  Matrix3D _projectionMatrix = new Matrix3D.fromIdentity();

  RenderTexture _activeRenderTexture = null;
  RenderProgram _activeRenderProgram = null;
  RenderFrameBuffer _activeRenderFrameBuffer = null;
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
  String get renderEngine => RenderEngine.WebGL;

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

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {
    activateRenderProgram(renderProgramQuad);
    activateBlendMode(renderState.globalBlendMode);
    activateRenderTexture(renderTextureQuad.renderTexture);
    renderProgramQuad.renderQuad(renderState, renderTextureQuad);
  }

  //-----------------------------------------------------------------------------------------------

  void renderTriangle(RenderState renderState,
                      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    activateRenderProgram(renderProgramTriangle);
    activateBlendMode(renderState.globalBlendMode);
    renderProgramTriangle.renderTriangle(renderState, x1, y1, x2, y2, x3, y3, color);
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

    int stencilDepth = _getStencilDepth();

    _activeRenderProgram.flush();

    _renderingContext.enable(gl.STENCIL_TEST);
    _renderingContext.stencilFunc(gl.EQUAL, stencilDepth, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, depthDelta == 1 ? gl.INCR : gl.DECR);
    _renderingContext.stencilMask(0xFF);
    _renderingContext.colorMask(false, false, false, false);

    mask.renderMask(renderState);
    renderState.flush();

    _renderingContext.stencilFunc(gl.EQUAL, stencilDepth + depthDelta, 0xFF);
    _renderingContext.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    _renderingContext.stencilMask(0x00);
    _renderingContext.colorMask(true, true, true, true);

    _updateStencilDepth(stencilDepth + depthDelta);
  }

  //-----------------------------------------------------------------------------------------------

  RenderFrameBuffer requestRenderFrameBuffer(int width, int height) {
    _activeRenderProgram.flush();
    if (_renderFrameBufferPool.length > 0) {
      return _renderFrameBufferPool.removeLast()..resize(width, height);
    } else {
      return new RenderFrameBuffer(this, width, height);
    }
  }

  void releaseRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (renderFrameBuffer != null) {
      _renderFrameBufferPool.add(renderFrameBuffer);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void activateRenderFrameBuffer(RenderFrameBuffer renderFrameBuffer) {
    if (identical(renderFrameBuffer, _activeRenderFrameBuffer) == false) {
      _activeRenderProgram.flush();
      _activeRenderFrameBuffer = renderFrameBuffer;

      int width, height, stencilDepth;
      gl.Framebuffer framebuffer;

      if (renderFrameBuffer != null) {
        width = renderFrameBuffer.width;
        height = renderFrameBuffer.height;
        framebuffer = renderFrameBuffer.framebuffer;
        stencilDepth = renderFrameBuffer.stencilDepth;
      } else {
        width = _viewportWidth;
        height = _viewportHeight;
        framebuffer = null;
        stencilDepth = _stencilDepth;
      }

      _renderingContext.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
      _renderingContext.viewport(0, 0, width, height);
      _updateStencilState(stencilDepth);
    }
  }

  void activateRenderProgram(RenderProgram renderProgram) {
    if (identical(renderProgram, _activeRenderProgram) == false) {
      _activeRenderProgram.flush();
      _activeRenderProgram = renderProgram;
      _activeRenderProgram.activate(this);
      _activeRenderProgram.projectionMatrix = _projectionMatrix;
    }
  }

  void activateBlendMode(BlendMode blendMode) {
    if (identical(blendMode, _activeBlendMode) == false) {
      _activeRenderProgram.flush();
      _activeBlendMode = blendMode;
      _renderingContext.blendFunc(blendMode.srcFactor, blendMode.dstFactor);
    }
  }

  void activateRenderTexture(RenderTexture renderTexture) {
    if (identical(renderTexture, _activeRenderTexture) == false) {
      _activeRenderProgram.flush();
      _activeRenderTexture = renderTexture;
      _activeRenderTexture.activate(this, gl.TEXTURE0);
    }
  }

  void activateProjectionMatrix(Matrix3D matrix) {
    _projectionMatrix.copyFromMatrix3D(matrix);
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

  int _getStencilDepth() {
    return _activeRenderFrameBuffer != null
        ? _activeRenderFrameBuffer._stencilDepth
        : _stencilDepth;
  }

  _updateStencilDepth(int stencilDepth) {
    if (_activeRenderFrameBuffer != null) {
      if (_activeRenderFrameBuffer._stencilDepth != stencilDepth) {
        _activeRenderFrameBuffer._stencilDepth = stencilDepth;
        _updateStencilState(stencilDepth);
      }
    } else {
      if (_stencilDepth != stencilDepth) {
        _stencilDepth = stencilDepth;
        _updateStencilState(stencilDepth);
      }
    }
  }

  _updateStencilState(int stencilDepth) {
    if (stencilDepth == 0) {
      _renderingContext.disable(gl.STENCIL_TEST);
    } else {
      _renderingContext.enable(gl.STENCIL_TEST);
      _renderingContext.stencilFunc(gl.EQUAL, stencilDepth, 0xFF);
    }
  }

}