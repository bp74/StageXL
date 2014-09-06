part of stagexl.toolkit;

class ButtonHelper {

  MovieClip target;
  dynamic upLabel;
  dynamic overLabel;
  dynamic downLabel;

  bool useHandCursor = true;
  bool enabled = true;

  ButtonHelper(this.target, this.upLabel, this.overLabel, this.downLabel, [DisplayObject hitArea])
      : super() {

    target.stop();
    target.onMouseOver.listen(_onMouseEvent);
    target.onMouseOut.listen(_onMouseEvent);
    target.onMouseDown.listen(_onMouseEvent);
    target.onMouseUp.listen(_onMouseEvent);
    target.hitArea = hitArea;
    target.useHandCursor = true;

    if (hitArea is MovieClip) {
      var movieClip = hitArea;
      movieClip.actionsEnabled = false;
      movieClip.stop();
      movieClip.advance(0); // process frame out of stage
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
