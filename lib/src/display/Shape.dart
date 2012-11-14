part of dartflash;

class Shape extends DisplayObject
{
  Graphics _graphics;

  Shape()
  {
    _graphics = new Graphics();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Graphics get graphics => _graphics;

  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle])
  {
    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    returnRectangle.x = matrix.tx;
    returnRectangle.y = matrix.ty;
    returnRectangle.width = 0;
    returnRectangle.height = 0;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    // ToDo: At this time it seems too costly to use a Shape as hitTarget. Therefore you
    // could draw the Shape to a BitmapData, which probably will boost performance anyway.

    return null;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    _graphics.render(renderState);
  }



}
