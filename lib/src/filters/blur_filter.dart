part of stagexl;

class BlurFilter extends BitmapFilter {

  int blurX;
  int blurY;

  //-------------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://members.chello.at/easyfilter/gauss.html
  // http://members.chello.at/easyfilter/gauss.pdf
  //-------------------------------------------------------------------------------------------------

  BlurFilter([this.blurX = 4, this.blurY = 4]) {
    if (blurX < 1 || blurY < 1) {
      throw new ArgumentError("Error #9004: The minimum blur size is 1.");
    }
    if (blurX > 64 || blurY > 64) {
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
    }
  }

  BitmapFilter clone() => new BlurFilter(blurX, blurY);
  Rectangle get overlap => new Rectangle(-blurX, -blurY, 2 * blurX, 2 * blurY);

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;
    int width = _ensureInt(imageData.width);
    int height = _ensureInt(imageData.height);

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    int blurX = (this.blurX * pixelRatio).round();
    int blurY = (this.blurY * pixelRatio).round();
    int stride = width * 4;

    _premultiplyAlpha(data);

    for (int x = 0; x < width; x++) {
      _blur2(data, x * 4 + 0, height, stride, blurY);
      _blur2(data, x * 4 + 1, height, stride, blurY);
      _blur2(data, x * 4 + 2, height, stride, blurY);
      _blur2(data, x * 4 + 3, height, stride, blurY);
    }

    for (int y = 0; y < height; y++) {
      _blur2(data, y * stride + 0, width, 4, blurX);
      _blur2(data, y * stride + 1, width, 4, blurX);
      _blur2(data, y * stride + 2, width, 4, blurX);
      _blur2(data, y * stride + 3, width, 4, blurX);
    }

    _unpremultiplyAlpha(data);

    renderTextureQuad.putImageData(imageData);
  }
}


