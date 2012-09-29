abstract class BitmapFilter
{
  BitmapFilter clone();
  void _applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint);
}
