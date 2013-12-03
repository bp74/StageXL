part of stagexl;

class GraphicsPattern {
  
  BitmapData _bitmapData;
  Matrix _matrix;
  String _repeatOption;

  GraphicsPattern.repeat(BitmapData bitmapData, [Matrix matrix]) {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat";
  }

  GraphicsPattern.repeatX(BitmapData bitmapData, [Matrix matrix]) {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat-x";
  }

  GraphicsPattern.repeatY(BitmapData bitmapData, [Matrix matrix]) {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "repeat-y";
  }

  GraphicsPattern.noRepeat(BitmapData bitmapData, [Matrix matrix]) {
    _bitmapData = bitmapData;
    _matrix = matrix;
    _repeatOption = "no-repeat";
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Matrix get matrix => _matrix;
  
  CanvasPattern getCanvasPattern(CanvasRenderingContext2D context) {
    CanvasImageSource source = _bitmapData._source;
    if(source is ImageElement) {
      return context.createPatternFromImage(source, _repeatOption);
    } else {
      return context.createPattern(source, _repeatOption);
    }
  }

}
