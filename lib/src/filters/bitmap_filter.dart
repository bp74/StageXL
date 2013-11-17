part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();
  Rectangle getBounds();

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(ImageData imageData) {

    var data = imageData.data;
    var isLittleEndianSystem = _isLittleEndianSystem;

    for(var i = 0; i <= data.length - 4; i += 4) {
      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];

      if (c0 is! num) continue; // dart2js_hint
      if (c1 is! num) continue; // dart2js_hint
      if (c2 is! num) continue; // dart2js_hint
      if (c3 is! num) continue; // dart2js_hint

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

      if (c0 is! num) continue; // dart2js_hint
      if (c1 is! num) continue; // dart2js_hint
      if (c2 is! num) continue; // dart2js_hint
      if (c3 is! num) continue; // dart2js_hint

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


}
