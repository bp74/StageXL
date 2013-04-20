part of stagexl;

class AlphaMaskFilter extends BitmapFilter {
  
  BitmapData _alphaBitmapData;
  Matrix _matrix;
  
  AlphaMaskFilter(BitmapData alphaBitmapData, [Matrix matrix]) {
    _alphaBitmapData = alphaBitmapData;
    _matrix = (matrix != null) ? matrix : _identityMatrix;
  }
  
  BitmapFilter clone() {
    return new AlphaMaskFilter(_alphaBitmapData, _matrix);
  }
  
  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint) {
    
    var sourceContext = sourceBitmapData._getContext();
    var sourceImageData = sourceContext.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    
    var destinationContext = destinationBitmapData._getContext();
    destinationContext.putImageData(sourceImageData, destinationPoint.x, destinationPoint.y);
    
    var alphaRoot = new Sprite();
    var alphaWarp = new Warp();
    var alphaBitmap = new Bitmap(_alphaBitmapData);
    
    alphaRoot.x = destinationPoint.x;
    alphaRoot.y = destinationPoint.y;
    alphaRoot.addChild(alphaWarp);
    
    alphaWarp.matrix = _matrix;
    alphaWarp.compositeOperation = CompositeOperation.DESTINATION_IN;
    alphaWarp.mask = new Mask.rectangle(0, 0, sourceRect.width, sourceRect.height);
    alphaWarp.mask.targetSpace = alphaRoot;
    alphaWarp.addChild(alphaBitmap);
    
    destinationBitmapData.draw(alphaRoot, alphaRoot.transformationMatrix);
  }
  
  //-----------------------------------------------------------------------------------------------
  
  Rectangle getBounds() {
    return new Rectangle.zero();
  }
}
