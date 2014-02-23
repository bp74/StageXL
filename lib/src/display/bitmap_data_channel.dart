part of stagexl;

class BitmapDataChannel {

  static const int RED = 1;
  static const int GREEN = 2;
  static const int BLUE = 4;
  static const int ALPHA = 8;

  static final bool isLittleEndianSystem = _checkLittleEndianSystem();

  static final int indexRed   = isLittleEndianSystem ? 0 : 3;
  static final int indexGreen = isLittleEndianSystem ? 1 : 2;
  static final int indexBlue  = isLittleEndianSystem ? 2 : 1;
  static final int indexAlpha = isLittleEndianSystem ? 3 : 0;

  static bool _checkLittleEndianSystem() {
    var canvas = new CanvasElement(width: 1, height: 1);
    canvas.context2D.fillStyle = "#000000";
    canvas.context2D.fillRect(0, 0, 1, 1);
    var data = canvas.context2D.getImageData(0, 0, 1, 1).data;
    var littleEndian = (data[0] == 0);
    return littleEndian;
  }
}