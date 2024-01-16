part of '../engine.dart';

class RenderFrameBuffer {
  RenderTexture? _renderTexture;
  RenderStencilBuffer? _renderStencilBuffer;
  late RenderContextWebGL _renderContext;

  int _contextIdentifier = -1;
  gl.Framebuffer? _framebuffer;
  gl.RenderingContext? _renderingContext;

  final List<_MaskState> _maskStates = <_MaskState>[];

  RenderFrameBuffer.rawWebGL(int width, int height) {
    _renderTexture = RenderTexture.rawWebGL(width, height);
    _renderStencilBuffer = RenderStencilBuffer.rawWebGL(width, height);
  }

  //---------------------------------------------------------------------------

  int? get width => _renderTexture?.width;

  int? get height => _renderTexture?.height;

  int get contextIdentifier => _contextIdentifier;

  RenderTexture? get renderTexture => _renderTexture;

  RenderStencilBuffer? get renderStencilBuffer => _renderStencilBuffer;

  //---------------------------------------------------------------------------

  /// Call the dispose method to release memory allocated by WebGL.

  void dispose() {
    _renderTexture?.dispose();
    _renderStencilBuffer?.dispose();
    if (_framebuffer != null) {
      _renderingContext?.deleteFramebuffer(_framebuffer);
    }
    _contextIdentifier = -1;
    _renderTexture = null;
    _renderStencilBuffer = null;
    _framebuffer = null;
  }

  //---------------------------------------------------------------------------

  void activate(RenderContextWebGL renderContext) {
    if (contextIdentifier != renderContext.contextIdentifier) {
      _renderContext = renderContext;
      _contextIdentifier = renderContext.contextIdentifier;
      _renderingContext = renderContext.rawContext;
      _framebuffer = renderContext.rawContext.createFramebuffer();

      if (_renderTexture != null) {
        _renderContext.activateRenderTexture(_renderTexture!);
      }

      if (_renderStencilBuffer != null) {
        _renderContext.activateRenderStencilBuffer(_renderStencilBuffer!);
      }

      const target = gl.WebGL.FRAMEBUFFER;
      const color = gl.WebGL.COLOR_ATTACHMENT0;
      const colorTarget = gl.WebGL.TEXTURE_2D;
      final colorData = _renderTexture!.texture;
      const stencil = gl.WebGL.DEPTH_STENCIL_ATTACHMENT;
      const stencilTarget = gl.WebGL.RENDERBUFFER;
      final stencilData = _renderStencilBuffer!.renderbuffer;

      _renderingContext!.bindFramebuffer(target, _framebuffer);
      _renderingContext!
          .framebufferTexture2D(target, color, colorTarget, colorData, 0);
      _renderingContext!
          .framebufferRenderbuffer(target, stencil, stencilTarget, stencilData);
    } else {
      _renderingContext!.bindFramebuffer(gl.WebGL.FRAMEBUFFER, _framebuffer);
    }
  }
}
