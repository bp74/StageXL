part of stagexl.resources;

class TextureAtlasFrame {

  final TextureAtlas textureAtlas;
  final String name;
  final int rotation;
  final num pixelRatio;

  final int offsetX;
  final int offsetY;
  final int originalWidth;
  final int originalHeight;

  final int frameX;
  final int frameY;
  final int frameWidth;
  final int frameHeight;

  RenderTexture renderTexture = null;

  TextureAtlasFrame(this.textureAtlas, this.name, this.rotation, this.pixelRatio,
      this.offsetX, this.offsetY, this.originalWidth, this.originalHeight,
      this.frameX, this.frameY, this.frameWidth, this.frameHeight);

  //-----------------------------------------------------------------------------------------------

  BitmapData getBitmapData() {

    var sourceRect = new Rectangle<int>(frameX, frameY, frameWidth, frameHeight);
    var offsetRect = new Rectangle<int>(-offsetX, -offsetY, originalWidth, originalHeight);
    var renderTextureQuad = new RenderTextureQuad(
        renderTexture, sourceRect, offsetRect, rotation, pixelRatio);

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }

}
