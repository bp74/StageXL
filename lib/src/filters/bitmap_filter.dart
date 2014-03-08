part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();

  Rectangle<int> get overlap => new Rectangle<int>(0, 0, 0, 0);
  List<int> get renderPassSources => [0];
  List<int> get renderPassTargets => [1];

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

  }

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    renderState.renderQuad(renderTextureQuad);
  }

  //-----------------------------------------------------------------------------------------------

  static var _buffer = new List<int>.filled(1024, 0);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(List<int> data) {

    if (BitmapDataChannel.isLittleEndianSystem) {
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

    if (BitmapDataChannel.isLittleEndianSystem) {
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

  _clearChannel(List<int> data, int offset, int length) {
    int offsetStart = offset;
    int offsetEnd = offset + length * 4 - 4;
    if (offsetStart < 0) throw new RangeError(offsetStart);
    if (offsetEnd >= data.length) throw new RangeError(offsetEnd);
    for(int i = offsetStart; i <= offsetEnd; i += 4) {
      data[i] = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  _shiftChannel(List<int> data, int channel, int width, int height, int shiftX, int shiftY) {

    if (channel < 0) throw new ArgumentError();
    if (channel > 3) throw new ArgumentError();
    if (shiftX == 0 && shiftY == 0) return;

    if (shiftX.abs() >= width || shiftY.abs() >= height) {
      _clearChannel(data, channel, width * height);
      return;
    }

    if (shiftX + width * shiftY < 0) {
      int dst = channel;
      int src = channel - 4 * (shiftX + width * shiftY);
      for(; src < data.length; src += 4, dst += 4) data[dst] = data[src];
    } else {
      int dst = data.length + channel - 4;
      int src = data.length + channel - 4 * (shiftX + width * shiftY);
      for(; src >= 0; src -= 4, dst -= 4) data[dst] = data[src];
    }

    for(int y = 0; y < height; y++) {
      if (y < shiftY || y >= height + shiftY) {
        _clearChannel(data, (y * width) * 4 + channel, width);
      } else if (shiftX > 0) {
        _clearChannel(data, (y * width) * 4 + channel, shiftX);
      } else if (shiftX < 0) {
        _clearChannel(data, (y * width + width + shiftX) * 4 + channel, 0 - shiftX);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blur2(List<int> data, int offset, int length, int stride, int radius) {

    radius += 1;
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

  _setColor(List<int> data, int color) {

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int aColor = _colorGetA(color);

    if (BitmapDataChannel.isLittleEndianSystem) {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = rColor;
        data[i + 1] = gColor;
        data[i + 2] = bColor;
        data[i + 3] = (aColor * data[i + 3] | 0) >> 8;
      }
    } else {
      for(var i = 0; i <= data.length - 4; i += 4) {
        data[i + 0] = (aColor * data[i + 0] | 0) >> 8;
        data[i + 1] = bColor;
        data[i + 2] = gColor;
        data[i + 3] = rColor;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _blend(List<int> dstData, List<int> srcData) {

    if (dstData.length != srcData.length) return;

    if (BitmapDataChannel.isLittleEndianSystem) {
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

  //-----------------------------------------------------------------------------------------------

  _knockout(List<int> dstData, List<int> srcData) {

    if (dstData.length != srcData.length) return;

    if (BitmapDataChannel.isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 3] = dstData[i + 3] * (255 - srcData[i + 3]) ~/ 255;
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = dstData[i + 0] * (255 - srcData[i + 0]) ~/ 255;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColorBlend(List<int> dstData, int color, List<int> srcData) {

    // optimized version for:
    //   _setColor(data, this.color, this.alpha);
    //   _blend(data, sourceImageData.data);

    if (dstData.length != srcData.length) return;

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int aColor = _colorGetA(color);

    if (BitmapDataChannel.isLittleEndianSystem) {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 3];
        int dstA = dstData[i + 3];
        int srcAX = (srcA * 255);
        int dstAX = (dstA * (255 - srcA) * aColor | 0) >> 8;
        int outAX = (srcAX + dstAX);
        if (outAX > 0) {
          dstData[i + 0] = (srcData[i + 0] * srcAX + rColor * dstAX) ~/ outAX;
          dstData[i + 1] = (srcData[i + 1] * srcAX + gColor * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + bColor * dstAX) ~/ outAX;
          dstData[i + 3] = outAX ~/ 255;
        } else {
          dstData[i + 3] = 0;
        }
      }
    } else {
      for(int i = 0; i <= dstData.length - 4; i += 4) {
        int srcA = srcData[i + 0];
        int dstA = dstData[i + 0];
        int srcAX = (srcA * 255);
        int dstAX = (dstA * (255 - srcA) * aColor | 0) >> 8;
        int outAX = (srcAX + dstAX);
        if (outAX > 0) {
          dstData[i + 0] = outAX ~/ 255;
          dstData[i + 1] = (srcData[i + 1] * srcAX + bColor * dstAX) ~/ outAX;
          dstData[i + 2] = (srcData[i + 2] * srcAX + gColor * dstAX) ~/ outAX;
          dstData[i + 3] = (srcData[i + 3] * srcAX + rColor * dstAX) ~/ outAX;
        } else {
          dstData[i + 0] = 0;
        }
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  _setColorKnockout(List<int> dstData, int color, List<int> srcData) {

    // optimized version for:
    //   _setColor(data, this.color, this.alpha);
    //   _knockout(data, sourceImageData.data);

    if (dstData.length != srcData.length) return;

    int rColor = _colorGetR(color);
    int gColor = _colorGetG(color);
    int bColor = _colorGetB(color);
    int aColor = _colorGetA(color);

    if (BitmapDataChannel.isLittleEndianSystem) {
      for(var i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = rColor;
        dstData[i + 1] = gColor;
        dstData[i + 2] = bColor;
        dstData[i + 3] = (aColor * dstData[i + 3] * (255 - srcData[i + 3]) | 0) ~/ (255 * 256);
      }
    } else {
      for(var i = 0; i <= dstData.length - 4; i += 4) {
        dstData[i + 0] = (aColor * dstData[i + 0] * (255 - srcData[i + 0]) | 0) ~/ (255 * 256);
        dstData[i + 1] = bColor;
        dstData[i + 2] = gColor;
        dstData[i + 3] = rColor;
      }
    }
  }

}
