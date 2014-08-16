part of stagexl;

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
    rotation = _ensureBool(frame["rotated"]) ? 1 : 0,
    originalWidth = _ensureInt(frame["sourceSize"]["w"]),
    originalHeight = _ensureInt(frame["sourceSize"]["h"]),
    offsetX = _ensureInt(frame["spriteSourceSize"]["x"]),
    offsetY = _ensureInt(frame["spriteSourceSize"]["y"]),
    frameX = _ensureInt(frame["frame"]["x"]),
    frameY = _ensureInt(frame["frame"]["y"]),
    frameWidth = _ensureInt(frame["frame"]["w"]),
    frameHeight = _ensureInt(frame["frame"]["h"]);

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData() {

    var renderTextureQuad = renderTexture.quad;

    if (rotation == 0) {
      renderTextureQuad = new RenderTextureQuad(renderTexture,
          0, offsetX, offsetY, frameX, frameY, frameWidth, frameHeight);
    } else if (rotation == 1) {
      renderTextureQuad = new RenderTextureQuad(renderTexture,
          1, offsetX, offsetY, frameX + frameHeight, frameY, frameWidth, frameHeight);
    } else if (rotation == 2) {
      renderTextureQuad = new RenderTextureQuad(renderTexture,
          2, offsetX, offsetY, frameX + frameWidth, frameY + frameHeight, frameWidth, frameHeight);
    } else if (rotation == 3) {
      renderTextureQuad = new RenderTextureQuad(renderTexture,
          3, offsetX, offsetY, frameX, frameY + frameWidth, frameWidth, frameHeight);
    }

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad, originalWidth, originalHeight);
  }

}
