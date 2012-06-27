/*
class DropShadowFilter 
{
  num distance;
  num angle;
  int color;
  num alpha;
  int blurX;
  int blurY;
  num strength;
  int quality;
  bool inner;
  bool knockout;
  bool hideObject;
  
  DropShadowFilter([this.distance = 4.0, this.angle = Math.PI / 4, this.color = 0, this.alpha = 1.0, this.blurX = 4, this.blurY = 4, this.strength = 1.0, this.quality = 1, this.inner = false, this.knockout = false, this.hideObject = false]);
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  BitmapFilter clone()
  {
    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
  }
  
  //-------------------------------------------------------------------------------------------------
  
  void _applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint)
  {
    // COMING SOON ...   
  }
  
}
*/