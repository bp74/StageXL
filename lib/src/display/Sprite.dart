part of stagexl;

class Sprite extends DisplayObjectContainer
{
  bool buttonMode = false;
  bool useHandCursor = false;
  
  Graphics _graphics = null;

  Graphics get graphics {
    return (_graphics != null) ? _graphics : _graphics = new Graphics();
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------
  
  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {
    
    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();
    
    super.getBoundsTransformed(matrix, returnRectangle);
    
    if (_graphics != null) {
      returnRectangle = _graphics._getBoundsTransformed(matrix).union(returnRectangle);
    }
    
    return returnRectangle;
  }
  
  //-----------------------------------------------------------------------------------------------
  
  DisplayObject hitTestInput(num localX, num localY) {
    
    var target = super.hitTestInput(localX, localY);
    
    if (target == null && _graphics != null) {
      if (_graphics._hitTestInput(localX, localY)) {
        target = this;
      }
    } 
    
    return target;
  }
  
  //-----------------------------------------------------------------------------------------------
  
  render(RenderState renderState) {
    
    if (_graphics != null)
      _graphics.render(renderState);
    
    super.render(renderState);
  }
  
}
