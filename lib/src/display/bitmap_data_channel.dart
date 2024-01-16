part of '../display.dart';

class BitmapDataChannel {
  static const int RED = 1;
  static const int GREEN = 2;
  static const int BLUE = 4;
  static const int ALPHA = 8;

  static int getCanvasIndex(int bitmapDataChannel) {
    final isLittleEndianSystem = env.isLittleEndianSystem;
    if (bitmapDataChannel & BitmapDataChannel.RED != 0) {
      return isLittleEndianSystem ? 0 : 3;
    }
    if (bitmapDataChannel & BitmapDataChannel.GREEN != 0) {
      return isLittleEndianSystem ? 1 : 2;
    }
    if (bitmapDataChannel & BitmapDataChannel.BLUE != 0) {
      return isLittleEndianSystem ? 2 : 1;
    }
    if (bitmapDataChannel & BitmapDataChannel.ALPHA != 0) {
      return isLittleEndianSystem ? 3 : 0;
    }
    throw ArgumentError('Invalid bitmapDataChannel');
  }

  static int getWebglIndex(int bitmapDataChannel) {
    if (bitmapDataChannel & BitmapDataChannel.RED != 0) return 0;
    if (bitmapDataChannel & BitmapDataChannel.GREEN != 0) return 1;
    if (bitmapDataChannel & BitmapDataChannel.BLUE != 0) return 2;
    if (bitmapDataChannel & BitmapDataChannel.ALPHA != 0) return 3;
    throw ArgumentError('Invalid bitmapDataChannel');
  }
}
