class GlowFilter extends BitmapFilter
{
  int color;
  num alpha;
  int blurX;
  int blurY;
  num strength;
  int quality;
  bool inner;
  bool knockout;
  bool hideObject;

  GlowFilter([this.color = 0, this.alpha = 1.0, this.blurX = 4, this.blurY = 4, this.strength = 2.0, this.quality = 1, this.inner = false, this.knockout = false, this.hideObject = false]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone()
  {
    return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var sourceData = sourceImageData.data;

    int sourceWidth = sourceRect.width;
    int sourceHeight = sourceRect.height;
    int radiusX = sqrt(5 * blurX * blurX + 1).toInt();
    int radiusY = sqrt(5 * blurY * blurY + 1).toInt();
    int weightX = radiusX * radiusX;
    int weightY = radiusY * radiusY;
    int rx1 = radiusX;
    int rx2 = radiusX * 2;
    int ry1 = radiusY;
    int ry2 = radiusY * 2;
    int destinationWidth = sourceWidth + rx2;
    int destinationHeight = sourceHeight + ry2;
    int sourceWidth4 = sourceWidth * 4;
    int destinationWidth4 = destinationWidth * 4;

    var destinationContext = destinationBitmapData._getContext();
    var destinationImageData = destinationContext.createImageData(destinationWidth, destinationHeight);
    var destinationData = destinationImageData.data;

    List<int> buffer = new List<int>(1024);
    int alphaChannel = 3;

    //--------------------------------------------------

    // blur vertical
    for (int x = 0; x < sourceWidth; x++) {
      int dif = 0, sum = weightY >> 1;
      int offsetSource = x * 4 + alphaChannel;
      int offsetDestination = (x + rx1) * 4 + alphaChannel;

      for (int y = 0 - ry2; y < sourceHeight; y++) {
        destinationData[offsetDestination] = sum ~/ weightY;
        offsetDestination += destinationWidth4;

        if (y >= 0) {
          dif -= 2 * buffer[y & 1023] - buffer[(y - ry1) & 1023];
        } else if (y + ry1 >= 0) {
          dif -= 2 * buffer[y & 1023];
        }

        var ty = y + ry2;
        int alpha = (ty >= 0 && ty < sourceHeight) ? sourceData[offsetSource + ty * sourceWidth4] : 0;
        buffer[(y + ry1) & 1023] = alpha;
        sum += dif += alpha;
      }
    }

    // blur horizontal
    for (int y = 0; y < destinationHeight; y++) {
      int dif = 0, sum = weightX >> 1;
      int offsetSource = y * destinationWidth4 + alphaChannel;
      int offsetDestination = offsetSource;

      for (int x = 0 - rx2; x < destinationWidth; x++) {
        if (x >= 0) {
          destinationData[offsetDestination] = sum ~/ weightX;
          offsetDestination += 4;
          dif -= 2 * buffer[x & 1023] - buffer[(x - rx1) & 1023];
        } else if (x + rx1 >= 0) {
          dif -= 2 * buffer[x & 1023];
        }

        int tx = x + rx1;
        int alpha = (tx >= 0 && tx < sourceWidth + rx1) ? destinationData[offsetSource + (tx << 2)] : 0;
        buffer[(x + rx1) & 1023] = alpha;
        sum += dif += alpha;
      }
    }

    //--------------------------------------------------

    var destinationPixels = destinationWidth * destinationHeight;
    var rColor = (color >> 16) & 0xFF;
    var gColor = (color >>  8) & 0xFF;
    var bColor = (color >>  0) & 0xFF;
    var aColor = (256 * this.alpha).round().toInt();

    for(var i = 0, offset = 0; i < destinationPixels; i++) {
      destinationData[offset + 0] = rColor;
      destinationData[offset + 1] = gColor;
      destinationData[offset + 2] = bColor;
      destinationData[offset + 3] = (destinationData[offset + 3] * aColor) >> 8;
      offset += 4;
    }

    var sx = destinationPoint.x;
    var sy = destinationPoint.y;
    var dx = destinationPoint.x - rx1;
    var dy = destinationPoint.y - ry1;
    var sRect = new Rectangle(sx, sy, sourceWidth, sourceHeight);
    var dRect = new Rectangle(dx, dy, destinationWidth, destinationHeight);
    var uRect = sRect.union(dRect);

    destinationContext.setTransform(1, 0, 0, 1, 0, 0);
    destinationContext.clearRect(uRect.x, uRect.y, uRect.width, uRect.height);
    destinationContext.putImageData(destinationImageData, dx, dy);

    if (this.hideObject == false)
      destinationContext.drawImage(sourceContext.canvas, sx, sy);
  }
}
