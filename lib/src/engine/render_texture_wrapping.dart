part of stagexl.engine;

class RenderTextureWrapping {
  final int value;

  const RenderTextureWrapping(this.value);

  static const RenderTextureWrapping REPEAT =
      RenderTextureWrapping(gl.WebGL.REPEAT);
  static const RenderTextureWrapping CLAMP =
      RenderTextureWrapping(gl.WebGL.CLAMP_TO_EDGE);
}
