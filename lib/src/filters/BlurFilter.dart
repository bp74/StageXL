class BlurFilter extends BitmapFilter
{
  int blurX;
  int blurY;
  int quality;

  //-------------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://free.pages.at/easyfilter/gauss.html
  // http://free.pages.at/easyfilter/gauss.pdf
  //-------------------------------------------------------------------------------------------------

  BlurFilter([this.blurX = 4, this.blurY = 4, this.quality = 1])
  {
    if (blurX > 128 || blurY > 128)
      throw new IllegalArgumentException("Error #9004: The maximum blur size is 128.");
  }

  BitmapFilter clone()
  {
    return new BlurFilter(blurX, blurY, quality);
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    if (quality <= 1) _applyLow(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
    if (quality == 2) _applyMedium(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
    if (quality >= 3) _applyHigh(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyLow(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var sourceData = sourceImageData.data;

    var destinationContext = destinationBitmapData._getContext();
    var destinationImageData = destinationContext.createImageData(sourceImageData.width, sourceImageData.height);
    var destinationData = destinationImageData.data;

    int width = sourceImageData.width;
    int height = sourceImageData.height;

    int radiusX = sqrt(5 * blurX * blurX + 1).toInt();
    int radiusY = sqrt(5 * blurY * blurY + 1).toInt();
    int weightX = radiusX * radiusX;
    int weightY = radiusY * radiusY;

    int width4 = width * 4;
    int rx1 = radiusX;
    int rx2 = radiusX * 2;
    int ry1 = radiusY;
    int ry2 = radiusY * 2;

    List<int> buffer = new List<int>(1024);

    for (int z = 0; z < 4; z++) {

      // blur vertical
      for (int x = 0, offsetX = z; x < width; x++) {
        int dif = 0, sum = weightY >> 1;
        int offsetY = x * 4 + z;

        for (int y = 0 - ry2; y < height; y++) {
          if (y >= 0) {
            destinationData[offsetY] = sum ~/ weightY;
            offsetY += width4;
            dif -= 2 * buffer[y & 1023] - buffer[(y - ry1) & 1023];
          } else if (y + ry1 >= 0) {
            dif -= 2 * buffer[y & 1023];
          }

          int ty = y + ry1;

          if (ty < 0) {
            ty = 0;
          } else if (ty >= height) {
            ty = height - 1;
          }

          sum += dif += (buffer[(y + ry1) & 1023] = sourceData[offsetX + ty * width4]);
        }
        offsetX += 4;
      }

      // blur horizontal
      for (int y = 0, offsetY = z; y < height; y++) {
        int dif = 0, sum = weightX >> 1;
        int offsetX = y * width4 + z;

        for (int x = 0 - rx2; x < width; x++) {
          if (x >= 0) {
            destinationData[offsetX] = sum ~/ weightX;
            offsetX += 4;
            dif -= 2 * buffer[x & 1023] - buffer[(x - rx1) & 1023];
          } else if (x + rx1 >= 0) {
            dif -= 2 * buffer[x & 1023];
          }

          int tx = x + rx1;

          if (tx < 0) {
            tx = 0;
          } else if (tx >= width) {
            tx = width - 1;
          }

          sum += dif += (buffer[(x + rx1) & 1023] = destinationData[offsetY + (tx << 2)]);
        }
        offsetY += width4;
      }
    }

    destinationContext.putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyMedium(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    // ToDo: implement second degree approximation

    _applyHigh(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyHigh(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var sourceData = sourceImageData.data;

    var destinationContext = destinationBitmapData._getContext();
    var destinationImageData = destinationContext.createImageData(sourceImageData.width, sourceImageData.height);
    var destinationData = destinationImageData.data;

    int width = sourceImageData.width;
    int height = sourceImageData.height;

    int radiusX = sqrt(3 * blurX * blurX + 1).toInt();
    int radiusY = sqrt(3 * blurY * blurY + 1).toInt();
    int weightX = radiusX * radiusX * radiusX * radiusX;
    int weightY = radiusY * radiusY * radiusY * radiusY;

    int width4 = width * 4;
    int rx1 = radiusX;
    int rx2 = radiusX * 2;
    int rx3 = radiusX * 3;
    int rx4 = radiusX * 4;
    int ry1 = radiusY;
    int ry2 = radiusY * 2;
    int ry3 = radiusY * 3;
    int ry4 = radiusY * 4;

    List<int> buffer = new List<int>(1024);

    for (int z = 0; z < 4; z++) {

      // blur vertical
      for (int x = 0, offsetX = z; x < width; x++) {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        int offsetY = x * 4 + z;

        for (int y = 0 - ry4; y < height; y++) {
          if (y >= 0) {
            destinationData[offsetY] = sum ~/ weightY;
            offsetY += width4;
            dif -= 4 * buffer[(y + ry1) & 1023] - 6 * buffer[y & 1023] + 4 * buffer[(y - ry1) & 1023] - buffer[(y - ry2) & 1023];
          } else if (y + ry1 >= 0) {
            dif -= 4 * buffer[(y + ry1) & 1023] - 6 * buffer[y & 1023] + 4 * buffer[(y - ry1) & 1023];
          } else if (y + ry2 >= 0) {
            dif -= 4 * buffer[(y + ry1) & 1023] - 6 * buffer[y & 1023];
          } else if (y + ry3 >= 0) {
            dif -= 4 * buffer[(y + ry1) & 1023];
          }

          int ty = y + ry2 - 1;

          if (ty < 0) {
            ty = 0;
          } else if (ty >= height) {
            ty = height - 1;
          }

          sum += der1 += der2 += dif += (buffer[(y + ry2) & 1023] = sourceData[offsetX + ty * width4]);
        }
        offsetX += 4;
      }

      // blur horizontal
      for (int y = 0, offsetY = z; y < height; y++) {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        int offsetX = y * width4 + z;

        for (int x = 0 - rx4; x < width; x++) {
          if (x >= 0) {
            destinationData[offsetX] = sum ~/ weightX;
            offsetX += 4;
            dif -= 4 * buffer[(x + rx1) & 1023] - 6 * buffer[x & 1023] + 4 * buffer[(x - rx1) & 1023] - buffer[(x - rx2) & 1023];
          } else if (x + rx1 >= 0) {
            dif -= 4 * buffer[(x + rx1) & 1023] - 6 * buffer[x & 1023] + 4 * buffer[(x - rx1) & 1023];
          } else if (x + rx2 >= 0) {
            dif -= 4 * buffer[(x + rx1) & 1023] - 6 * buffer[x & 1023];
          } else if (x + rx3 >= 0) {
            dif -= 4 * buffer[(x + rx1) & 1023];
          }

          int tx = x + rx2 - 1;

          if (tx < 0) {
            tx = 0;
          } else if (tx >= width) {
            tx = width - 1;
          }

          sum += der1 += der2 += dif += (buffer[(x + rx2) & 1023] = destinationData[offsetY + (tx << 2)]);
        }
        offsetY += width4;
      }
    }

    destinationContext.putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);
  }

}

