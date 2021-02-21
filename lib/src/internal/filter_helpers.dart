library stagexl.internal.filter_helpers;

import 'dart:typed_data';
import 'environment.dart' as env;
import 'tools.dart';

Int32List _buffer = Int32List(1024);

//-----------------------------------------------------------------------------------------------

void premultiplyAlpha(List<int> data) {
  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= data.length - 4; i += 4) {
      final alpha = data[i + 3];
      if (alpha > 0 && alpha < 255) {
        data[i + 0] = (data[i + 0] * alpha & 65535) ~/ 255;
        data[i + 1] = (data[i + 1] * alpha & 65535) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha & 65535) ~/ 255;
      }
    }
  } else {
    for (var i = 0; i <= data.length - 4; i += 4) {
      final alpha = data[i + 0];
      if (alpha > 0 && alpha < 255) {
        data[i + 1] = (data[i + 1] * alpha & 65535) ~/ 255;
        data[i + 2] = (data[i + 2] * alpha & 65535) ~/ 255;
        data[i + 3] = (data[i + 3] * alpha & 65535) ~/ 255;
      }
    }
  }
}

//-----------------------------------------------------------------------------------------------

void unpremultiplyAlpha(List<int> data) {
  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= data.length - 4; i += 4) {
      final alpha = data[i + 3];
      if (alpha > 0 && alpha < 255) {
        data[i + 0] = (data[i + 0] * 255 & 65535) ~/ alpha;
        data[i + 1] = (data[i + 1] * 255 & 65535) ~/ alpha;
        data[i + 2] = (data[i + 2] * 255 & 65535) ~/ alpha;
      }
    }
  } else {
    for (var i = 0; i <= data.length - 4; i += 4) {
      final alpha = data[i + 0];
      if (alpha > 0 && alpha < 255) {
        data[i + 1] = (data[i + 1] * 255 & 65535) ~/ alpha;
        data[i + 2] = (data[i + 2] * 255 & 65535) ~/ alpha;
        data[i + 3] = (data[i + 3] * 255 & 65535) ~/ alpha;
      }
    }
  }
}

//-----------------------------------------------------------------------------------------------

void clearChannel(List<int> data, int offset, int length) {
  final offsetStart = offset;
  final offsetEnd = offset + length * 4 - 4;
  if (offsetStart < 0) throw RangeError(offsetStart);
  if (offsetEnd >= data.length) throw RangeError(offsetEnd);
  for (var i = offsetStart; i <= offsetEnd; i += 4) {
    data[i] = 0;
  }
}

//-----------------------------------------------------------------------------------------------

void shiftChannel(List<int> data, int channel, int width, int height,
    int shiftX, int shiftY) {
  if (channel < 0) throw ArgumentError();
  if (channel > 3) throw ArgumentError();
  if (shiftX == 0 && shiftY == 0) return;

  if (shiftX.abs() >= width || shiftY.abs() >= height) {
    clearChannel(data, channel, width * height);
    return;
  }

  if (shiftX + width * shiftY < 0) {
    var dst = channel;
    var src = channel - 4 * (shiftX + width * shiftY);
    for (; src < data.length; src += 4, dst += 4) {
      data[dst] = data[src];
    }
  } else {
    var dst = data.length + channel - 4;
    var src = data.length + channel - 4 * (shiftX + width * shiftY);
    for (; src >= 0; src -= 4, dst -= 4) {
      data[dst] = data[src];
    }
  }

  for (var y = 0; y < height; y++) {
    if (y < shiftY || y >= height + shiftY) {
      clearChannel(data, (y * width) * 4 + channel, width);
    } else if (shiftX > 0) {
      clearChannel(data, (y * width) * 4 + channel, shiftX);
    } else if (shiftX < 0) {
      clearChannel(
          data, (y * width + width + shiftX) * 4 + channel, 0 - shiftX);
    }
  }
}

//-----------------------------------------------------------------------------------------------

