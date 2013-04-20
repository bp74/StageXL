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

    destinationContext.save();
    destinationContext.beginPath();
    destinationContext.rect(destinationPoint.x, destinationPoint.y, sourceRect.width, sourceRect.height);
    destinationContext.clip();
    
    var matrix = new Matrix(1.0, 0.0, 0.0, 1.0, destinationPoint.x, destinationPoint.y);
    var renderState = new RenderState.fromCanvasRenderingContext2D(destinationContext, matrix);
    
    destinationContext.transform(_matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
    destinationContext.globalCompositeOperation = CompositeOperation.DESTINATION_IN;
    
    _alphaBitmapData.render(renderState);
   
    destinationContext.globalCompositeOperation = CompositeOperation.SOURCE_OVER;
    destinationContext.restore();
  }
  
  //-----------------------------------------------------------------------------------------------
  
  Rectangle getBounds() {
    return new Rectangle.zero();
  }
}
