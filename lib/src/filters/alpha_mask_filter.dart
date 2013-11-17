part of stagexl;

class AlphaMaskFilter extends BitmapFilter {
  
  final BitmapData _alphaBitmapData;
  final Matrix _matrix;
  
  AlphaMaskFilter(BitmapData alphaBitmapData, [Matrix matrix]) :
    _alphaBitmapData = alphaBitmapData,
    _matrix = (matrix != null) ? matrix : new Matrix.fromIdentity();
  
  Matrix get matrix => _matrix;
  
  BitmapFilter clone() {
    return new AlphaMaskFilter(_alphaBitmapData, _matrix.clone());
  }
  
  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData sourceBitmapData, Rectangle sourceRect, BitmapData destinationBitmapData, Point destinationPoint) {
    
    var destinationRect = new Rectangle(destinationPoint.x, destinationPoint.y, sourceRect.width, sourceRect.height);
    var destinationBounds = new Rectangle(0, 0, destinationBitmapData.width, destinationBitmapData.height);
    
    var alphaRoot = new Sprite();
    var alphaWarp = new Warp();
    var alphaBitmap = new Bitmap(_alphaBitmapData);
    
    alphaRoot.x = destinationPoint.x;
    alphaRoot.y = destinationPoint.y;
    alphaRoot.addChild(alphaWarp);
    
    alphaWarp.matrix = _matrix;
    alphaWarp.compositeOperation = CompositeOperation.DESTINATION_IN;
    alphaWarp.addChild(alphaBitmap);
    
    if (!destinationRect.containsRect(destinationBounds)) {
      alphaWarp.mask = new Mask.rectangle(0, 0, sourceRect.width, sourceRect.height);
      alphaWarp.mask.targetSpace = alphaRoot;
    }
    
    if (!identical(sourceBitmapData, destinationBitmapData) || !sourceRect.topLeft.equals(destinationPoint)) {
      destinationBitmapData.copyPixels(sourceBitmapData, sourceRect, destinationPoint);
    }
    
    destinationBitmapData.draw(alphaRoot, alphaRoot.transformationMatrix);
  }
  
  //-----------------------------------------------------------------------------------------------
  
  Rectangle getBounds() {
    return new Rectangle.zero();
  }
}
