part of stagexl.engine;

class RenderTextureWrapping {

  final int value;

  const RenderTextureWrapping(this.value);

  static const RenderTextureWrapping REPEAT = const RenderTextureWrapping(gl.REPEAT);
  static const RenderTextureWrapping CLAMP  = const RenderTextureWrapping(gl.CLAMP_TO_EDGE);
}
