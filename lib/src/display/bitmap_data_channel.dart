part of stagexl;

class BitmapDataChannel {

  static const int RED = 1;
  static const int GREEN = 2;
  static const int BLUE = 4;
  static const int ALPHA = 8;

  static final bool isLittleEndianSystem = _checkLittleEndianSystem();

  static int getCanvasIndex(int bitmapDataChannel) {
    if (bitmapDataChannel & BitmapDataChannel.RED != 0) return isLittleEndianSystem ? 0 : 3;
    if (bitmapDataChannel & BitmapDataChannel.GREEN != 0) return isLittleEndianSystem ? 1 : 2;
    if (bitmapDataChannel & BitmapDataChannel.BLUE != 0) return isLittleEndianSystem ? 2 : 1;
    if (bitmapDataChannel & BitmapDataChannel.ALPHA != 0) return isLittleEndianSystem ? 3 : 0;
    throw new ArgumentError("Invalid bitmapDataChannel");
  }

  static int getWebglIndex(int bitmapDataChannel) {
    if (bitmapDataChannel & BitmapDataChannel.RED != 0) return 0;
    if (bitmapDataChannel & BitmapDataChannel.GREEN != 0) return 1;
    if (bitmapDataChannel & BitmapDataChannel.BLUE != 0) return 2;
    if (bitmapDataChannel & BitmapDataChannel.ALPHA != 0) return 3;
    throw new ArgumentError("Invalid bitmapDataChannel");
  }

  static bool _checkLittleEndianSystem() {
    var canvas = new CanvasElement(width: 1, height: 1);
    canvas.context2D.fillStyle = "#000000";
    canvas.context2D.fillRect(0, 0, 1, 1);
    var data = canvas.context2D.getImageData(0, 0, 1, 1).data;
    var littleEndian = (data[0] == 0);
    return littleEndian;
  }
}