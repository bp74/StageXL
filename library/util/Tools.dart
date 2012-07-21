//-------------------------------------------------------------------------------------------------

String _color2rgb(int color)
{
  int r = (color >> 16) & 0xFF;
  int g = (color >>  8) & 0xFF;
  int b = (color >>  0) & 0xFF;

  return "rgb($r,$g,$b)";  
}

//-------------------------------------------------------------------------------------------------

String _color2rgba(int color)
{
  int a = (color >> 24) & 0xFF;    
  int r = (color >> 16) & 0xFF;
  int g = (color >>  8) & 0xFF;
  int b = (color >>  0) & 0xFF;
  
  return "rgba($r,$g,$b,${a / 255.0})";
}

//-------------------------------------------------------------------------------------------------

Rectangle _getBoundsTransformedHelper(Matrix matrix, num width, num height, Rectangle returnRectangle)
{
  // tranformedX = X * matrix.a + Y * matrix.c + matrix.tx;
  // tranformedY = X * matrix.b + Y * matrix.d + matrix.ty;
  
  double x1 = 0.0;
  double y1 = 0.0;
  double x2 = width * matrix.a;
  double y2 = width * matrix.b;
  double x3 = width * matrix.a + height * matrix.c;
  double y3 = width * matrix.b + height * matrix.d;
  double x4 = height * matrix.c;
  double y4 = height * matrix.d;

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

  returnRectangle.x = matrix.tx + left;
  returnRectangle.y = matrix.ty + top;
  returnRectangle.width = right - left;
  returnRectangle.height = bottom - top;

  return returnRectangle;  
}