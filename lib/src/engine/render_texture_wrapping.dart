part of stagexl.engine;

class RenderTextureWrapping {
  final int value;

  const RenderTextureWrapping(this.value);

  static const RenderTextureWrapping REPEAT =
      const RenderTextureWrapping(gl.WebGL.REPEAT);
  static const RenderTextureWrapping CLAMP =
      const RenderTextureWrapping(gl.WebGL.CLAMP_TO_EDGE);
}
