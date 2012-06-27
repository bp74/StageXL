class BlurFilter extends BitmapFilter 
{
  int blurX;
  int blurY;
  int quality;
  
  BlurFilter([this.blurX = 4, this.blurY = 4, this.quality = 1])
  {
    if (blurX > 128 || blurY > 128)
      throw new IllegalArgumentException("Error #9004: The maximum blur size is 128.");
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  BitmapFilter clone()
  {
    return new BlurFilter(blurX, blurY, quality); 
  }
  
  //-------------------------------------------------------------------------------------------------

  void _applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    if (quality <= 1) _applyFilterLow(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint); 
    if (quality == 2) _applyFilterMedium(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
    if (quality >= 3) _applyFilterHigh(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);   
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyFilterLow(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    // ToDo: Maybe a simple box blur?
    
    _applyFilterMedium(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _applyFilterMedium(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    // ToDo: Find a good one ... maybe Stack Blur
    // http://www.quasimondo.com/StackBlurForCanvas/StackBlurDemo.html
    
    _applyFilterHigh(sourceBitmapData, sourceRect, destinationBitmapData, destinationPoint);
  }
  
  //-------------------------------------------------------------------------------------------------
  // Credits to Alois Zingl, Vienna, Austria.
  // Extended Binomial Filter for Fast Gaussian Blur
  // http://free.pages.at/easyfilter/gauss.html
  // http://free.pages.at/easyfilter/gauss.pdf
  // Fourth degree of the extended binomial Gaussian blur filter algorithm.  
  //-------------------------------------------------------------------------------------------------

  void _applyFilterHigh(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    html.ImageData sourceImageData = sourceBitmapData._getContext().getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    html.Uint8ClampedArray sourceData = sourceImageData.data;
    
    html.ImageData destinationImageData = destinationBitmapData._getContext().createImageData(sourceImageData.width, sourceImageData.height);
    html.Uint8ClampedArray destinationData = destinationImageData.data;
    
    int width = sourceImageData.width;
    int height = sourceImageData.height;
    
    int radiusX = Math.sqrt(3 * blurX * blurX + 1).toInt();  
    int weightX = radiusX * radiusX * radiusX * radiusX;
    
    int radiusY = Math.sqrt(3 * blurY * blurY + 1).toInt();  
    int weightY = radiusY * radiusY * radiusY * radiusY;    
    
    int p;
    int width4 = width * 4;
    
    int rx1 = radiusX;
    int rx2 = radiusX * 2; 
    int rx3 = radiusX * 3; 
    int rx4 = radiusX * 4; 
    int ry1 = radiusY;
    int ry2 = radiusY * 2; 
    int ry3 = radiusY * 3; 
    int ry4 = radiusY * 4; 

    // ToDo: What buffer should we use to make it cross browser compatible? 
    // 1) html.Uint8Array buffer = new html.Uint8Array(1024);
    // 2) html.Uint8ClampedArray buffer = destinationBitmapData._context.createImageData(16, 16).data; // 1024 Bytes
    // 3) List<int> buffer = new List<int>(1024);
    
    List<int> buffer = new List<int>(1024);

    for (int z = 0; z < 4; z++)
    {
      //------------------------
      // vertical blur...
      
      for (int x = 0, offsetX = z; x < width; x++)      
      {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        
        for (int y = 0 - ry4, offsetY = x * 4 + z; y < height; y++) 
        {                                
          if      (y       >= 0) dif += 6 * buffer[y & 1023] + buffer[(y - ry2) & 1023] - 4 * (buffer[(y - ry1) & 1023] + buffer[(y + ry1) & 1023]);
          else if (y + ry1 >= 0) dif += 6 * buffer[y & 1023] - 4 * (buffer[(y - ry1) & 1023] + buffer[(y + ry1) & 1023]);
          else if (y + ry2 >= 0) dif += 6 * buffer[y & 1023] - 4 * (buffer[(y + ry1) & 1023]);
          else if (y + ry3 >= 0) dif -= 4 * buffer[(y + ry1) & 1023];

          if (y >= 0)
          {
            destinationData[offsetY] = (sum / weightY).toInt();
            offsetY += width4;
          }
          
          int ty = y + ry2 - 1;
          if (ty < 0) ty = 0; else if (ty >= height) ty = height - 1;
          
          p = sourceData[offsetX + ty * width4];
          buffer[(y + ry2) & 1023] = p;
          
          sum += der1 += der2 += dif += p;
        } 
        
        offsetX += 4;
      } 

      //------------------------
      // horizontal blur...
      
      for (int y = 0, offsetY = z; y < height; y++)      
      {
        int dif = 0, der1 = 0, der2 = 0, sum = 0;
        
        for (int x = 0 - rx4, offsetX = y * width4 + z; x < width; x++) 
        {
          if      (x       >= 0) dif += 6 * buffer[x & 1023] + buffer[(x - rx2) & 1023] - 4 * (buffer[(x - rx1) & 1023] + buffer[(x + rx1) & 1023]);
          else if (x + rx1 >= 0) dif += 6 * buffer[x & 1023] - 4 * (buffer[(x - rx1) & 1023] + buffer[(x + rx1) & 1023]);
          else if (x + rx2 >= 0) dif += 6 * buffer[x & 1023] - 4 * (buffer[(x + rx1) & 1023]); 
          else if (x + rx3 >= 0) dif -= 4 * buffer[(x + rx1) & 1023];

          if (x >= 0) 
          {
            destinationData[offsetX] = (sum / weightX).toInt();
            offsetX += 4;
          }
          
          int tx = x + rx2 - 1;
          if (tx < 0) tx = 0; else if (tx >= width) tx = width - 1;
          
          p = destinationData[offsetY + (tx << 2)]; 
          buffer[(x + rx2) & 1023] = p;  
          
          sum += der1 += der2 += dif += p;
        }
        
        offsetY += width4;
      }
    }
    
    destinationBitmapData._getContext().putImageData(destinationImageData, destinationPoint.x, destinationPoint.y);   
  }
  
}

