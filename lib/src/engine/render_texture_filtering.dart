part of '../engine.dart';

/// The RenderTextureFiltering defines the method that is used to determine
/// the texture color for a texture mapped pixel, using the colors of nearby
/// texels (pixels of the texture).
///
/// See also: [RenderTexture.filtering]
///
class RenderTextureFiltering {
  final int value;

  const RenderTextureFiltering(this.value);

  static const RenderTextureFiltering NEAREST =
      RenderTextureFiltering(gl.WebGL.NEAREST);
  static const RenderTextureFiltering LINEAR =
      RenderTextureFiltering(gl.WebGL.LINEAR);
}
