part of stagexl.resources;

class TextureAtlasFrame {

  final TextureAtlas textureAtlas;
  final String name;
  final int rotation;

  final int originalWidth;
  final int originalHeight;
  final int offsetX;
  final int offsetY;

  final int frameX;
  final int frameY;
  final int frameWidth;
  final int frameHeight;

  RenderTexture renderTexture = null;

  TextureAtlasFrame(this.textureAtlas, this.name, this.rotation,
      this.originalWidth, this.originalHeight, this.offsetX, this.offsetY,
      this.frameX, this.frameY, this.frameWidth, this.frameHeight);

  TextureAtlasFrame._fromJson(this.textureAtlas, this.name, Map frame) :
    rotation = ensureBool(frame["rotated"]) ? 1 : 0,
    originalWidth = ensureInt(frame["sourceSize"]["w"]),
    originalHeight = ensureInt(frame["sourceSize"]["h"]),
    offsetX = ensureInt(frame["spriteSourceSize"]["x"]),
    offsetY = ensureInt(frame["spriteSourceSize"]["y"]),
    frameX = ensureInt(frame["frame"]["x"]),
    frameY = ensureInt(frame["frame"]["y"]),
    frameWidth = ensureInt(frame["frame"]["w"]),
    frameHeight = ensureInt(frame["frame"]["h"]);

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData() {

    var textureX = frameX;
    var textureY = frameY;
    var textureWidth = frameWidth;
    var textureHeight = frameHeight;

    if (rotation == 0) {
      textureX = frameX;
      textureY = frameY;
    } else if (rotation == 1) {
      textureX = frameX + frameHeight;
      textureY = frameY;
    } else if (rotation == 2) {
      textureX = frameX + frameWidth;
      textureY = frameY + frameHeight;
    } else if (rotation == 3) {
      textureX = frameX;
      textureY = frameY + frameWidth;
    }

    var renderTextureQuad = new RenderTextureQuad(renderTexture,
        rotation, offsetX, offsetY, textureX, textureY, textureWidth, textureHeight);

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad, originalWidth, originalHeight);
  }

}
