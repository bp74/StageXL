part of dartflash;

class TextField extends InteractiveObject
{
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

  num _textWidth = 0;
  num _textHeight = 0;
  List<String> _linesText;
  List<TextLineMetrics> _linesMetrics;

  bool _canvasRefreshPending = true;
  num _canvasWidth = 100;
  num _canvasHeight = 100;
  CanvasElement _canvas = null;
  CanvasRenderingContext2D _context = null;

  //-------------------------------------------------------------------------------------------------

  TextField()
  {
    _defaultTextFormat = new TextFormat("Arial", 12, 0x000000);

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
  num get width => _canvasWidth;
  num get height => _canvasHeight;

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
  void set width(num value) { _canvasWidth = value; _canvasRefreshPending = true; }
  void set height(num value) { _canvasHeight = value; _canvasRefreshPending = true; }

  //-------------------------------------------------------------------------------------------------

  num get textWidth { _canvasRefresh(); return _textWidth; }
  num get textHeight { _canvasRefresh(); return _textHeight; }
  int get numLines { _canvasRefresh(); return _linesText.length; }

  int getLineLength(int lineIndex) { _canvasRefresh(); return _linesText[lineIndex].length; }
  TextLineMetrics getLineMetrics(int lineIndex) { _canvasRefresh(); return _linesMetrics[lineIndex]; }
  String getLineText(int lineIndex) { _canvasRefresh(); return _linesText[lineIndex]; }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle])
  {
    return _getBoundsTransformedHelper(matrix, _canvasWidth, _canvasHeight, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    if (localX >= 0 && localY >= 0 && localX < _canvasWidth && localY < _canvasHeight)
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    _canvasRefresh();

    renderState._context.drawImage(_canvas, 0.0, 0.0);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _processTextLines()
  {
    _linesText.clear();
    _linesMetrics.clear();

    //---------------------------

    if (_wordWrap == false)
    {
      _linesText.add(_text);
    }
    else
    {
      StringBuffer lineBuffer = new StringBuffer();
      int previousLength;
      String line;

      // ToDo: very simple implementation, we can do better ...
      
      for(String paragraph in _text.replaceAll('\r', '').split('\n')) 
      {
        for(String word in paragraph.split(' ')) 
        {
          previousLength = lineBuffer.length;
          lineBuffer.add((previousLength > 0) ? " $word": word);
          line = lineBuffer.toString();
  
          if (_context.measureText(line).width > _canvasWidth)
          {
            if (previousLength > 0) 
              line = line.substring(0, previousLength); 
            else 
              word = "";
  
            _linesText.add(line);
  
            lineBuffer.clear();
            lineBuffer.add(word);
          }
        }
  
        if (lineBuffer.isEmpty == false)
        {
          _linesText.add(lineBuffer.toString());
          lineBuffer.clear();
        }
      }
    }

    //---------------------------

    _textWidth = 0;
    _textHeight = 0;

    for(String line in _linesText)
    {
      var metrics = _context.measureText(line);
      var offsetX = 0;

      if (_defaultTextFormat.align == TextFormatAlign.CENTER || _defaultTextFormat.align == TextFormatAlign.JUSTIFY)
        offsetX = (_canvasWidth - metrics.width) / 2;

      if (_defaultTextFormat.align == TextFormatAlign.RIGHT || _defaultTextFormat.align == TextFormatAlign.END)
        offsetX = _canvasWidth - metrics.width;

      TextLineMetrics textLineMetrics = new TextLineMetrics(offsetX, metrics.width, _defaultTextFormat.size, 0, 0, 0);

      _linesMetrics.add(textLineMetrics);
      _textWidth = max(_textWidth, textLineMetrics.width);
      _textHeight = _textHeight + textLineMetrics.height;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _canvasRefresh()
  {
    if (_canvasRefreshPending)
    {
      _canvasRefreshPending = false;

      int canvasWidthInt = _canvasWidth.ceil().toInt();
      int canvasHeightInt =  _canvasHeight.ceil().toInt();

      if (_canvas == null)
      {
        _canvas = new CanvasElement(width: canvasWidthInt, height: canvasHeightInt);
        _context = _canvas.context2d;
      }

      if (_canvas.width != canvasWidthInt) _canvas.width = canvasWidthInt;
      if (_canvas.height != canvasHeightInt) _canvas.height = canvasHeightInt;

      //-----------------------------
      // set canvas context

      StringBuffer fontStyle = new StringBuffer();

      fontStyle.add(_defaultTextFormat.italic ? "italic " : "normal ");
      fontStyle.add("normal ");
      fontStyle.add(_defaultTextFormat.bold ? "bold " : "normal ");
      fontStyle.add("${_defaultTextFormat.size}px ");
      fontStyle.add("${_defaultTextFormat.font},sans-serif");

      _context.font = fontStyle.toString();
      _context.textAlign = "start";
      _context.textBaseline = "top";
      _context.fillStyle = _color2rgb(_textColor);

      //-----------------------------
      // split text into lines

      _processTextLines();

      //-----------------------------
      // draw background

      if (_background)
      {
        _context.fillStyle = _color2rgb(_backgroundColor);
        _context.fillRect(0, 0, _canvasWidth, _canvasHeight);
      }
      else
      {
        _context.clearRect(0, 0, _canvasWidth, _canvasHeight);
      }

      //-----------------------------
      // draw text

      int offsetY = 0;

      for(int i = 0; i < _linesText.length; i++)
      {
        TextLineMetrics metrics = _linesMetrics[i];

        _context.fillStyle = _color2rgb(_textColor);
        _context.fillText(_linesText[i], metrics.x, offsetY);

        offsetY += metrics.height;
      }

      //-----------------------------
      // draw border

      if (_border)
      {
        _context.strokeStyle = _color2rgb(_borderColor);
        _context.lineWidth = 1;
        _context.strokeRect(0, 0, _canvasWidth, _canvasHeight);
      }
    }
  }



}
