part of stagexl;

class TextField extends InteractiveObject {

  String _text = "";
  TextFormat _defaultTextFormat = null;

  String _autoSize = TextFieldAutoSize.NONE;
  String _gridFitType = GridFitType.PIXEL;
  String _type = TextFieldType.DYNAMIC;

  int _caretIndex = 0;
  int _caretLine = 0;
  num _caretTime = 0.0;
  num _caretX = 0.0;
  num _caretY = 0.0;
  num _caretWidth = 0.0;
  num _caretHeight = 0.0;

  bool _wordWrap = false;
  bool _multiline = false;
  bool _background = false;
  int _backgroundColor = 0x000000;
  bool _border = false;
  int _borderColor = 0x000000;
  num _width = 100;
  num _height = 100;

  num _textWidth = 0;
  num _textHeight = 0;
  List<TextLineMetrics> _textLineMetrics;

  bool _refreshPending = true;
  CanvasElement _canvas = null;
  CanvasRenderingContext2D _context = null;

  //-------------------------------------------------------------------------------------------------

  TextField([String text, TextFormat textFormat]) {

    _text = (text != null) ? text : "";
    _defaultTextFormat = (textFormat != null) ? textFormat : new TextFormat("Arial", 12, 0x000000);
    _textLineMetrics = new List<TextLineMetrics>();
    _refreshPending = true;

    this.onKeyDown.listen(_onKeyDown);
    this.onTextInput.listen(_onTextInput);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String get text => _text;
  int get textColor => _defaultTextFormat.color;
  TextFormat get defaultTextFormat => _defaultTextFormat;

  int get caretIndex => _caretIndex;

  String get autoSize => _autoSize;
  String get gridFitType => _gridFitType;
  String get type => _type;
  bool get wordWrap => _wordWrap;
  bool get multiline => _multiline;

  bool get background => _background;
  int get backgroundColor => _backgroundColor;
  bool get border => _border;
  int get borderColor => _borderColor;
  num get width => _width;
  num get height => _height;

  //-------------------------------------------------------------------------------------------------

  void set text(String value) {
    _text = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    _caretIndex = _text.length;
    _refreshPending = true;
  }

  void set textColor(int value) {
    _defaultTextFormat.color = value;
    _refreshPending = true;
  }

  void set defaultTextFormat(TextFormat value) {
    _defaultTextFormat = value.clone();
    _refreshPending = true;
  }

  void set autoSize(String value) {
    _autoSize = value;
    _refreshPending = true;
  }

  void set gridFitType(String value) {
    _gridFitType = value;
    _refreshPending = true;
  }

  void set type(String value) {
    _type = value;
    _refreshPending = true;
  }

  void set wordWrap(bool value) {
    _wordWrap = value;
    _refreshPending = true;
  }

  void set multiline(bool value) {
    _multiline = value;
    _refreshPending = true;
  }

  void set background(bool value) {
    _background = value;
    _refreshPending = true;
  }

  void set backgroundColor(int value) {
    _backgroundColor = value;
    _refreshPending = true;
  }

  void set border(bool value) {
    _border = value;
    _refreshPending = true;
  }

  void set borderColor(int value) {
    _borderColor = value;
    _refreshPending = true;
  }

  void set width(num value) {
    _width = value.toDouble();
    _refreshPending = true;
  }

  void set height(num value) {
    _height = value.toDouble();
    _refreshPending = true;
  }

  //-------------------------------------------------------------------------------------------------

  num get textWidth {
    _refresh();
    return _textWidth;
  }

  num get textHeight {
    _refresh();
    return _textHeight;
  }

  int get numLines {
    _refresh();
    return _textLineMetrics.length;
  }

  TextLineMetrics getLineMetrics(int lineIndex) {
    _refresh();
    return _textLineMetrics[lineIndex];
  }

  String getLineText(int lineIndex) {
    return getLineMetrics(lineIndex)._text;
  }

  int getLineLength(int lineIndex) {
    return getLineMetrics(lineIndex)._text.length;
  }

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

    _refresh();
    _caretTime += renderState.deltaTime;

    var renderContext = renderState._context;
    renderContext.drawImageScaled(_canvas, 0.0, 0.0, _width, _height);

    if (_type == TextFieldType.INPUT) {
      var stage = this.stage;
      if (stage != null && stage.focus == this && _caretTime.remainder(0.8) < 0.4) {
        renderContext.fillStyle = _color2rgb(_defaultTextFormat.color);
        renderContext.fillRect(_caretX, _caretY, _caretWidth, _caretHeight);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _refreshTextLineMetrics(_FontStyleMetrics fontStyleMetrics) {

    _textLineMetrics.clear();

    //-----------------------------
    // split lines

    var startIndex = 0;
    var checkLine = '';
    var validLine = '';
    var lineWidth = 0;

    for(var paragraph in _text.split('\n')) {

      if (_wordWrap == false) {

        _textLineMetrics.add(new TextLineMetrics._internal(paragraph, startIndex));
        startIndex += paragraph.length + 1;

      } else {

        checkLine = null;

        for(var word in paragraph.split(' ')) {

          validLine = checkLine;
          checkLine = (validLine == null) ? word : validLine + ' ' + word;
          lineWidth = _context.measureText(checkLine).width.toDouble();

          if (lineWidth >= _width) {
            if (validLine == null) {
              _textLineMetrics.add(new TextLineMetrics._internal(checkLine, startIndex));
              startIndex += checkLine.length + 1;
              checkLine = null;
            } else {
              _textLineMetrics.add(new TextLineMetrics._internal(validLine, startIndex));
              startIndex += validLine.length + 1;
              checkLine = word;
            }
          }
        }

        if (checkLine != null) {
          _textLineMetrics.add(new TextLineMetrics._internal(checkLine, startIndex));
          startIndex += checkLine.length + 1;
        }
      }
    }

    //-----------------------------
    // calculate metrics

    _textWidth = 0;
    _textHeight = 0;

    var offsetX = 0.0;
    var offsetY = _defaultTextFormat.topMargin + _defaultTextFormat.size;

    for(var textLineMetrics in _textLineMetrics) {
      var width = _context.measureText(textLineMetrics._text).width.toDouble();
      var align = _defaultTextFormat.align;

      if (align == TextFormatAlign.CENTER || align == TextFormatAlign.JUSTIFY) {
        offsetX = (_width - width) / 2;
      } else  if (align == TextFormatAlign.RIGHT || align == TextFormatAlign.END) {
        offsetX = (_width - width);
      } else {
        offsetX = 0;
      }

      textLineMetrics._x = offsetX;
      textLineMetrics._y = offsetY;
      textLineMetrics._width = width;
      textLineMetrics._height = _defaultTextFormat.size;
      textLineMetrics._ascent = fontStyleMetrics.ascent;
      textLineMetrics._descent = fontStyleMetrics.descent;
      textLineMetrics._leading = 0;

      offsetY = offsetY + _defaultTextFormat.size;

      _textWidth = max(_textWidth, textLineMetrics._width);
      _textHeight = _textHeight + textLineMetrics._height;
    }

    //-----------------------------
    // calculate caret position

    if (_type == TextFieldType.INPUT) {

      for(int line = _textLineMetrics.length - 1; line >= 0; line--) {
        var textLineMetrics = _textLineMetrics[line];

        if (_caretIndex >= textLineMetrics._textIndex) {
          var textIndex = _caretIndex - textLineMetrics._textIndex;
          var text = textLineMetrics._text.substring(0, textIndex);
          _caretLine = line;
          _caretX = (textLineMetrics._x + _context.measureText(text).width).toDouble();
          _caretY = (textLineMetrics._y - fontStyleMetrics.ascent * 0.9).toDouble();
          _caretWidth = 1;
          _caretHeight = _defaultTextFormat.size;
          break;
        }
      }

      var shiftX = 0.0;
      var shiftY = 0.0;

      while (shiftX + _caretX > _width) shiftX -= _width * 0.2;
      while (shiftX + _caretX < 0) shiftX += _width * 0.2;
      while (shiftY + _caretY + _caretHeight > _height) shiftY -= _defaultTextFormat.size;
      while (shiftY + _caretY < 0) shiftY += _defaultTextFormat.size;

      _caretX += shiftX;
      _caretY += shiftY;

      for(int i = 0; i < _textLineMetrics.length; i++) {
        var tlm = _textLineMetrics[i];
        tlm._x += shiftX;
        tlm._y += shiftY;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  _refresh({bool calculateOnly:false}) {

    if (_refreshPending) {

      _refreshPending = false;

      var pixelRatio = (Stage.autoHiDpi ? _devicePixelRatio : 1.0) / _backingStorePixelRatio;
      var canvasWidth = (_width * pixelRatio).ceil();
      var canvasHeight =  (_height * pixelRatio).ceil();

      if (_canvas == null) {
        _canvas = new CanvasElement(width: canvasWidth, height: canvasHeight);
        _context = _canvas.context2D;
      }

      if (_canvas.width != canvasWidth) _canvas.width = canvasWidth;
      if (_canvas.height != canvasHeight) _canvas.height = canvasHeight;

      //-------------------------------------
      // set canvas context

      var fontStyleBuffer = new StringBuffer()
      ..write(_defaultTextFormat.italic ? "italic " : "normal ")
      ..write("normal ")
      ..write(_defaultTextFormat.bold ? "bold " : "normal ")
      ..write("${_defaultTextFormat.size}px ")
      ..write("${_defaultTextFormat.font},sans-serif");

      var fontStyle = fontStyleBuffer.toString();
      var fontStyleMetrics = _getFontStyleMetrics(fontStyle);

      _context.font = fontStyle;
      _context.textAlign = "start";
      _context.textBaseline = "alphabetic";
      _context.fillStyle = _color2rgb(_defaultTextFormat.color);

      //-------------------------------------
      // refresh TextLineMetrics

      _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

      _refreshTextLineMetrics(fontStyleMetrics);

      if (calculateOnly) {
        _refreshPending = true;
        return;
      }

      //-------------------------------------
      // draw background, text, border

      _context.setTransform(pixelRatio, 0.0, 0.0, pixelRatio, 0.0, 0.0);

      if (_background) {
        _context.fillStyle = _color2rgb(_backgroundColor);
        _context.fillRect(0, 0, _width, _height);
      } else {
        _context.clearRect(0, 0, _width, _height);
      }

      _context.fillStyle = _color2rgb(_defaultTextFormat.color);

      for(int i = 0; i < _textLineMetrics.length; i++) {
        var lm = _textLineMetrics[i];
        _context.fillText(lm._text, lm._x, lm._y);
      }

      if (_border) {
        _context.strokeStyle = _color2rgb(_borderColor);
        _context.lineWidth = 1;
        _context.strokeRect(0, 0, _width, _height);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _onKeyDown(KeyboardEvent keyboardEvent) {

    if (_type == TextFieldType.INPUT) {

      _refresh(calculateOnly:true);

      var text = _text;
      var textLength = text.length;
      var textLineMetrics = _textLineMetrics;
      var caretIndex = _caretIndex;
      var caretLine = _caretLine;
      var caretIndexNew = -1;
      var keyCode = keyboardEvent.keyCode;

      switch(keyboardEvent.keyCode) {

        case 8: // backspace
          if (caretIndex > 0) {
            _text = text.substring(0, caretIndex - 1) + text.substring(caretIndex);
            caretIndexNew = caretIndex - 1;
          }
          break;

        case 35:  // end
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex + tlm._text.length;
          break;

        case 36:  // home
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex;
          break;

        case 37: // arrow left
          if (caretIndex > 0) {
            caretIndexNew = caretIndex - 1;
          }
          break;

        case 38: // arrow up
          if (caretLine > 0 && caretLine < textLineMetrics.length) {
            var tlmFrom = textLineMetrics[caretLine ];
            var tlmTo = textLineMetrics[caretLine - 1];
            var lineIndex = min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
            caretIndexNew = tlmTo._textIndex + lineIndex;
          } else {
            caretIndexNew = 0;
          }
          break;

        case 39: // arrow right
          if (caretIndex < textLength) {
            caretIndexNew = caretIndex + 1;
          }
          break;

        case 40: // arrow down
          if (caretLine >= 0 && caretLine < textLineMetrics.length - 1) {
            var tlmFrom = textLineMetrics[caretLine ];
            var tlmTo = textLineMetrics[caretLine + 1];
            var lineIndex = min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
            caretIndexNew = tlmTo._textIndex + lineIndex;
          } else {
            caretIndexNew = textLength;
          }
          break;

        case 46: // delete
          if (caretIndex < textLength) {
            _text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
            caretIndexNew = caretIndex;
          }
          break;
      }

      if (caretIndexNew != -1) {
        _caretIndex = caretIndexNew;
        _caretTime = 0.0;
        _refreshPending = true;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onTextInput(TextEvent textEvent) {

    if (_type == TextFieldType.INPUT) {

      var textLength = _text.length;
      var caretIndex = _caretIndex;
      var newText = textEvent.text;

      if (newText == '\r') newText = '\n';
      if (newText == '\n' && _multiline == false) newText = '';
      if (newText != '') {
        _text = _text.substring(0, caretIndex) + newText + _text.substring(caretIndex);
        _caretIndex = _caretIndex + newText.length;
        _caretTime = 0.0;
        _refreshPending = true;
      }
    }
  }


}
