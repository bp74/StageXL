part of stagexl;

class DropShadowFilter extends BitmapFilter {

  num distance;
  num angle;
  int color;
  num alpha;
  int blurX;
  int blurY;
  num strength;
  bool inner;
  bool knockout;
  bool hideObject;

  DropShadowFilter([this.distance = 4.0, this.angle = PI / 4, this.color = 0, this.alpha = 1.0,
      this.blurX = 4, this.blurY = 4, this.strength = 1.0, this.inner = false,
      this.knockout = false, this.hideObject = false]) {

    if (blurX < 1 || blurY < 1)
      throw new ArgumentError("Error #9004: The minimum blur size is 1.");

    if (blurX > 64 || blurY > 64)
      throw new ArgumentError("Error #9004: The maximum blur size is 64.");
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone() {

    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, inner, knockout, hideObject);
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint) {

    var originalBitmapData = sourceBitmapData;

    if (sourceBitmapData == destinationBitmapData && !hideObject) {
      originalBitmapData = sourceBitmapData.clone(destinationBitmapData.pixelRatio);
    }

    var sourceImageData = sourceBitmapData.getImageData(
        sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destinationBitmapData.pixelRatio);
    var sourceData = sourceImageData.data;

    num pixelRatio = destinationBitmapData.pixelRatio;
    int sourceWidth = _ensureInt(sourceRect.width);
    int sourceHeight = _ensureInt(sourceRect.height);
    int weightX = (blurX * blurX * pixelRatio * pixelRatio).floor();
    int weightY = (blurY * blurY * pixelRatio * pixelRatio).floor();
    int weightXinv = (1 << 22) ~/ weightX;
    int weightYinv = (1 << 22) ~/ weightY;
    int rx1 = (blurX * pixelRatio).floor();
    int rx2 = (blurX * pixelRatio * 2).floor();
    int ry1 = (blurY * pixelRatio).floor();
    int ry2 = (blurY * pixelRatio * 2).floor();
    int destinationWidth = sourceWidth + rx2;
    int destinationHeight = sourceHeight + ry2;
    int sourceWidth4 = sourceWidth * 4;
    int destinationWidth4 = destinationWidth * 4;
    int alphaChannel = _isLittleEndianSystem ? 3 : 0;

    var destinationImageData = destinationBitmapData.createImageData(destinationWidth, destinationHeight);
    var destinationData = destinationImageData.data;
    var buffer = new List<int>.filled(1024, 0);

    //--------------------------------------------------
    // blur vertical

    for (int x = 0; x < sourceWidth; x++) {
      int dif = 0, sum = weightY >> 1;
      int offsetSource = x * 4 + alphaChannel;
      int offsetDestination = (x + rx1) * 4 + alphaChannel;

      for (int y = 0; y < destinationHeight; y++) {
        destinationData[offsetDestination] = (sum *weightYinv) >> 22;
        offsetDestination += destinationWidth4;

        if (y >= ry2) {
          dif -= 2 * buffer[y & 1023] - buffer[(y - ry1) & 1023];
        } else if (y >= ry1) {
          dif -= 2 * buffer[y & 1023];
        }

        int alpha = (y < sourceHeight) ? sourceData[offsetSource] : 0;
        buffer[(y + ry1) & 1023] = alpha;
        sum += dif += alpha;
        offsetSource += sourceWidth4;
      }
    }

    //--------------------------------------------------
    // blur horizontal

    for (int y = 0; y < destinationHeight; y++) {
      int dif = 0, sum = weightX >> 1;
      int offsetSource = y * destinationWidth4 + rx1 * 4 + alphaChannel;
      int offsetDestination = y * destinationWidth4 + alphaChannel;

      for (int x = 0; x < destinationWidth; x++) {
        destinationData[offsetDestination] = (sum * weightXinv) >> 22;
        offsetDestination += 4;

        if (x >= rx2) {
          dif -= 2 * buffer[x & 1023] - buffer[(x - rx1) & 1023];
        } else if (x >= rx1) {
          dif -= 2 * buffer[x & 1023];
        }

        int alpha = (x < sourceWidth) ? destinationData[offsetSource] : 0;
        buffer[(x + rx1) & 1023] = alpha;
        sum += dif += alpha;
        offsetSource += 4;
      }
    }

    //--------------------------------------------------
    // set color

    int aColor = (alpha * 256).toInt();
    int rColor = (color >> 16) & 0xFF;
    int gColor = (color >>  8) & 0xFF;
    int bColor = (color >>  0) & 0xFF;

    if (_isLittleEndianSystem) {
      for(var i = 0; i <= destinationData.length - 4; i += 4) {
        destinationData[i + 0] = rColor;
        destinationData[i + 1] = gColor;
        destinationData[i + 2] = bColor;
        destinationData[i + 3] = (destinationData[i + 3] * aColor) >> 8;
      }
    } else {
      for(var i = 0; i <= destinationData.length - 4; i += 4) {
        destinationData[i + 0] = (destinationData[i + 0] * aColor) >> 8;
        destinationData[i + 1] = bColor;
        destinationData[i + 2] = gColor;
        destinationData[i + 3] = rColor;
      }
    }

    //--------------------------------------------------

    var sx = destinationPoint.x;
    var sy = destinationPoint.y;
    var dx = destinationPoint.x - rx1 + (this.distance * cos(this.angle)).round();
    var dy = destinationPoint.y - ry1 + (this.distance * sin(this.angle)).round();
    var sRect = new Rectangle(sx, sy, sourceWidth, sourceHeight);
    var dRect = new Rectangle(dx, dy, destinationWidth, destinationHeight);
    var uRect = sRect.union(dRect);

    destinationBitmapData.fillRect(uRect, Color.Transparent);
    destinationBitmapData.putImageData(destinationImageData, dx, dy);

    if (this.hideObject == false) {
      destinationBitmapData.draw(originalBitmapData, new Matrix(1.0, 0.0, 0.0, 1.0, sx, sy));
    }
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBounds() {

    var dx = (this.distance * cos(this.angle)).round();
    var dy = (this.distance * sin(this.angle)).round();
    var sRect = new Rectangle(0, 0, 0, 0);
    var dRect = new Rectangle(dx - blurX, dy - blurY, 2 * blurX, 2 * blurY);
    return sRect.union(dRect);
  }
}
