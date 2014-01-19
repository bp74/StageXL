part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();

  void apply(BitmapData bitmapData, [Rectangle rectangle]);

  //-----------------------------------------------------------------------------------------------

  static var _buffer = new List<int>.filled(1024, 0);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(ImageData imageData) {

    var data = imageData.data;
    var isLittleEndianSystem = _isLittleEndianSystem;

    for(var i = 0; i <= data.length - 4; i += 4) {
      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];

      if (isLittleEndianSystem) {
        data[i + 0] = (c0 * c3) ~/ 255;
        data[i + 1] = (c1 * c3) ~/ 255;
        data[i + 2] = (c2 * c3) ~/ 255;
      } else {
        data[i + 1] = (c1 * c0) ~/ 255;
        data[i + 2] = (c2 * c0) ~/ 255;
        data[i + 3] = (c3 * c0) ~/ 255;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _unpremultiplyAlpha(ImageData imageData) {

    var data = imageData.data;
    var isLittleEndianSystem = _isLittleEndianSystem;

    for(var i = 0; i <= data.length - 4; i += 4) {
      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];

      if (isLittleEndianSystem) {
        if (c3 == 0) continue;
        data[i + 0] = (c0 * 255) ~/ c3;
        data[i + 1] = (c1 * 255) ~/ c3;
        data[i + 2] = (c2 * 255) ~/ c3;
      } else {
        if (c0 == 0) continue;
        data[i + 1] = (c1 * 255) ~/ c0;
        data[i + 2] = (c2 * 255) ~/ c0;
        data[i + 3] = (c3 * 255) ~/ c0;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blur2(List<int> data, int offset, int length, int stride, int radius) {

    int dif = 0;
    int weight = radius * radius;
    int weightInv = (1 << 22) ~/ weight;
    int sum = weight ~/ 2;
    int offsetSource = offset;
    int offsetDestination = offset;
    int radius1 = radius * 1;
    int radius2 = radius * 2;

    List<int> buffer = _buffer;

    for (int i = 0; i < length + radius1; i++) {

      if (i >= radius1) {
        data[offsetDestination] = ((sum * weightInv) | 0) >> 22;
        offsetDestination += stride;
        dif -= 2 * buffer[i & 1023];
        if (i >= radius2) {
          dif += buffer[(i - radius1) & 1023];
        }
      }

      int value = (i < length) ? data[offsetSource] : 0;
      buffer[(i + radius1) & 1023] = value;
      sum += dif += value;
      offsetSource += stride;
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColor(List<int> data, int color, num alpha) {

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int alpha256 = (alpha * 256).toInt();

    if (_isLittleEndianSystem) {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = rColor;
        data[i + 1] = gColor;
        data[i + 2] = bColor;
        data[i + 3] = (data[i + 3] * alpha256 | 0) >> 8;
      }
    } else {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = (data[i + 0] * alpha256 | 0) >> 8;
        data[i + 1] = bColor;
        data[i + 2] = gColor;
        data[i + 3] = rColor;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _composite(List<int> destinationData, List<int> sourceData) {

    if (destinationData.length != sourceData.length) return;

    // TODO: This needs optimization!

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= destinationData.length - 4; i += 4) {
        int srcA = sourceData[i + 3];
        int dstA = destinationData[i + 3];
        int srcAX = srcA * 255;
        int dstAX = dstA * (255 - srcA);
        int outA = srcAX + dstAX;
        if (outA > 0) {
          int srcR = sourceData[i + 0];
          int srcG = sourceData[i + 1];
          int srcB = sourceData[i + 2];
          int dstR = destinationData[i + 0];
          int dstG = destinationData[i + 1];
          int dstB = destinationData[i + 2];
          destinationData[i + 0] = (srcR * srcAX + dstR * dstAX) ~/ outA;
          destinationData[i + 1] = (srcG * srcAX + dstG * dstAX) ~/ outA;
          destinationData[i + 2] = (srcB * srcAX + dstB * dstAX) ~/ outA;
          destinationData[i + 3] = outA ~/ 255;
        }
      }
    } else {

      // TODO: composite for big endian systems

    }
  }

}
