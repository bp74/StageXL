part of stagexl.resources;

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

  BitmapData _bitmapData = null;

  //---------------------------------------------------------------------------

  TextureAtlasFrame(
      this.textureAtlas, this.textureAtlasQuad, this.name, this.rotation,
      this.offsetX, this.offsetY, this.originalWidth, this.originalHeight,
      this.frameX, this.frameY, this.frameWidth, this.frameHeight) {

    var s = new Rectangle<int>(frameX, frameY, frameWidth, frameHeight);
    var o = new Rectangle<int>(-offsetX, -offsetY, originalWidth, originalHeight);
    var q = new RenderTextureQuad.slice(textureAtlasQuad, s, o, rotation);
    _bitmapData = new BitmapData.fromRenderTextureQuad(q);
  }

  //---------------------------------------------------------------------------

  BitmapData get bitmapData => _bitmapData;

}
