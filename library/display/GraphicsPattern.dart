class GraphicsPattern 
{
  BitmapData _bitmapData;
  Matrix _matrix;
  String _repeatOption;
  
  GraphicsPattern.repeat(BitmapData bitmapData, [Matrix matrix = null])
  {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat";
  }

  GraphicsPattern.repeatX(BitmapData bitmapData, [Matrix matrix = null])
  {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat-x";
  }
  
  GraphicsPattern.repeatY(BitmapData bitmapData, [Matrix matrix = null])
  {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat-y";
  }
  
  GraphicsPattern.noRepeat(BitmapData bitmapData, [Matrix matrix = null])
  {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "no-repeat";
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  html.CanvasPattern getCanvasPattern(html.CanvasRenderingContext2D context)
  {
    return context.createPattern(_bitmapData._htmlElement, _repeatOption);
  }
  
}
