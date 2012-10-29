part of dartflash;

class BlurFilter extends BitmapFilter
{
  int blurX;
  int blurY;

  //-------------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://free.pages.at/easyfilter/gauss.html
  // http://free.pages.at/easyfilter/gauss.pdf
  //-------------------------------------------------------------------------------------------------

  BlurFilter([this.blurX = 4, this.blurY = 4])
  {
    if (blurX < 1 || blurY < 1)
      throw new ArgumentError("Error #9004: The minimum blur size is 1.");

    if (blurX > 128 || blurY > 128)
      throw new ArgumentError("Error #9004: The maximum blur size is 128.");
  }

  BitmapFilter clone()
  {
    return new BlurFilter(blurX, blurY);
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var sourceData = sourceImageData.data;

    int sourceWidth = sourceImageData.width;
    int sourceHeight = sourceImageData.height;
    int weightX = blurX * blurX;
    int weightY = blurY * blurY;
    int rx1 = blurX;
    int rx2 = blurX * 2;
    int ry1 = blurY;
    int ry2 = blurY * 2;
    int destinationWidth = sourceWidth + rx2;
    int destinationHeight = sourceHeight + ry2;
    int sourceWidth4 = sourceWidth * 4;
    int destinationWidth4 = destinationWidth * 4;

    var destinationContext = destinationBitmapData._getContext();
    var destinationImageData = destinationContext.createImageData(destinationWidth, destinationHeight);
    var destinationData = destinationImageData.data;

    List<int> buffer = new List<int>(1024);

    //--------------------------------------------------
    // premultiply alpha

    for(var i = 0; i <= sourceData.length - 4; i += 4) {
      var alpha = sourceData[i + 3];
      sourceData[i + 0] = (sourceData[i + 0] * alpha) ~/ 255;
      sourceData[i + 1] = (sourceData[i + 1] * alpha) ~/ 255;
      sourceData[i + 2] = (sourceData[i + 2] * alpha) ~/ 255;
    }

    //--------------------------------------------------
    // blur vertical

    for (int z = 0; z < 4; z++) {
      for (int x = 0; x < sourceWidth; x++) {
        int dif = 0, sum = weightY >> 1;
        int offsetSource = x * 4 + z;
        int offsetDestination = (x + rx1) * 4 + z;

        for (int y = 0; y < destinationHeight; y++) {
          destinationData[offsetDestination] = sum ~/ weightY;
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
    }

    //--------------------------------------------------
    // blur horizontal

    for (int z = 0; z < 4; z++) {
      for (int y = 0; y < destinationHeight; y++) {
        int dif = 0, sum = weightX >> 1;
        int offsetSource = y * destinationWidth4 + rx1 * 4 + z;
        int offsetDestination = y * destinationWidth4 + z;

        for (int x = 0; x < destinationWidth; x++) {
          destinationData[offsetDestination] = sum ~/ weightX;
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
    }

    //--------------------------------------------------
    // unpremultiply alpha

    for(var i = 0; i <= destinationData.length - 4; i += 4) {
      var alpha = destinationData[i + 3];
      if (alpha > 0) {
        destinationData[i + 0] = (destinationData[i + 0] * 255) ~/ alpha;
        destinationData[i + 1] = (destinationData[i + 1] * 255) ~/ alpha;
        destinationData[i + 2] = (destinationData[i + 2] * 255) ~/ alpha;
      }
    }

    //--------------------------------------------------

    destinationContext.putImageData(destinationImageData, destinationPoint.x - rx1, destinationPoint.y - ry1);
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBounds()
  {
    return new Rectangle(-blurX, -blurY, 2 * blurX, 2 * blurY);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  /*
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
      for (int x = 0; x < width; x++) {
        int dif = 0, sum = weightY >> 1;
        int offsetBase = x * 4 + z;
        int offsetLoop = offsetBase;

        for (int y = 0 - ry2; y < height; y++) {
          if (y >= 0) {
            destinationData[offsetLoop] = sum ~/ weightY;
            offsetLoop += width4;
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

          sum += dif += (buffer[(y + ry1) & 1023] = sourceData[offsetBase + ty * width4]);
        }
      }

      // blur horizontal
      for (int y = 0; y < height; y++) {
        int dif = 0, sum = weightX >> 1;
        int offsetBase = y * width4 + z;
        int offsetLoop = offsetBase;

        for (int x = 0 - rx2; x < width; x++) {
          if (x >= 0) {
            destinationData[offsetLoop] = sum ~/ weightX;
            offsetLoop += 4;
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

          sum += dif += (buffer[(x + rx1) & 1023] = destinationData[offsetBase + (tx << 2)]);
        }
      }
    }

    destinationContext.putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyMedium(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var sourceData = sourceImageData.data;

    var destinationContext = destinationBitmapData._getContext();
    var destinationImageData = destinationContext.createImageData(sourceImageData.width, sourceImageData.height);
    var destinationData = destinationImageData.data;

    int width = sourceImageData.width;
    int height = sourceImageData.height;

    int radiusX = sqrt(4 * blurX * blurX + 1).toInt();
    int radiusY = sqrt(4 * blurY * blurY + 1).toInt();
    int weightX = radiusX * radiusX * radiusX;
    int weightY = radiusY * radiusY * radiusY;

    int width4 = width * 4;
    int rx1 = radiusX;
    int rx2 = radiusX * 2;
    int rx3 = radiusX * 3;
    int ry1 = radiusY;
    int ry2 = radiusY * 2;
    int ry3 = radiusY * 3;
    int rx3h = (rx3 / 2).round().toInt();
    int ry3h = (ry3 / 2).round().toInt();

    List<int> buffer = new List<int>(1024);

    for (int z = 0; z < 4; z++) {

      // blur vertical
      for (int x = 0; x < width; x++) {
        int dif = 0, der = 0, sum = 0;
        int offsetBase = x * 4 + z;
        int offsetLoop = offsetBase;

        for (int y = 0 - ry3; y < height; y++) {
          if (y >= 0) {
            destinationData[offsetLoop] = sum ~/ weightY;
            offsetLoop += width4;
            dif -= 3 * buffer[(y + ry1) & 1023] - 3 * buffer[y & 1023] + buffer[(y - ry1) & 1023];
          } else if (y + ry1 >= 0) {
            dif -= 3 * buffer[(y + ry1) & 1023] - 3 * buffer[y & 1023];
          } else if (y + ry2 >= 0) {
            dif -= 3 * buffer[(y + ry1) & 1023];
          }

          int ty = y + ry3h;

          if (ty < 0) {
            ty = 0;
          } else if (ty >= height) {
            ty = height - 1;
          }

          sum += der += dif += (buffer[(y + ry2) & 1023] = sourceData[offsetBase + ty * width4]);
        }
      }

      // blur horizontal
      for (int y = 0; y < height; y++) {
        int dif = 0, der = 0, sum = 0;
        int offsetBase = y * width4 + z;
        int offsetLoop = offsetBase;

        for (int x = 0 - rx3; x < width; x++) {
          if (x >= 0) {
            destinationData[offsetLoop] = sum ~/ weightX;
            offsetLoop += 4;
            dif -= 3 * buffer[(x + rx1) & 1023] - 3 * buffer[x & 1023] + buffer[(x - rx1) & 1023];
          } else if (x + rx1 >= 0) {
            dif -= 3 * buffer[(x + rx1) & 1023] - 3 * buffer[x & 1023];
          } else if (x + rx2 >= 0) {
            dif -= 3 * buffer[(x + rx1) & 1023];
          }

          int tx = x + rx3h;

          if (tx < 0) {
            tx = 0;
          } else if (tx >= width) {
            tx = width - 1;
          }

          sum += der += dif += (buffer[(x + rx2) & 1023] = destinationData[offsetBase + (tx << 2)]);
        }
      }
    }

    destinationContext.putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);
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
      for (int x = 0; x < width; x++) {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        int offsetBase = x * 4 + z;
        int offsetLoop = offsetBase;

        for (int y = 0 - ry4; y < height; y++) {
          if (y >= 0) {
            destinationData[offsetLoop] = sum ~/ weightY;
            offsetLoop += width4;
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

          sum += der1 += der2 += dif += (buffer[(y + ry2) & 1023] = sourceData[offsetBase + ty * width4]);
        }
      }

      // blur horizontal
      for (int y = 0; y < height; y++) {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        int offsetBase = y * width4 + z;
        int offsetLoop = offsetBase;

        for (int x = 0 - rx4; x < width; x++) {
          if (x >= 0) {
            destinationData[offsetLoop] = sum ~/ weightX;
            offsetLoop += 4;
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

          sum += der1 += der2 += dif += (buffer[(x + rx2) & 1023] = destinationData[offsetBase + (tx << 2)]);
        }
      }
    }

    destinationContext.putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);
  }
  */
}

