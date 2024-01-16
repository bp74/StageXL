part of '../resources.dart';

class TextureAtlasFrame {
  final TextureAtlas textureAtlas;
  final RenderTextureQuad textureAtlasQuad;
  final String name;
  final int rotation;

  final int offsetX;
  final int offsetY;
  final int originalWidth;
  final int originalHeight;

  final int frameX;
  final int frameY;
  final int frameWidth;
  final int frameHeight;

  final Float32List? vxList;
  final Int16List? ixList;

  late final BitmapData _bitmapData;

  //---------------------------------------------------------------------------

  TextureAtlasFrame(
      this.textureAtlas,
      this.textureAtlasQuad,
      this.name,
      this.rotation,
      this.offsetX,
      this.offsetY,
      this.originalWidth,
      this.originalHeight,
      this.frameX,
      this.frameY,
      this.frameWidth,
      this.frameHeight,
      this.vxList,
      this.ixList) {
    final s = Rectangle<int>(frameX, frameY, frameWidth, frameHeight);
    final o = Rectangle<int>(-offsetX, -offsetY, originalWidth, originalHeight);
    final q = RenderTextureQuad.slice(textureAtlasQuad, s, o, rotation);

    if (vxList != null && ixList != null) {
      q.setCustomVertices(vxList!, ixList!);
    } else {
      q.setQuadVertices();
    }

    _bitmapData = BitmapData.fromRenderTextureQuad(q);
  }

  //---------------------------------------------------------------------------

  BitmapData get bitmapData => _bitmapData;
}
