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
    
    if (lockCenter) {
      Mouse._dragSpriteCenter = this.getBoundsTransformed(_tmpMatrixIdentity).center;
    } else {
      var mp = this.mousePosition;
      Mouse._dragSpriteCenter = (mp != null) ? mp : new Point.zero();
    }

    _updateDrag();
  }
  
  stopDrag() {
    
    Mouse._dragSprite = null;
  }
  
  _updateDrag() {
    
    var mp = this.mousePosition;
    if (mp != null) {
      
      var pivot = mp.subtract(Mouse._dragSpriteCenter);
      pivot.offset(_pivotX, _pivotY);
      
      var location = _transformationMatrix.transformPoint(pivot);
      this.x = location.x;
      this.y = location.y;
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
