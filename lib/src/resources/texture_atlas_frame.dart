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

  TextureAtlasFrame(
      this.textureAtlas, this.textureAtlasQuad, this.name, this.rotation,
      this.offsetX, this.offsetY, this.originalWidth, this.originalHeight,
      this.frameX, this.frameY, this.frameWidth, this.frameHeight);

  //---------------------------------------------------------------------------

  BitmapData get bitmapData {
    if (_bitmapData == null) _bitmapData = _calculateBitmapData();
    return _bitmapData;
  }

  //---------------------------------------------------------------------------

  BitmapData _calculateBitmapData() {

    var taqRenderTexture = this.textureAtlasQuad.renderTexture;
    var taqPixelRatio = this.textureAtlasQuad.pixelRatio;
    var taqRotation = this.textureAtlasQuad.rotation;
    var taqSourceL = this.textureAtlasQuad.sourceRectangle.left;
    var taqSourceT = this.textureAtlasQuad.sourceRectangle.top;
    var taqSourceR = this.textureAtlasQuad.sourceRectangle.right;
    var taqSourceB = this.textureAtlasQuad.sourceRectangle.bottom;
    var taqOffsetL = this.textureAtlasQuad.offsetRectangle.left;
    var taqOffsetT = this.textureAtlasQuad.offsetRectangle.top;

    var newRenderTexture = taqRenderTexture;
    var newPixelRatio = taqPixelRatio;
    var newRotation = (taqRotation + this.rotation) % 4;
    var newSourceL = this.frameX;
    var newSourceT = this.frameY;
    var newSourceR = this.frameX + this.frameWidth;
    var newSourceB = this.frameY + this.frameHeight;
    var newOffsetL = 0 - this.offsetX;
    var newOffsetT = 0 - this.offsetY;
    var newOffsetW = this.originalWidth;
    var newOffsetH = this.originalHeight;

    var tmpSourceL = 0;
    var tmpSourceT = 0;
    var tmpSourceR = 0;
    var tmpSourceB = 0;

    if (taqRotation == 0) {
      tmpSourceL = taqSourceL + taqOffsetL + newSourceL;
      tmpSourceT = taqSourceT + taqOffsetT + newSourceT;
      tmpSourceR = taqSourceL + taqOffsetL + newSourceR;
      tmpSourceB = taqSourceT + taqOffsetT + newSourceB;
    } else if (taqRotation == 1) {
      tmpSourceL = taqSourceR - taqOffsetT - newSourceB;
      tmpSourceT = taqSourceT + taqOffsetL + newSourceL;
      tmpSourceR = taqSourceR - taqOffsetT - newSourceT;
      tmpSourceB = taqSourceT + taqOffsetL + newSourceR;
    } else if (taqRotation == 2) {
      tmpSourceL = taqSourceR - taqOffsetL - newSourceR;
      tmpSourceT = taqSourceB - taqOffsetT - newSourceB;
      tmpSourceR = taqSourceR - taqOffsetL - newSourceL;
      tmpSourceB = taqSourceB - taqOffsetT - newSourceT;
    } else if (taqRotation == 3) {
      tmpSourceL = taqSourceL + taqOffsetT + newSourceT;
      tmpSourceT = taqSourceB - taqOffsetL - newSourceR;
      tmpSourceR = taqSourceL + taqOffsetT + newSourceB;
      tmpSourceB = taqSourceB - taqOffsetL - newSourceL;
    }

    newSourceL = clampInt(tmpSourceL, taqSourceL, taqSourceR);
    newSourceT = clampInt(tmpSourceT, taqSourceT, taqSourceB);
    newSourceR = clampInt(tmpSourceR, taqSourceL, taqSourceR);
    newSourceB = clampInt(tmpSourceB, taqSourceT, taqSourceB);

    if (newRotation == 0) {
      newOffsetL += tmpSourceL - newSourceL;
      newOffsetT += tmpSourceT - newSourceT;
    } else if (newRotation == 1) {
      newOffsetL += tmpSourceT - newSourceT;
      newOffsetT += newSourceR - tmpSourceR;
    } else if (newRotation == 2) {
      newOffsetL += newSourceR - tmpSourceR;
      newOffsetT += tmpSourceB - newSourceB;
    } else if (newRotation == 3) {
      newOffsetL += newSourceB - tmpSourceB;
      newOffsetT += newSourceL - tmpSourceL;
    }

    var newSourceW = newSourceR - newSourceL;
    var newSourceH = newSourceB - newSourceT;

    var renderTextureQuad = new RenderTextureQuad(newRenderTexture,
        new Rectangle<int>(newSourceL, newSourceT, newSourceW, newSourceH),
        new Rectangle<int>(newOffsetL, newOffsetT, newOffsetW, newOffsetH),
        newRotation, newPixelRatio);

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }
}
