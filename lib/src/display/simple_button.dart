part of stagexl;

class SimpleButton extends InteractiveObject {

  DisplayObject upState;
  DisplayObject overState;
  DisplayObject downState;
  DisplayObject hitTestState;

  bool enabled = true;

  DisplayObject _currentState;

  SimpleButton([this.upState, this.overState, this.downState, this.hitTestState]) {

    useHandCursor = true;
    
    addEventListener(MouseEvent.MOUSE_OVER, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_OUT, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);

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

    if (_currentState != null)
      renderState.renderDisplayObject(_currentState);
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

}
