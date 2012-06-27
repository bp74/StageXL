class SimpleButton extends InteractiveObject
{
  DisplayObject upState;
  DisplayObject overState;
  DisplayObject downState;
  DisplayObject hitTestState;

  bool useHandCursor = true;
  bool enabled = true;

  DisplayObject _currentState;

  SimpleButton([this.upState = null, this.overState = null, this.downState = null, this.hitTestState = null])
  {
    addEventListener(MouseEvent.MOUSE_OVER, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_OUT, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);
    addEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);

    _currentState = this.upState;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle = null])
  {
    if (_currentState != null)
    {
      _tmpMatrix.copyFromAndConcat(_currentState._transformationMatrix, matrix);

      return _currentState.getBoundsTransformed(_tmpMatrix, returnRectangle);
    }

    return super.getBoundsTransformed(matrix, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    if (this.hitTestState != null)
    {
      Matrix matrix = this.hitTestState._transformationMatrix;

      double deltaX = localX - matrix.tx;
      double deltaY = localY - matrix.ty;
      double childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
      double childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

      if (this.hitTestState.hitTestInput(childX, childY) != null)
        return this;
    }

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    if (_currentState != null)
      renderState.renderDisplayObject(_currentState);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onMouseEvent(MouseEvent mouseEvent)
  {
    bool over = (this.hitTestInput(mouseEvent.localX, mouseEvent.localY) == this) && (mouseEvent.type != MouseEvent.MOUSE_OUT);
    bool down = mouseEvent.buttonDown;

    _currentState = upState;

    if (over && down) _currentState = downState;
    if (over && !down) _currentState = overState;
  }

}
