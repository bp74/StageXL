part of stagexl;

class GlowFilter extends BitmapFilter {

  int color;
  num alpha;
  int blurX;
  int blurY;

  GlowFilter([this.color = 0, this.alpha = 1.0, this.blurX = 4, this.blurY = 4]) {
    if (blurX < 1 || blurY < 1) {
      throw new ArgumentError("Error #9004: The minimum blur size is 1.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new GlowFilter(color, alpha, blurX, blurY);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    var renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    var sourceImageData = renderTextureQuad.getImageData();
    var imageData = renderTextureQuad.getImageData();
    var data = imageData.data;
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

    // TODO: _setColor and _blend could be combined in one operation!

    _setColor(data, this.color, this.alpha);
    _blend(data, sourceImageData.data);

    renderTextureQuad.putImageData(imageData);
  }


}
