part of stagexl;

class TextField extends InteractiveObject {

  String _text = "";
  int _textColor = 0x000000;
  TextFormat _defaultTextFormat = null;

  String _autoSize = TextFieldAutoSize.NONE;
  String _gridFitType = GridFitType.PIXEL;
  String _type = TextFieldType.DYNAMIC;

  bool _wordWrap = false;
  bool _background = false;
  int _backgroundColor = 0x000000;
  bool _border = false;
  int _borderColor = 0x000000;
  num _width = 100;
  num _height = 100;

  num _textWidth = 0;
  num _textHeight = 0;
  List<String> _linesText;
  List<TextLineMetrics> _linesMetrics;

  bool _canvasRefreshPending = true;
  CanvasElement _canvas = null;
  CanvasRenderingContext2D _context = null;

  //-------------------------------------------------------------------------------------------------

  TextField([String text, TextFormat textFormat]) {

    if (text != null) _text = text;

    if (textFormat != null) defaultTextFormat = textFormat;
    else _defaultTextFormat = new TextFormat("Arial", 12, 0x000000);

    _linesText = new List<String>();
    _linesMetrics = new List<TextLineMetrics>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String get text => _text;
  int get textColor => _textColor;
  TextFormat get defaultTextFormat => _defaultTextFormat;

  String get autoSize => _autoSize;
  String get gridFitType => _gridFitType;
  String get type => _type;
  bool get wordWrap => _wordWrap;

  bool get background => _background;
  int get backgroundColor => _backgroundColor;
  bool get border => _border;
  int get borderColor => _borderColor;
  num get width => _width;
  num get height => _height;

  //-------------------------------------------------------------------------------------------------

  void set text(String value) { _text = value; _canvasRefreshPending = true; }
  void set textColor(int value) { _textColor = value; _canvasRefreshPending = true; }
  void set defaultTextFormat(TextFormat value) { _defaultTextFormat = value; _textColor = _defaultTextFormat.color; _canvasRefreshPending = true; }

  void set autoSize(String value) { _autoSize = value; _canvasRefreshPending = true; }
  void set gridFitType(String value) { _gridFitType = value; _canvasRefreshPending = true; }
  void set type(String value) { _type = value; _canvasRefreshPending = true; }
  void set wordWrap(bool value) { _wordWrap = value; _canvasRefreshPending = true; }

  void set background(bool value) { _background = value; _canvasRefreshPending = true; }
  void set backgroundColor(int value) { _backgroundColor = value; _canvasRefreshPending = true; }
  void set border(bool value) { _border = value; _canvasRefreshPending = true; }
  void set borderColor(int value) { _borderColor = value; _canvasRefreshPending = true; }
  void set width(num value) { _width = value; _canvasRefreshPending = true; }
  void set height(num value) { _height = value; _canvasRefreshPending = true; }

  //-------------------------------------------------------------------------------------------------

  num get textWidth { _canvasRefresh(); return _textWidth; }
  num get textHeight { _canvasRefresh(); return _textHeight; }
  int get numLines { _canvasRefresh(); return _linesText.length; }

  int getLineLength(int lineIndex) { _canvasRefresh(); return _linesText[lineIndex].length; }
  TextLineMetrics getLineMetrics(int lineIndex) { _canvasRefresh(); return _linesMetrics[lineIndex]; }
  String getLineText(int lineIndex) { _canvasRefresh(); return _linesText[lineIndex]; }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {
    return _getBoundsTransformedHelper(matrix, _width, _height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    if (localX >= 0 && localY >= 0 && localX < _width && localY < _height)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    _canvasRefresh();
    renderState._context.drawImageScaled(_canvas, 0.0, 0.0, _width, _height);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _processTextLines(String fontStyle) {

    var fontStyleMetrics = _getFontStyleMetrics(fontStyle);

    _linesText.clear();
    _linesMetrics.clear();

    //---------------------------

    if (_wordWrap == false) {

      for(String paragraph in _text.replaceAll('\r', '').split('\n'))
        _linesText.add(paragraph);

    } else {

      // Split text into paragraphs

      for(String paragraph in _text.replaceAll('\r', '').split('\n')) {

        var line = '';

        // Split paragraphs into words

        for(String word in paragraph.split(' ')) {

          var previousLine = line;

          line = (line.length == 0) ? word : line + ' ' + word;

          if (_context.measureText(line).width > _width) {

            if (previousLine.length == 0) {
              _linesText.add(line);
              line = '';
            } else {
              _linesText.add(previousLine);
              line = word;
            }
          }
        }

        if (line.isEmpty == false) {
          _linesText.add(line);
        }
      }
    }

    //---------------------------

    _textWidth = 0;
    _textHeight = 0;

    for(String line in _linesText) {

      var metrics = _context.measureText(line);
      var offsetX = 0.0;

      if (_defaultTextFormat.align == TextFormatAlign.CENTER || _defaultTextFormat.align == TextFormatAlign.JUSTIFY)
        offsetX = (_width - metrics.width) / 2;

      if (_defaultTextFormat.align == TextFormatAlign.RIGHT || _defaultTextFormat.align == TextFormatAlign.END)
        offsetX = _width - metrics.width;

      var textLineMetrics = new TextLineMetrics(
        offsetX, metrics.width, _defaultTextFormat.size, fontStyleMetrics.ascent, fontStyleMetrics.descent, 0);

      _linesMetrics.add(textLineMetrics);
      _textWidth = max(_textWidth, textLineMetrics.width);
      _textHeight = _textHeight + textLineMetrics.height;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _canvasRefresh() {

    if (_canvasRefreshPending) {

      _canvasRefreshPending = false;

      var ratio = _devicePixelRatio / _backingStorePixelRatio;
      var canvasWidth = (_width * ratio).ceil();
      var canvasHeight =  (_height * ratio).ceil();

      if (_canvas == null) {
        _canvas = new CanvasElement(width: canvasWidth, height: canvasHeight);
        _context = _canvas.context2D;
      }

      if (_canvas.width != canvasWidth) _canvas.width = canvasWidth;
      if (_canvas.height != canvasHeight) _canvas.height = canvasHeight;

      //-----------------------------
      // set canvas context

      var fontStyleBuffer = new StringBuffer()
        ..write(_defaultTextFormat.italic ? "italic " : "normal ")
        ..write("normal ")
        ..write(_defaultTextFormat.bold ? "bold " : "normal ")
        ..write("${_defaultTextFormat.size}px ")
        ..write("${_defaultTextFormat.font},sans-serif");

      var fontStyle = fontStyleBuffer.toString();

      _context.font = fontStyle;
      _context.textAlign = "start";
      _context.textBaseline = "alphabetic";
      _context.fillStyle = _color2rgb(_textColor);
      _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

      //-----------------------------
      // split text into lines

      _processTextLines(fontStyle);

      //-----------------------------
      // draw background

      _context.setTransform(ratio, 0.0, 0.0, ratio, 0.0, 0.0);

      if (_background) {
        _context.fillStyle = _color2rgb(_backgroundColor);
        _context.fillRect(0, 0, _width, _height);
      } else {
        _context.clearRect(0, 0, _width, _height);
      }

      //-----------------------------
      // draw text

      num offsetY = _defaultTextFormat.topMargin + _defaultTextFormat.size;

      for(int i = 0; i < _linesText.length; i++) {
        var metrics = _linesMetrics[i];
        _context.fillStyle = _color2rgb(_textColor);
        _context.fillText(_linesText[i], metrics.x, offsetY);

        offsetY += metrics.height;
      }

      //-----------------------------
      // draw border

      if (_border) {
        _context.strokeStyle = _color2rgb(_borderColor);
        _context.lineWidth = 1;
        _context.strokeRect(0, 0, _width, _height);
      }
    }
  }

}
