part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();
  Rectangle get overlap;

  void apply(BitmapData bitmapData, [Rectangle rectangle]);

  //-----------------------------------------------------------------------------------------------

  static var _buffer = new List<int>.filled(1024, 0);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(List<int> data) {

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 3];
        data[i + 0] = (data[i + 0] * alpha) ~/ 255;
        data[i + 1] = (data[i + 1] * alpha) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha) ~/ 255;
      }
    } else {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 0];
        data[i + 1] = (data[i + 1] * alpha) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha) ~/ 255;
        data[i + 3] = (data[i + 3] * alpha) ~/ 255;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _unpremultiplyAlpha(List<int> data) {

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 3];
        if (alpha > 0) {
          data[i + 0] = (data[i + 0] * 255) ~/ alpha;
          data[i + 1] = (data[i + 1] * 255) ~/ alpha;
          data[i + 2] = (data[i + 2] * 255) ~/ alpha;
        }
      }
    } else {
      for(int i = 0; i <= data.length - 4; i += 4) {
        int alpha = data[i + 0];
        if (alpha > 0) {
          data[i + 1] = (data[i + 1] * 255) ~/ alpha;
          data[i + 2] = (data[i + 2] * 255) ~/ alpha;
          data[i + 3] = (data[i + 3] * 255) ~/ alpha;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blur2(List<int> data, int offset, int length, int stride, int radius) {

    int weight = radius * radius;
    int weightInv = (1 << 22) ~/ weight;
    int sum = weight ~/ 2;
    int dif = 0;
    int offsetSource = offset;
    int offsetDestination = offset;
    int radius1 = radius * 1;
    int radius2 = radius * 2;

    List<int> buffer = _buffer;

    for (int i = 0; i < length + radius1; i++) {

      if (i >= radius1) {
        data[offsetDestination] = ((sum * weightInv) | 0) >> 22;
        offsetDestination += stride;
        if (i >= radius2) {
          dif -= 2 * buffer[i & 1023] - buffer[(i - radius1) & 1023];
        } else {
          dif -= 2 * buffer[i & 1023];
        }
      }

      if (i < length) {
        int value = data[offsetSource];
        offsetSource += stride;
        buffer[(i + radius1) & 1023] = value;
        sum += dif += value;
      } else {
        buffer[(i + radius1) & 1023] = 0;
        sum += dif;
      }
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

  _blend(List<int> dstData, List<int> srcData) {

    if (dstData.length != srcData.length) return;

    if (_isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 3];
        int dstA = dstData[i + 3];
        int srcAX = srcA * 255;
        int dstAX = dstA * (255 - srcA);
        int outAX = srcAX + dstAX;
        if (outAX > 0) {
          dstData[i + 0] = (srcData[i + 0] * srcAX + dstData[i + 0] * dstAX) ~/ outAX;
          dstData[i + 1] = (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
          dstData[i + 3] = outAX ~/ 255;
        }
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 0];
        int dstA = dstData[i + 0];
        int srcAX = srcA * 255;
        int dstAX = dstA * (255 - srcA);
        int outAX = srcAX + dstAX;
        if (outAX > 0) {
          dstData[i + 0] = outAX ~/ 255;
          dstData[i + 1] = (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
          dstData[i + 3] = (srcData[i + 3] * srcAX + dstData[i + 3] * dstAX) ~/ outAX;
        }
      }
    }
  }

}
