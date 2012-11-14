part of dartflash;

class Bitmap extends DisplayObject
{
  BitmapData bitmapData;
  String pixelSnapping;
  Rectangle clipRectangle;

  Bitmap([this.bitmapData = null, this.pixelSnapping = "auto"])
  {
    clipRectangle = null;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle])
  {
    int width = (bitmapData != null) ? bitmapData.width : 0;
    int height = (bitmapData != null) ? bitmapData.height : 0;

    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    if (bitmapData != null && localX >= 0.0 && localY >= 0.0 && localX < bitmapData.width && localY < bitmapData.height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    if (bitmapData != null)
    {
      if (clipRectangle == null)
        bitmapData.render(renderState);
      else
        bitmapData.renderClipped(renderState, clipRectangle);
    }
  }


}
