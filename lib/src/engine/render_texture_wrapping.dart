part of '../engine.dart';

class RenderTextureWrapping {
  final int value;

  const RenderTextureWrapping(this.value);

  static const RenderTextureWrapping REPEAT =
      RenderTextureWrapping(web.WebGLRenderingContext.REPEAT);
  static const RenderTextureWrapping CLAMP =
      RenderTextureWrapping(web.WebGLRenderingContext.CLAMP_TO_EDGE);
}
