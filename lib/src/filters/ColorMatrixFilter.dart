part of dartflash;

class ColorMatrixFilter extends BitmapFilter
{
  List<num> matrix;

  ColorMatrixFilter(this.matrix)
  {
    if (this.matrix.length != 20)
      throw new ArgumentError("The supplied matrix needs to be a 4 x 5 matrix.");
  }

  ColorMatrixFilter.grayscale(): matrix = [0.212671, 0.715160, 0.072169, 0, 0,
                                           0.212671, 0.715160, 0.072169, 0, 0,
                                           0.212671, 0.715160, 0.072169, 0, 0,
                                           0, 0, 0, 1, 0];

  ColorMatrixFilter.invert():matrix = [-1,  0,  0, 0, 255,
                                        0, -1,  0, 0, 255,
                                        0,  0, -1, 0, 255,
                                        0,  0,  0, 1, 0];

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapFilter clone()
  {
    return new ColorMatrixFilter(new List<num>.from(this.matrix));
  }

  //-------------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    //redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
    //greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
    //blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
    //alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]

    var imageData = sourceBitmapData._getContext().getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    var data = imageData.data;

    int a00 = (this.matrix[00] * 65536).toInt();
    int a01 = (this.matrix[01] * 65536).toInt();
    int a02 = (this.matrix[02] * 65536).toInt();
    int a03 = (this.matrix[03] * 65536).toInt();
    int a04 = (this.matrix[04] * 65536).toInt();
    int a05 = (this.matrix[05] * 65536).toInt();
    int a06 = (this.matrix[06] * 65536).toInt();
    int a07 = (this.matrix[07] * 65536).toInt();
    int a08 = (this.matrix[08] * 65536).toInt();
    int a09 = (this.matrix[09] * 65536).toInt();
    int a10 = (this.matrix[10] * 65536).toInt();
    int a11 = (this.matrix[11] * 65536).toInt();
    int a12 = (this.matrix[12] * 65536).toInt();
    int a13 = (this.matrix[13] * 65536).toInt();
    int a14 = (this.matrix[14] * 65536).toInt();
    int a15 = (this.matrix[15] * 65536).toInt();
    int a16 = (this.matrix[16] * 65536).toInt();
    int a17 = (this.matrix[17] * 65536).toInt();
    int a18 = (this.matrix[18] * 65536).toInt();
    int a19 = (this.matrix[19] * 65536).toInt();

    // ToDo: Check again for other optimizations in the future.
    // Maybe floating point calculations with .toInt() is faster?
    // This is the fastest solution now, still pretty slow.

    if (_isLittleEndianSystem) {
      for(int index = 0 ; index <= data.length - 4; index += 4) {
        int srcR = data[index + 0];
        int srcG = data[index + 1];
        int srcB = data[index + 2];
        int srcA = data[index + 3];

        data[index + 0] = ((a00 * srcR) + (a01 * srcG) + (a02 * srcB) + (a03 * srcA) + a04) ~/ 65536;
        data[index + 1] = ((a05 * srcR) + (a06 * srcG) + (a07 * srcB) + (a08 * srcA) + a09) ~/ 65536;
        data[index + 2] = ((a10 * srcR) + (a11 * srcG) + (a12 * srcB) + (a13 * srcA) + a14) ~/ 65536;
        data[index + 3] = ((a15 * srcR) + (a16 * srcG) + (a17 * srcB) + (a18 * srcA) + a19) ~/ 65536;
      }
    } else {
      for(int index = 0 ; index <= data.length - 4; index += 4) {
        int srcA = data[index + 0];
        int srcB = data[index + 1];
        int srcG = data[index + 2];
        int srcR = data[index + 3];

        data[index + 0] = ((a15 * srcR) + (a16 * srcG) + (a17 * srcB) + (a18 * srcA) + a19) ~/ 65536;
        data[index + 1] = ((a10 * srcR) + (a11 * srcG) + (a12 * srcB) + (a13 * srcA) + a14) ~/ 65536;
        data[index + 2] = ((a05 * srcR) + (a06 * srcG) + (a07 * srcB) + (a08 * srcA) + a09) ~/ 65536;
        data[index + 3] = ((a00 * srcR) + (a01 * srcG) + (a02 * srcB) + (a03 * srcA) + a04) ~/ 65536;
      }
    }

    destinationBitmapData._getContext().putImageData(imageData, destinationPoint.x, destinationPoint.y);
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBounds()
  {
    return new Rectangle(0, 0, 0, 0);
  }

}
