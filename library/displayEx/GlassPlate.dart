class GlassPlate extends InteractiveObject 
{
  num width;
  num height;
  
  GlassPlate(this.width, this.height);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle = null])
  {
    double x1 = matrix.tx;
    double y1 = matrix.ty;
    double x2 = width * matrix.a + matrix.tx;
    double y2 = width * matrix.b + matrix.ty;
    double x3 = width * matrix.a + height * matrix.c + matrix.tx;
    double y3 = width * matrix.b + height * matrix.d + matrix.ty;
    double x4 = height * matrix.c + matrix.tx;
    double y4 = height * matrix.d + matrix.ty;

    double left = x1;
    if (left > x2) left = x2;
    if (left > x3) left = x3;
    if (left > x4) left = x4;

    double top = y1;
    if (top > y2 ) top = y2;
    if (top > y3 ) top = y3;
    if (top > y4 ) top = y4;

    double right = x1;
    if (right < x2) right = x2;
    if (right < x3) right = x3;
    if (right < x4) right = x4;

    double bottom = y1;
    if (bottom < y2 ) bottom = y2;
    if (bottom < y3 ) bottom = y3;
    if (bottom < y4 ) bottom = y4;

    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    returnRectangle.x = left;
    returnRectangle.y = top;
    returnRectangle.width = right - left;
    returnRectangle.height = bottom - top;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------
  
  DisplayObject hitTestInput(num localX, num localY) 
  {
    return (localX > 0.0 && localX <= width && localY >= 0.0 && localY <= height) ? this : null;
  }
}