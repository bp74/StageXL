class ColorMatrixFilter extends BitmapFilter
{
  List<num> matrix;
  
  ColorMatrixFilter(this.matrix)
  {
    if (this.matrix.length != 20)
      throw new Exception("The supplied matrix needs to be a 4 x 5 matrix.");
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

  void _applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    //redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
    //greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
    //blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
    //alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]
    
    html.ImageData imageData = sourceBitmapData._getContext().getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    html.Uint8ClampedArray data = imageData.data;
        
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

    int pixels = data.length >> 2;
    
    for(int i = 0 ; i < pixels; i++)
    {
      int indexR = i << 2 ;
      int indexG = indexR + 1;
      int indexB = indexR + 2;
      int indexA = indexR + 3;

      int srcR = data[indexR];
      int srcG = data[indexG];
      int srcB = data[indexB];
      int srcA = data[indexA];

      data[indexR] = ((a00 * srcR) + (a01 * srcG) + (a02 * srcB) + (a03 * srcA) + a04) >> 16;
      data[indexG] = ((a05 * srcR) + (a06 * srcG) + (a07 * srcB) + (a08 * srcA) + a09) >> 16;
      data[indexB] = ((a10 * srcR) + (a11 * srcG) + (a12 * srcB) + (a13 * srcA) + a14) >> 16;
      data[indexA] = ((a15 * srcR) + (a16 * srcG) + (a17 * srcB) + (a18 * srcA) + a19) >> 16;
    }
    
    destinationBitmapData._getContext().putImageData(imageData, destinationPoint.x, destinationPoint.y);
  }
  
}
