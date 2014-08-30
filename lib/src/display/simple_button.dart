part of stagexl.display;

class SimpleButton extends InteractiveObject {

  DisplayObject upState;
  DisplayObject overState;
  DisplayObject downState;
  DisplayObject hitTestState;

  bool enabled = true;

  DisplayObject _currentState;

  SimpleButton([this.upState, this.overState, this.downState, this.hitTestState]) {

    this.useHandCursor = true;

    this.onMouseOver.listen(_onMouseEvent);
    this.onMouseOut.listen(_onMouseEvent);
    this.onMouseDown.listen(_onMouseEvent);
    this.onMouseUp.listen(_onMouseEvent);

    this.onTouchOver.listen(_onTouchEvent);
    this.onTouchOut.listen(_onTouchEvent);
    this.onTouchBegin.listen(_onTouchEvent);
    this.onTouchEnd.listen(_onTouchEvent);

    _currentState = this.upState;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    if (_currentState != null) {
      _tmpMatrix.copyFromAndConcat(_currentState.transformationMatrix, matrix);
      return _currentState.getBoundsTransformed(_tmpMatrix, returnRectangle);
    }

    return super.getBoundsTransformed(matrix, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    if (this.hitTestState != null) {

      Matrix matrix = this.hitTestState.transformationMatrix;

      num deltaX = localX - matrix.tx;
      num deltaY = localY - matrix.ty;
      num childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
      num childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

      if (this.hitTestState.hitTestInput(childX, childY) != null) return this;
    }

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {
    if (_currentState != null) {
      renderState.renderObject(_currentState);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onMouseEvent(MouseEvent mouseEvent) {
    if (mouseEvent.type == MouseEvent.MOUSE_OUT) {
      _currentState = upState;
    } else {
      _currentState = mouseEvent.buttonDown ? downState : overState;
    }
  }

  void _onTouchEvent(TouchEvent touchEvent) {
    if (touchEvent.isPrimaryTouchPoint) {
      switch(touchEvent.type) {
        case TouchEvent.TOUCH_OVER: _currentState = downState; break;
        case TouchEvent.TOUCH_OUT: _currentState = upState; break;
        case TouchEvent.TOUCH_BEGIN: _currentState = downState; break;
        case TouchEvent.TOUCH_END: _currentState = upState; break;
      }
    }
  }

}
