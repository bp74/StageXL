part of stagexl;

class TextField extends InteractiveObject {

  String _text = "";
  TextFormat _defaultTextFormat = null;

  String _autoSize = TextFieldAutoSize.NONE;
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
  bool _displayAsPassword = false;
  bool _background = false;
  bool _border = false;
  String _passwordChar = "•";
  int _backgroundColor = 0x000000;
  int _borderColor = 0x000000;
  int _maxChars = 0;
  num _width = 100;
  num _height = 100;

  num _textWidth = 0.0;
  num _textHeight = 0.0;
  final List<TextLineMetrics> _textLineMetrics = new List<TextLineMetrics>();

  bool _refreshPending = true;
  CanvasElement _canvas = null;
  CanvasRenderingContext2D _context = null;

  //-------------------------------------------------------------------------------------------------

  TextField([String text, TextFormat textFormat]) {

    this.text = (text != null) ? text : "";
    this.defaultTextFormat = (textFormat != null) ? textFormat : new TextFormat("Arial", 12, 0x000000);

    this.onKeyDown.listen(_onKeyDown);
    this.onTextInput.listen(_onTextInput);
    this.onMouseDown.listen(_onMouseDown);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String get text => _text;
  int get textColor => _defaultTextFormat.color;
  TextFormat get defaultTextFormat => _defaultTextFormat;

  int get caretIndex => _caretIndex;

  String get autoSize => _autoSize;
  String get type => _type;

  bool get wordWrap => _wordWrap;
  bool get multiline => _multiline;
  bool get displayAsPassword => _displayAsPassword;
  bool get background => _background;
  bool get border => _border;

  String get passwordChar => _passwordChar;
  int get backgroundColor => _backgroundColor;
  int get borderColor => _borderColor;
  int get maxChars => _maxChars;

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

  void set displayAsPassword(bool value) {
    _displayAsPassword = value;
    _refreshPending = true;
  }

  void set passwordChar(String value) {
    _passwordChar = value[0];
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

  void set maxChars(int value) {
    _maxChars = value;
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
    return getLineText(lineIndex).length;
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
    var textFormatSize = _defaultTextFormat.size.toDouble();
    var textFormatLeftMargin = _defaultTextFormat.leftMargin.toDouble();
    var textFormatTopMargin = _defaultTextFormat.topMargin.toDouble();
    var textFormatAlign = _defaultTextFormat.align.toString();
    var fontStyleMetricsAscent = fontStyleMetrics.ascent.toDouble();
    var fontStyleMetricsDescent = fontStyleMetrics.descent.toDouble();

    for(var paragraph in _text.split('\n')) {

      if (_wordWrap == false) {

        _textLineMetrics.add(new TextLineMetrics._internal(paragraph, startIndex));
        startIndex += paragraph.length + 1;

      } else {

        checkLine = null;

        for(var word in paragraph.split(' ')) {

          validLine = checkLine;
          checkLine = (validLine == null) ? word : "$validLine $word";
          checkLine = _passwordEncoder(checkLine);
          lineWidth = _context.measureText(checkLine).width.toDouble();

          if (lineWidth >= _width) {
            if (validLine == null) {
              _textLineMetrics.add(new TextLineMetrics._internal(checkLine, startIndex));
              startIndex += checkLine.length + 1;
              checkLine = null;
            } else {
              _textLineMetrics.add(new TextLineMetrics._internal(validLine, startIndex));
              startIndex += validLine.length + 1;
              checkLine = _passwordEncoder(word);
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

    _textWidth = 0.0;
    _textHeight = 0.0;

    var offsetX = 0.0;
    var offsetY = textFormatTopMargin + textFormatSize;

    for(int line = 0; line < _textLineMetrics.length; line++) {
      var textLineMetrics = _textLineMetrics[line];
      if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

      var width = _context.measureText(textLineMetrics._text).width.toDouble();

      switch(textFormatAlign) {
        case TextFormatAlign.CENTER:
        case TextFormatAlign.JUSTIFY:
          offsetX = (_width - width) / 2;
          break;
        case TextFormatAlign.RIGHT:
        case TextFormatAlign.END:
          offsetX = (_width - width);
          break;
        default:
          offsetX = textFormatLeftMargin;
      }

      textLineMetrics._x = offsetX;
      textLineMetrics._y = offsetY;
      textLineMetrics._width = width;
      textLineMetrics._height = textFormatSize;
      textLineMetrics._ascent = fontStyleMetricsAscent;
      textLineMetrics._descent = fontStyleMetricsDescent;
      textLineMetrics._leading = 0.0;

      offsetY = offsetY + textFormatSize;

      _textWidth = max(_textWidth, width);
      _textHeight = _textHeight + textFormatSize;
    }

    //-----------------------------
    // calculate caret position

    if (_type == TextFieldType.INPUT) {

      for(int line = _textLineMetrics.length - 1; line >= 0; line--) {
        var textLineMetrics = _textLineMetrics[line];
        if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

        if (_caretIndex >= textLineMetrics._textIndex) {
          var textIndex = _caretIndex - textLineMetrics._textIndex;
          var text = textLineMetrics._text.substring(0, textIndex);
          _caretLine = line;
          _caretX = textLineMetrics._x + _context.measureText(text).width.toDouble();
          _caretY = textLineMetrics._y - fontStyleMetricsAscent * 0.9;
          _caretWidth = 1.0;
          _caretHeight = textFormatSize;
          break;
        }
      }

      var shiftX = 0.0;
      var shiftY = 0.0;

      while (shiftX + _caretX > _width) shiftX -= _width * 0.2;
      while (shiftX + _caretX < 0) shiftX += _width * 0.2;
      while (shiftY + _caretY + _caretHeight > _height) shiftY -= textFormatSize;
      while (shiftY + _caretY < 0) shiftY += textFormatSize;

      _caretX += shiftX;
      _caretY += shiftY;

      for(int line = 0; line < _textLineMetrics.length; line++) {
        var textLineMetrics = _textLineMetrics[line];
        if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

        textLineMetrics._x += shiftX;
        textLineMetrics._y += shiftY;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  String _passwordEncoder(String text) {

    if (text is! String) return text;
    if (_displayAsPassword == false) return text;

    var newText = "";
    for(int i = 0; i < text.length; i++) {
      newText = "$newText$_passwordChar";
    }
    return newText;
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

      var fontStyle = "${_defaultTextFormat.size}px ${_defaultTextFormat.font},sans-serif";
      if (_defaultTextFormat.bold) fontStyle = "bold $fontStyle";
      if (_defaultTextFormat.italic) fontStyle = "italic $fontStyle";

      _context.font = fontStyle;
      _context.textAlign = "start";
      _context.textBaseline = "alphabetic";

      //-------------------------------------
      // refresh TextLineMetrics

      _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

      _refreshTextLineMetrics(_getFontStyleMetrics(fontStyle));

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

      switch(keyboardEvent.keyCode) {

        case html.KeyCode.BACKSPACE:
          if (caretIndex > 0) {
            _text = text.substring(0, caretIndex - 1) + text.substring(caretIndex);
            caretIndexNew = caretIndex - 1;
          }
          break;

        case html.KeyCode.END:
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex + tlm._text.length;
          break;

        case html.KeyCode.HOME:
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex;
          break;

        case html.KeyCode.LEFT:
          if (caretIndex > 0) {
            caretIndexNew = caretIndex - 1;
          }
          break;

        case html.KeyCode.UP:
          if (caretLine > 0 && caretLine < textLineMetrics.length) {
            var tlmFrom = textLineMetrics[caretLine ];
            var tlmTo = textLineMetrics[caretLine - 1];
            var lineIndex = min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
            caretIndexNew = tlmTo._textIndex + lineIndex;
          } else {
            caretIndexNew = 0;
          }
          break;

        case html.KeyCode.RIGHT:
          if (caretIndex < textLength) {
            caretIndexNew = caretIndex + 1;
          }
          break;

        case html.KeyCode.DOWN:
          if (caretLine >= 0 && caretLine < textLineMetrics.length - 1) {
            var tlmFrom = textLineMetrics[caretLine ];
            var tlmTo = textLineMetrics[caretLine + 1];
            var lineIndex = min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
            caretIndexNew = tlmTo._textIndex + lineIndex;
          } else {
            caretIndexNew = textLength;
          }
          break;

        case html.KeyCode.DELETE:
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
      if (newText == '') return;
      if (_maxChars != 0 && textLength >= _maxChars) return;

      _text = _text.substring(0, caretIndex) + newText + _text.substring(caretIndex);
      _caretIndex = _caretIndex + newText.length;
      _caretTime = 0.0;
      _refreshPending = true;
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onMouseDown(MouseEvent mouseEvent) {
    var mouseX = mouseEvent.localX.toDouble();
    var mouseY = mouseEvent.localY.toDouble();

    if (_context == null) return;
    _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

    for(int line = 0; line < _textLineMetrics.length; line++) {
      var textLineMetrics = _textLineMetrics[line];
      if (textLineMetrics is! TextLineMetrics) continue;  // dart2js_hint

      var text = textLineMetrics._text;
      var lineX = textLineMetrics._x;
      var lineY1 = textLineMetrics._y - textLineMetrics._ascent;
      var lineY2 = textLineMetrics._y + textLineMetrics._descent;

      if (lineY1 <= mouseY && lineY2 >= mouseY) {
        var bestDistance = double.INFINITY;
        var bestIndex = 0;

        for(var c = 0; c <= text.length; c++) {
          var width = _context.measureText(text.substring(0, c)).width.toDouble();
          var distance = (lineX + width - mouseX).abs();
          if (distance < bestDistance) {
            bestDistance = distance;
            bestIndex = c;
          }
        }

        _caretIndex = textLineMetrics._textIndex + bestIndex;
        _caretTime = 0.0;
        _refreshPending = true;
      }
    }
  }
}
