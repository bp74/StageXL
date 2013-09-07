part of stagexl;

abstract class BitmapFilter {

  BitmapFilter clone();
  Rectangle getBounds();

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint);

  //-----------------------------------------------------------------------------------------------

  _premultiplyAlpha(ImageData imageData) {

    var data = imageData.data;

    var rChannel = _isLittleEndianSystem ? 0 : 3;
    var gChannel = _isLittleEndianSystem ? 1 : 2;
    var bChannel = _isLittleEndianSystem ? 2 : 1;
    var aChannel = _isLittleEndianSystem ? 3 : 0;

    for(var i = 0; i <= data.length - 4; i += 4) {
      var r = data[i + rChannel];
      var g = data[i + gChannel];
      var b = data[i + bChannel];
      var a = data[i + aChannel];
      r = (r * a) ~/ 255;
      g = (g * a) ~/ 255;
      b = (b * a) ~/ 255;
      data[i + rChannel] = r;
      data[i + gChannel] = g;
      data[i + bChannel] = b;
    }
  }

  //-----------------------------------------------------------------------------------------------

  _unpremultiplyAlpha(ImageData imageData) {

    var data = imageData.data;

    var rChannel = _isLittleEndianSystem ? 0 : 3;
    var gChannel = _isLittleEndianSystem ? 1 : 2;
    var bChannel = _isLittleEndianSystem ? 2 : 1;
    var aChannel = _isLittleEndianSystem ? 3 : 0;

    for(var i = 0; i <= data.length - 4; i += 4) {
      var r = data[i + rChannel];
      var g = data[i + gChannel];
      var b = data[i + bChannel];
      var a = data[i + aChannel];
      if (a > 0) {
        r = (r * 255) ~/ a;
        g = (g * 255) ~/ a;
        b = (b * 255) ~/ a;
        data[i + rChannel] = r;
        data[i + gChannel] = g;
        data[i + bChannel] = b;
      }
    }
  }


}
