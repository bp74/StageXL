part of stagexl;

class Sprite extends DisplayObjectContainer {
  
  bool buttonMode = false;
  bool useHandCursor = false;
  Sprite hitArea = null;
  
  Graphics _graphics = null;
  DisplayObject _dropTarget = null;
  
  Graphics get graphics {
    return (_graphics != null) ? _graphics : _graphics = new Graphics();
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------
  
  startDrag([bool lockCenter = false, Rectangle bounds = null]) {
    
    Mouse._dragSprite = this;
    Mouse._dragSpriteCenter = lockCenter ?
      this.getBoundsTransformed(_tmpMatrixIdentity).center : _mousePoint;
      
      var rect = this.getBoundsTransformed(_tmpMatrixIdentity);
      print(Mouse._dragSpriteCenter);
    _updateDrag();
  }
  
  stopDrag() {
    
    Mouse._dragSprite = null;
  }
  
  _updateDrag() {
    
    if (this.stage != null) {
      var delta = _mousePoint.subtract(Mouse._dragSpriteCenter);
      delta.x = delta.x + pivotX;
      delta.y = delta.y + pivotY;
      var deltaParent = _transformationMatrix.transformPoint(delta);
      this.x = deltaParent.x;
      this.y = deltaParent.y;
    }
  }
  
  DisplayObject get dropTarget => _dropTarget;
  
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
    
    DisplayObject target = null;
    
    if (this.hitArea != null) {
      
      var matrix = this.hitArea.transformationMatrixTo(this);
      if (matrix != null) {
        double deltaX = localX - matrix.tx;
        double deltaY = localY - matrix.ty;
        double childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
        double childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;
        
        if (this.hitArea.hitTestInput(childX, childY) != null) {
          target = this;
        }
      }

    } else {
    
      target = super.hitTestInput(localX, localY);
      
      if (target == null && _graphics != null) {
        if (_graphics._hitTestInput(localX, localY)) {
          target = this;
        }
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
