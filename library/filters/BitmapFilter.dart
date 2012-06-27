class BitmapFilter 
{
  abstract BitmapFilter clone();
  abstract void _applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint);
}
