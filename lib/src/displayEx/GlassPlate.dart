part of stagexl;

class GlassPlate extends InteractiveObject {
  
  num width;
  num height;

  GlassPlate(this.width, this.height);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {
    
    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    
    if (localX >= 0.0 && localY >= 0.0  && localX < width && localY < height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

  }
  
}