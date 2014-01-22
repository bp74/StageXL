part of stagexl;

class GlowFilter extends BitmapFilter {

  int color;
  num alpha;
  int blurX;
  int blurY;
  bool knockout;
  bool hideObject;

  GlowFilter(this.color, this.alpha, this.blurX, this.blurY, {
             this.knockout: false, this.hideObject: false}) {

    if (blurX < 1 || blurY < 1) {
      throw new ArgumentError("Error #9004: The minimum blur size is 1.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new GlowFilter(color, alpha, blurX, blurY,
      knockout: knockout, hideObject: hideObject);

  Rectangle get overlap => new Rectangle(-blurX, -blurY, 2 * blurX, 2 * blurY);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData sourceImageData =
        this.hideObject == false || this.knockout ? renderTextureQuad.getImageData() : null;

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = _ensureInt(imageData.width);
    int height = _ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int alphaChannel = _isLittleEndianSystem ? 3 : 0;
    int stride = width * 4;

    for (int x = 0; x < width; x++) {
      _blur2(data, x * 4 + alphaChannel, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      _blur2(data, y * stride + alphaChannel, width, 4, blurX);
    }

    if (this.knockout) {
      _setColorKnockout(data, this.color, this.alpha, sourceImageData.data);
    } else if (this.hideObject) {
      _setColor(data, this.color, this.alpha);
    } else {
      _setColorBlend(data, this.color, this.alpha, sourceImageData.data);
    }

    renderTextureQuad.putImageData(imageData);
  }


}
