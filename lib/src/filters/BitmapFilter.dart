part of dartflash;

abstract class BitmapFilter
{
  BitmapFilter clone();
  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint);
  Rectangle getBounds();
}
