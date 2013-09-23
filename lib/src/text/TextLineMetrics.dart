part of stagexl;

class TextLineMetrics {

  String _text;
  int _textIndex;

  num _x = 0.0;
  num _y = 0.0;   // relative to baseline
  num _width = 0.0;
  num _height = 0.0;
  num _ascent = 0.0;
  num _descent = 0.0;
  num _leading = 0.0;
  num _indent = 0.0;

  TextLineMetrics._internal(this._text, this._textIndex);

  //-----------------------------------------------------------------------------------------------

  num get x => _x;
  num get y => _y;

  num get width => _width;
  num get height => _height;

  num get ascent => _ascent;
  num get descent => _descent;
  num get leading => _leading;
  num get indent => _indent;
}
