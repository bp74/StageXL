part of stagexl.engine;

/// The RenderTextureFilter is used to change the texture filtering
/// of RenderTextures.
///
/// See also: [RenderTexture.filter]
///
class RenderTextureFilter {

  final int glFilter;

  const RenderTextureFilter(this.glFilter);

  static const NEAREST = const RenderTextureFilter(gl.NEAREST);
  static const LINEAR  = const RenderTextureFilter(gl.LINEAR);
}