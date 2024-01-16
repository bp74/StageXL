part of '../text.dart';

class TextLineMetrics {
  final String _text;
  final int _textIndex;

  // These private fields are modified directly elsewhere in this library.
  // ignore_for_file: prefer_final_fields
  num _x = 0.0;
  num _y = 0.0; // relative to baseline
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