void blur(List<int> data, int offset, int length, int stride, int radius) {
  radius += 1;
  final weight = radius * radius;
  final weightInv = (1 << 22) ~/ weight;
  var sum = weight ~/ 2;
  var dif = 0;
  var offsetSource = offset;
  var offsetDestination = offset;
  final radius1 = radius * 1;
  final radius2 = radius * 2;

  final buffer = _buffer;

  for (var i = 0; i < length + radius1; i++) {
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
      final value = data[offsetSource];
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

void setColor(List<int> data, int color) {
  final rColor = colorGetR(color);
  final gColor = colorGetG(color);
  final bColor = colorGetB(color);
  final aColor = colorGetA(color);

  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= data.length - 4; i += 4) {
      data[i + 0] = rColor;
      data[i + 1] = gColor;
      data[i + 2] = bColor;
      data[i + 3] = (aColor * data[i + 3] | 0) >> 8;
    }
  } else {
    for (var i = 0; i <= data.length - 4; i += 4) {
      data[i + 0] = (aColor * data[i + 0] | 0) >> 8;
      data[i + 1] = bColor;
      data[i + 2] = gColor;
      data[i + 3] = rColor;
    }
  }
}

//-----------------------------------------------------------------------------------------------

void blend(List<int> dstData, List<int> srcData) {
  if (dstData.length != srcData.length) return;

  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      final srcA = srcData[i + 3];
      final dstA = dstData[i + 3];
      final srcAX = srcA * 255;
      final dstAX = dstA * (255 - srcA);
      final outAX = srcAX + dstAX;
      if (outAX > 0) {
        dstData[i + 0] =
            (srcData[i + 0] * srcAX + dstData[i + 0] * dstAX) ~/ outAX;
        dstData[i + 1] =
            (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
        dstData[i + 2] =
            (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
        dstData[i + 3] = outAX ~/ 255;
      }
    }
  } else {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      final srcA = srcData[i + 0];
      final dstA = dstData[i + 0];
      final srcAX = srcA * 255;
      final dstAX = dstA * (255 - srcA);
      final outAX = srcAX + dstAX;
      if (outAX > 0) {
        dstData[i + 0] = outAX ~/ 255;
        dstData[i + 1] =
            (srcData[i + 1] * srcAX + dstData[i + 1] * dstAX) ~/ outAX;
        dstData[i + 2] =
            (srcData[i + 2] * srcAX + dstData[i + 2] * dstAX) ~/ outAX;
        dstData[i + 3] =
            (srcData[i + 3] * srcAX + dstData[i + 3] * dstAX) ~/ outAX;
      }
    }
  }
}

//-----------------------------------------------------------------------------------------------

void knockout(List<int> dstData, List<int> srcData) {
  if (dstData.length != srcData.length) return;

  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      dstData[i + 3] = dstData[i + 3] * (255 - srcData[i + 3]) ~/ 255;
    }
  } else {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      dstData[i + 0] = dstData[i + 0] * (255 - srcData[i + 0]) ~/ 255;
    }
  }
}

//-----------------------------------------------------------------------------------------------

void setColorBlend(List<int> dstData, int color, List<int> srcData) {
  // optimized version for:
  //   _setColor(data, this.color, this.alpha);
  //   _blend(data, sourceImageData.data);

  if (dstData.length != srcData.length) return;

  final rColor = colorGetR(color);
  final gColor = colorGetG(color);
  final bColor = colorGetB(color);
  final aColor = colorGetA(color);

  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      final srcA = srcData[i + 3];
      final dstA = dstData[i + 3];
      final srcAX = srcA * 255;
      final dstAX = (dstA * (255 - srcA) * aColor | 0) >> 8;
      final outAX = srcAX + dstAX;
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
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      final srcA = srcData[i + 0];
      final dstA = dstData[i + 0];
      final srcAX = srcA * 255;
      final dstAX = (dstA * (255 - srcA) * aColor | 0) >> 8;
      final outAX = srcAX + dstAX;
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

void setColorKnockout(List<int> dstData, int color, List<int> srcData) {
  // optimized version for:
  //   _setColor(data, this.color, this.alpha);
  //   _knockout(data, sourceImageData.data);

  if (dstData.length != srcData.length) return;

  final rColor = colorGetR(color);
  final gColor = colorGetG(color);
  final bColor = colorGetB(color);
  final aColor = colorGetA(color);

  if (env.isLittleEndianSystem) {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      dstData[i + 0] = rColor;
      dstData[i + 1] = gColor;
      dstData[i + 2] = bColor;
      dstData[i + 3] =
          (aColor * dstData[i + 3] * (255 - srcData[i + 3]) | 0) ~/ (255 * 256);
    }
  } else {
    for (var i = 0; i <= dstData.length - 4; i += 4) {
      dstData[i + 0] =
          (aColor * dstData[i + 0] * (255 - srcData[i + 0]) | 0) ~/ (255 * 256);
      dstData[i + 1] = bColor;
      dstData[i + 2] = gColor;
      dstData[i + 3] = rColor;
    }
  }
}
