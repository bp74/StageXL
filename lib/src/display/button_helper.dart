part of stagexl;

class ButtonHelper {
  
  MovieClip target;
  var upLabel;
  var overLabel;
  var downLabel;
  
  bool useHandCursor = true;
  bool enabled = true;
  
  ButtonHelper(this.target, this.upLabel, this.overLabel, this.downLabel, [DisplayObject hitArea])
    : super() {
    
    target.useHandCursor = true;
    target.stop();
    target.addEventListener(MouseEvent.MOUSE_OVER, _onMouseEvent);
    target.addEventListener(MouseEvent.MOUSE_OUT, _onMouseEvent);
    target.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);
    target.addEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);
    
    if (hitArea != null) {
      if (hitArea is MovieClip) {
        var mc = hitArea;
        mc.actionsEnabled = false;
        mc.stop();
        mc.advance(0); // process frame out of stage
      }
      
      if (hitArea._parent == null)
        hitArea._parent = target; // consider the hitArea as a child
      target.hitArea = hitArea;
    }
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onMouseEvent(MouseEvent mouseEvent) {
    
    if (mouseEvent.type == MouseEvent.MOUSE_OUT) {
      target.gotoAndStop(upLabel);
    } else {
      target.gotoAndStop(mouseEvent.buttonDown ? downLabel : overLabel);
    }
  }
}

