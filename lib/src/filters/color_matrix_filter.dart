part of stagexl;

class ColorMatrixFilter extends BitmapFilter {

  final List<num> _matrix = new List.filled(20, 0.0);

  ColorMatrixFilter(List<num> matrix) {
    if (matrix.length != 20) {
      throw new ArgumentError("The supplied matrix needs to be a 4 x 5 matrix.");
    }
    for(int i = 0; i < matrix.length; i++) {
      _matrix[i] = _ensureNum(matrix[i]);
    }
  }

  ColorMatrixFilter.grayscale() : this([
    0.212671, 0.715160, 0.072169, 0, 0,
    0.212671, 0.715160, 0.072169, 0, 0,
    0.212671, 0.715160, 0.072169, 0, 0,
    0, 0, 0, 1, 0]);

  ColorMatrixFilter.invert() : this([
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1, 0]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone() => new ColorMatrixFilter(_matrix);
  Rectangle get overlap => new Rectangle(0, 0, 0, 0);

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    //redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
    //greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
    //blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
    //alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]

    bool isLittleEndianSystem = _isLittleEndianSystem;

    int d0c0 = ((isLittleEndianSystem ? _matrix[00] : _matrix[18]) * 65536).round();
    int d0c1 = ((isLittleEndianSystem ? _matrix[01] : _matrix[17]) * 65536).round();
    int d0c2 = ((isLittleEndianSystem ? _matrix[02] : _matrix[16]) * 65536).round();
    int d0c3 = ((isLittleEndianSystem ? _matrix[03] : _matrix[15]) * 65536).round();
    int d0cc = ((isLittleEndianSystem ? _matrix[04] : _matrix[19]) * 65536).round();

    int d1c0 = ((isLittleEndianSystem ? _matrix[05] : _matrix[13]) * 65536).round();
    int d1c1 = ((isLittleEndianSystem ? _matrix[06] : _matrix[12]) * 65536).round();
    int d1c2 = ((isLittleEndianSystem ? _matrix[07] : _matrix[11]) * 65536).round();
    int d1c3 = ((isLittleEndianSystem ? _matrix[08] : _matrix[10]) * 65536).round();
    int d1cc = ((isLittleEndianSystem ? _matrix[09] : _matrix[14]) * 65536).round();

    int d2c0 = ((isLittleEndianSystem ? _matrix[10] : _matrix[08]) * 65536).round();
    int d2c1 = ((isLittleEndianSystem ? _matrix[11] : _matrix[07]) * 65536).round();
    int d2c2 = ((isLittleEndianSystem ? _matrix[12] : _matrix[06]) * 65536).round();
    int d2c3 = ((isLittleEndianSystem ? _matrix[13] : _matrix[05]) * 65536).round();
    int d2cc = ((isLittleEndianSystem ? _matrix[14] : _matrix[09]) * 65536).round();

    int d3c0 = ((isLittleEndianSystem ? _matrix[15] : _matrix[03]) * 65536).round();
    int d3c1 = ((isLittleEndianSystem ? _matrix[16] : _matrix[02]) * 65536).round();
    int d3c2 = ((isLittleEndianSystem ? _matrix[17] : _matrix[01]) * 65536).round();
    int d3c3 = ((isLittleEndianSystem ? _matrix[18] : _matrix[00]) * 65536).round();
    int d3cc = ((isLittleEndianSystem ? _matrix[19] : _matrix[04]) * 65536).round();

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for(int index = 0 ; index <= data.length - 4; index += 4) {
      int c0 = data[index + 0];
      int c1 = data[index + 1];
      int c2 = data[index + 2];
      int c3 = data[index + 3];
      data[index + 0] = ((d0c0 * c0 + d0c1 * c1 + d0c2 * c2 + d0c3 * c3 + d0cc) | 0) >> 16;
      data[index + 1] = ((d1c0 * c0 + d1c1 * c1 + d1c2 * c2 + d1c3 * c3 + d1cc) | 0) >> 16;
      data[index + 2] = ((d2c0 * c0 + d2c1 * c1 + d2c2 * c2 + d2c3 * c3 + d2cc) | 0) >> 16;
      data[index + 3] = ((d3c0 * c0 + d3c1 * c1 + d3c2 * c2 + d3c3 * c3 + d3cc) | 0) >> 16;
    }

    renderTextureQuad.putImageData(imageData);
  }

}
