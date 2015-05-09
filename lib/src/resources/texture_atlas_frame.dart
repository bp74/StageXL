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
    var taqSrcL = this.textureAtlasQuad.sourceRectangle.left;
    var taqSrcT = this.textureAtlasQuad.sourceRectangle.top;
    var taqSrcR = this.textureAtlasQuad.sourceRectangle.right;
    var taqSrcB = this.textureAtlasQuad.sourceRectangle.bottom;
    var taqOfsL = this.textureAtlasQuad.offsetRectangle.left;
    var taqOfsT = this.textureAtlasQuad.offsetRectangle.top;

    var newSrcL = this.frameX;
    var newSrcT = this.frameY;
    var newSrcR = this.frameX + this.frameWidth;
    var newSrcB = this.frameY + this.frameHeight;
    var newOfsL = 0 - this.offsetX;
    var newOfsT = 0 - this.offsetY;
    var newOfsW = this.originalWidth;
    var newOfsH = this.originalHeight;

    var srcL = 0, srcT = 0, srcR = 0, srcB = 0;
    var ofsL = 0, ofsT = 0;

    if (taqRotation == 0) {
      srcL = clampInt(taqSrcL + taqOfsL + newSrcL, taqSrcL, taqSrcR);
      srcT = clampInt(taqSrcT + taqOfsT + newSrcT, taqSrcT, taqSrcB);
      srcR = clampInt(taqSrcL + taqOfsL + newSrcR, taqSrcL, taqSrcR);
      srcB = clampInt(taqSrcT + taqOfsT + newSrcB, taqSrcT, taqSrcB);
      ofsL = newOfsL + newSrcL + taqOfsL + taqSrcL - srcL;
      ofsT = newOfsT + newSrcT + taqOfsT + taqSrcT - srcT;
    } else if (taqRotation == 1) {
      srcL = clampInt(taqSrcR - taqOfsT - newSrcB, taqSrcL, taqSrcR);
      srcT = clampInt(taqSrcT + taqOfsL + newSrcL, taqSrcT, taqSrcB);
      srcR = clampInt(taqSrcR - taqOfsT - newSrcT, taqSrcL, taqSrcR);
      srcB = clampInt(taqSrcT + taqOfsL + newSrcR, taqSrcT, taqSrcB);
      ofsL = newOfsL + newSrcL + taqOfsL + taqSrcT - srcT;
      ofsT = newOfsT + newSrcT + taqOfsT - taqSrcR + srcR;
    } else if (taqRotation == 2) {
      srcL = clampInt(taqSrcR - taqOfsL - newSrcR, taqSrcL, taqSrcR);
      srcT = clampInt(taqSrcB - taqOfsT - newSrcB, taqSrcT, taqSrcB);
      srcR = clampInt(taqSrcR - taqOfsL - newSrcL, taqSrcL, taqSrcR);
      srcB = clampInt(taqSrcB - taqOfsT - newSrcT, taqSrcT, taqSrcB);
      ofsL = newOfsL + newSrcL + taqOfsL - taqSrcR + srcR;
      ofsT = newOfsT + newSrcT + taqOfsT - taqSrcB + srcB;
    } else if (taqRotation == 3) {
      srcL = clampInt(taqSrcL + taqOfsT + newSrcT, taqSrcL, taqSrcR);
      srcT = clampInt(taqSrcB - taqOfsL - newSrcR, taqSrcT, taqSrcB);
      srcR = clampInt(taqSrcL + taqOfsT + newSrcB, taqSrcL, taqSrcR);
      srcB = clampInt(taqSrcB - taqOfsL - newSrcL, taqSrcT, taqSrcB);
      ofsL = newOfsL + newSrcL + taqOfsL - taqSrcB + srcB;
      ofsT = newOfsT + newSrcT + taqOfsT + taqSrcL - srcL;
    }

    var renderTextureQuad = new RenderTextureQuad(taqRenderTexture,
        new Rectangle<int>(srcL, srcT, srcR - srcL, srcB - srcT),
        new Rectangle<int>(ofsL, ofsT, newOfsW, newOfsH),
        (taqRotation + this.rotation) % 4, taqPixelRatio);

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad);
  }
}
