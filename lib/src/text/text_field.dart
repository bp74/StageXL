part of stagexl.text;

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
  int _backgroundColor = 0xFFFFFF;
  int _borderColor = 0x000000;
  int _maxChars = 0;
  num _width = 100;
  num _height = 100;

  num _textWidth = 0.0;
  num _textHeight = 0.0;
  final List<TextLineMetrics> _textLineMetrics = new List<TextLineMetrics>();

  int _refreshPending = 3;   // bit 0: textLineMetrics, bit 1: cache
  bool _cacheAsBitmap = true;

  RenderTexture _renderTexture;
  RenderTextureQuad _renderTextureQuad;

  //-------------------------------------------------------------------------------------------------

  TextField([String text, TextFormat textFormat]) {

    this.text = (text != null) ? text : "";
    this.defaultTextFormat = (textFormat != null) ? textFormat : new TextFormat("Arial", 12, 0x000000);

    this.onKeyDown.listen(_onKeyDown);
    this.onTextInput.listen(_onTextInput);
    this.onMouseDown.listen(_onMouseDown);
  }

  //-------------------------------------------------------------------------------------------------

  RenderTexture get renderTexture => _renderTexture;

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
  bool get cacheAsBitmap => _cacheAsBitmap;

  String get passwordChar => _passwordChar;
  int get backgroundColor => _backgroundColor;
  int get borderColor => _borderColor;
  int get maxChars => _maxChars;

  String get mouseCursor => (type == TextFieldType.INPUT) ? MouseCursor.TEXT : super.mouseCursor;

  //-------------------------------------------------------------------------------------------------

  void set width(num value) {
    _width = value.toDouble();
    _refreshPending |= 3;
  }

  void set height(num value) {
    _height = value.toDouble();
    _refreshPending |= 3;
  }

  void set text(String value) {
    _text = value;
    _caretIndex = _text.length;
    _refreshPending |= 3;
  }

  void set textColor(int value) {
    _defaultTextFormat.color = value;
    _refreshPending |= 2;
  }

  void set defaultTextFormat(TextFormat value) {
    _defaultTextFormat = value.clone();
    _refreshPending |= 3;
  }

  void set autoSize(String value) {
    _autoSize = value;
    _refreshPending |= 3;
  }

  void set type(String value) {
    _type = value;
    _refreshPending |= 3;
  }

  void set wordWrap(bool value) {
    _wordWrap = value;
    _refreshPending |= 3;
  }

  void set multiline(bool value) {
    _multiline = value;
    _refreshPending |= 3;
  }

  void set displayAsPassword(bool value) {
    _displayAsPassword = value;
    _refreshPending |= 3;
  }

  void set passwordChar(String value) {
    _passwordChar = value[0];
    _refreshPending |= 3;
  }

  void set background(bool value) {
    _background = value;
    _refreshPending |= 2;
  }

  void set backgroundColor(int value) {
    _backgroundColor = value;
    _refreshPending |= 2;
  }

  void set border(bool value) {
    _border = value;
    _refreshPending |= 2;
  }

  void set borderColor(int value) {
    _borderColor = value;
    _refreshPending |= 2;
  }

  void set maxChars(int value) {
    _maxChars = value;
  }

  void set cacheAsBitmap(bool value) {
    if (value) _refreshPending |= 2;
    _cacheAsBitmap = value;
  }

  //-------------------------------------------------------------------------------------------------

  num get x {
    _refreshTextLineMetrics();
    return super.x;
  }

  num get width {
    _refreshTextLineMetrics();
    return _width;
  }

  num get height {
    _refreshTextLineMetrics();
    return _height;
  }

  num get textWidth {
    _refreshTextLineMetrics();
    return _textWidth;
  }

  num get textHeight {
    _refreshTextLineMetrics();
    return _textHeight;
  }

  int get numLines {
    _refreshTextLineMetrics();
    return _textLineMetrics.length;
  }

  TextLineMetrics getLineMetrics(int lineIndex) {
    _refreshTextLineMetrics();
    return _textLineMetrics[lineIndex];
  }

  String getLineText(int lineIndex) {
    return getLineMetrics(lineIndex)._text;
  }

  int getLineLength(int lineIndex) {
    return getLineText(lineIndex).length;
  }

  Matrix get transformationMatrix {
    _refreshTextLineMetrics();
    return super.transformationMatrix;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, width, height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (localX < 0 || localX >= width) return null;
    if (localY < 0 || localY >= height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {

    _refreshTextLineMetrics();

    if (renderState.renderContext is RenderContextWebGL || _cacheAsBitmap ) {
      _refreshCache(renderState.globalMatrix);
      renderState.renderQuad(_renderTextureQuad);
    } else if (renderState.renderContext is RenderContextCanvas) {
      RenderContextCanvas renderContextCanvas = renderState.renderContext;
      renderContextCanvas.setTransform(renderState.globalMatrix);
      renderContextCanvas.setAlpha(renderState.globalAlpha);
      _renderText(renderContextCanvas.rawContext);
    }

    // draw cursor for INPUT text fields

    _caretTime += renderState.deltaTime;

    if (_type == TextFieldType.INPUT) {
      var stage = this.stage;
      if (stage != null && stage.focus == this && _caretTime.remainder(0.8) < 0.4) {
        var x1 = _caretX;
        var y1 = _caretY;
        var x3 = _caretX + _caretWidth;
        var y3 = _caretY + _caretHeight;
        var color = _defaultTextFormat.color;
        renderState.renderTriangle(x1, y1, x3, y1, x3, y3, color);
        renderState.renderTriangle(x1, y1, x3, y3, x1, y3, color);
      }
    }
  }

  @override
  void renderFiltered(RenderState renderState) {

    if (_type == TextFieldType.INPUT) {
      super.renderFiltered(renderState);
    } if (renderState.renderContext is RenderContextWebGL || _cacheAsBitmap) {
      _refreshTextLineMetrics();
      _refreshCache(renderState.globalMatrix);
      renderState.renderQuadFiltered(_renderTextureQuad, this.filters);
    } else {
      super.renderFiltered(renderState);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _refreshTextLineMetrics() {

    if ((_refreshPending & 1) == 0) {
      return;
    } else {
      _refreshPending &= 255 - 1;
    }

    _textLineMetrics.clear();

    //-----------------------------------
    // split lines

    var startIndex = 0;
    var checkLine = '';
    var validLine = '';
    var lineWidth = 0;
    var lineIndent = 0;

    var textFormat = _defaultTextFormat;
    var textFormatSize = ensureNum(textFormat.size);
    num textFormatStrokeWidth = ensureNum(textFormat.strokeWidth);
    var textFormatLeftMargin = ensureNum(textFormat.leftMargin);
    var textFormatRightMargin = ensureNum(textFormat.rightMargin);
    var textFormatTopMargin = ensureNum(textFormat.topMargin);
    var textFormatBottomMargin = ensureNum(textFormat.bottomMargin);
    var textFormatIndent = ensureNum(textFormat.indent);
    var textFormatLeading = ensureNum(textFormat.leading);
    var textFormatAlign = ensureString(textFormat.align);

    var fontStyle = textFormat._cssFontStyle;
    var fontStyleMetrics = _getFontStyleMetrics(textFormat);
    var fontStyleMetricsAscent = ensureNum(fontStyleMetrics.ascent);
    var fontStyleMetricsDescent = ensureNum(fontStyleMetrics.descent);

    var availableWidth = _width - textFormatLeftMargin - textFormatRightMargin;
    var canvasContext = _dummyCanvasContext;
    var paragraphLines = new List<int>();
    var paragraphSplit = new RegExp(r"\r\n|\r|\n");
    var paragraphs = _text.split(paragraphSplit);

    canvasContext.font = fontStyle + " "; // IE workaround
    canvasContext.textAlign = "start";
    canvasContext.textBaseline = "alphabetic";
    canvasContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

    for(int p = 0; p < paragraphs.length; p++) {

      var paragraph = paragraphs[p];
      if (paragraph is! String) continue; // dart2js_hint

      paragraphLines.add(_textLineMetrics.length);

      if (_wordWrap == false) {

        paragraph = _passwordEncoder(paragraph);
        _textLineMetrics.add(new TextLineMetrics._internal(paragraph, startIndex));
        startIndex += paragraph.length + 1;

      } else {

        checkLine = null;
        lineIndent = textFormatIndent;

        var words = paragraph.split(' ');

        for(int w = 0; w < words.length; w++) {

          var word = words[w];
          if (word is! String) continue; // dart2js_hint

          validLine = checkLine;
          checkLine = (validLine == null) ? word : "$validLine $word";
          checkLine = _passwordEncoder(checkLine);
          lineWidth = canvasContext.measureText(checkLine).width.toDouble();

          if (lineIndent + lineWidth >= availableWidth) {
            if (validLine == null) {
              _textLineMetrics.add(new TextLineMetrics._internal(checkLine, startIndex));
              startIndex += checkLine.length + 1;
              checkLine = null;
              lineIndent = 0;
            } else {
              _textLineMetrics.add(new TextLineMetrics._internal(validLine, startIndex));
              startIndex += validLine.length + 1;
              checkLine = _passwordEncoder(word);
              lineIndent = 0;
            }
          }
        }

        if (checkLine != null) {
          _textLineMetrics.add(new TextLineMetrics._internal(checkLine, startIndex));
          startIndex += checkLine.length + 1;
        }
      }
    }

    //-----------------------------------
    // calculate metrics

    _textWidth = 0.0;
    _textHeight = 0.0;

    for(int line = 0; line < _textLineMetrics.length; line++) {

      var textLineMetrics = _textLineMetrics[line];
      if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

      var indent = paragraphLines.contains(line) ? textFormatIndent : 0;
      var offsetX = textFormatLeftMargin + indent;
      var offsetY = textFormatTopMargin + textFormatSize +
                    line * (textFormatLeading + textFormatSize + fontStyleMetricsDescent);

      var width = canvasContext.measureText(textLineMetrics._text).width.toDouble();

      textLineMetrics._x = offsetX;
      textLineMetrics._y = offsetY;
      textLineMetrics._width = width;
      textLineMetrics._height = textFormatSize;
      textLineMetrics._ascent = fontStyleMetricsAscent;
      textLineMetrics._descent = fontStyleMetricsDescent;
      textLineMetrics._leading = textFormatLeading;
      textLineMetrics._indent = indent;

      _textWidth = max(_textWidth, textFormatLeftMargin + indent + width + textFormatRightMargin);
      _textHeight = offsetY + fontStyleMetricsDescent + textFormatBottomMargin;
    }

    _textWidth += textFormatStrokeWidth * 2;
    _textHeight += textFormatStrokeWidth * 2;

    //-----------------------------------
    // calculate TextField autoSize

    var autoWidth = _wordWrap ? _width : _textWidth.ceil();
    var autoHeight = _textHeight.ceil();

    if (_width != autoWidth || _height != autoHeight) {

      switch(_autoSize) {
        case TextFieldAutoSize.LEFT:
          _width = autoWidth;
          _height = autoHeight;
          break;
        case TextFieldAutoSize.RIGHT:
          super.x -= (autoWidth - _width);
          _width = autoWidth;
          _height = autoHeight;
          break;
        case TextFieldAutoSize.CENTER:
          super.x -= (autoWidth - _width) / 2;
          _width = autoWidth;
          _height = autoHeight;
          break;
      }
    }

    availableWidth = _width - textFormatLeftMargin - textFormatRightMargin;

    //-----------------------------------
    // calculate TextFormat align

    for(int line = 0; line < _textLineMetrics.length; line++) {

      var textLineMetrics = _textLineMetrics[line];
      if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

      switch(textFormatAlign) {
        case TextFormatAlign.CENTER:
        case TextFormatAlign.JUSTIFY:
          textLineMetrics._x += (availableWidth - textLineMetrics.width) / 2;
          break;
        case TextFormatAlign.RIGHT:
        case TextFormatAlign.END:
          textLineMetrics._x += (availableWidth - textLineMetrics.width);
          break;
        default:
          textLineMetrics._x += textFormatStrokeWidth;
      }

      textLineMetrics._y += textFormatStrokeWidth;
    }

    //-----------------------------------
    // calculate caret position

    if (_type == TextFieldType.INPUT) {

      for(int line = _textLineMetrics.length - 1; line >= 0; line--) {

        var textLineMetrics = _textLineMetrics[line];
        if (textLineMetrics is! TextLineMetrics) continue; // dart2js_hint

        if (_caretIndex >= textLineMetrics._textIndex) {
          var textIndex = _caretIndex - textLineMetrics._textIndex;
          var text = textLineMetrics._text.substring(0, textIndex);
          _caretLine = line;
          _caretX = textLineMetrics.x + canvasContext.measureText(text).width.toDouble();
          _caretY = textLineMetrics.y - fontStyleMetricsAscent * 0.9;
          _caretWidth = 2.0;
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

  _refreshCache(Matrix globalMatrix) {

    if ((_refreshPending & 2) == 0) {
      return;
    } else {
      _refreshPending &= 255 - 2;
    }

    var pixelRatio = sqrt(globalMatrix.det.abs());
    var width = max(1, _width * pixelRatio).ceil();
    var height =  max(1, _height * pixelRatio).ceil();

    if (_renderTexture == null) {
      _renderTexture = new RenderTexture(width, height, Color.Transparent);
      _renderTextureQuad = _renderTexture.quad.withPixelRatio(pixelRatio);
    } else {
      _renderTexture.resize(width, height);
      _renderTextureQuad = _renderTexture.quad.withPixelRatio(pixelRatio);
    }

    var matrix = _renderTextureQuad.drawMatrix;
    var context = _renderTexture.canvas.context2D;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.clearRect(0, 0, _width, _height);

    _renderText(context);
    _renderTexture.update();
  }

  //-------------------------------------------------------------------------------------------------

  _renderText(CanvasRenderingContext2D context) {

    var textFormat = _defaultTextFormat;
    var lineWidth = (textFormat.bold ? textFormat.size / 10 : textFormat.size / 20).ceil();

    context.save();
    context.beginPath();
    context.rect(0, 0, _width, _height);
    context.clip();

    context.font = textFormat._cssFontStyle + " "; // IE workaround
    context.textAlign = "start";
    context.textBaseline = "alphabetic";
    context.lineCap = "round";
    context.lineJoin = "round";

    if (_background) {
      context.fillStyle = color2rgb(_backgroundColor);
      context.fillRect(0, 0, _width, _height);
    }

    if(textFormat.strokeWidth > 0) {
      context.lineWidth = textFormat.strokeWidth * 2;
      context.strokeStyle = color2rgb(textFormat.strokeColor);
      for(int i = 0; i < _textLineMetrics.length; i++) {
        var lm = _textLineMetrics[i];
        context.strokeText(lm._text, lm.x, lm.y);
      }
    }

    context.lineWidth = lineWidth;
    context.strokeStyle = color2rgb(textFormat.color);
    context.fillStyle = textFormat.fillGradient != null
        ? textFormat.fillGradient.getCanvasGradient(context)
        : color2rgb(textFormat.color);

    for(int i = 0; i < _textLineMetrics.length; i++) {
      var lm = _textLineMetrics[i];
      context.fillText(lm._text, lm.x, lm.y);
      if(textFormat.underline) {
        num underlineY = (lm.y + lineWidth).round();
        if (lineWidth % 2 != 0) underlineY += 0.5;
        context.beginPath();
        context.moveTo(lm.x, underlineY);
        context.lineTo(lm.x + lm.width, underlineY);
        context.stroke();
      }
    }

    if (_border) {
      context.strokeStyle = color2rgb(_borderColor);
      context.lineWidth = 1;
      context.strokeRect(0, 0, _width, _height);
    }

    context.restore();
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
  //-------------------------------------------------------------------------------------------------

  _onKeyDown(KeyboardEvent keyboardEvent) {

    if (_type == TextFieldType.INPUT) {

      _refreshTextLineMetrics();

      var text = _text;
      var textLength = text.length;
      var textLineMetrics = _textLineMetrics;
      var caretIndex = _caretIndex;
      var caretLine = _caretLine;
      var caretIndexNew = -1;

      switch(keyboardEvent.keyCode) {

        case html.KeyCode.BACKSPACE:
          keyboardEvent.preventDefault();
          if (caretIndex > 0) {
            _text = text.substring(0, caretIndex - 1) + text.substring(caretIndex);
            caretIndexNew = caretIndex - 1;
          }
          break;

        case html.KeyCode.END:
          keyboardEvent.preventDefault();
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex + tlm._text.length;
          break;

        case html.KeyCode.HOME:
          keyboardEvent.preventDefault();
          var tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex;
          break;

        case html.KeyCode.LEFT:
          keyboardEvent.preventDefault();
          if (caretIndex > 0) {
            caretIndexNew = caretIndex - 1;
          }
          break;

        case html.KeyCode.UP:
          keyboardEvent.preventDefault();
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
          keyboardEvent.preventDefault();
          if (caretIndex < textLength) {
            caretIndexNew = caretIndex + 1;
          }
          break;

        case html.KeyCode.DOWN:
          keyboardEvent.preventDefault();
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
          keyboardEvent.preventDefault();
          if (caretIndex < textLength) {
            _text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
            caretIndexNew = caretIndex;
          }
          break;
      }

      if (caretIndexNew != -1) {
        _caretIndex = caretIndexNew;
        _caretTime = 0.0;
        _refreshPending |= 3;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onTextInput(TextEvent textEvent) {

    if (_type == TextFieldType.INPUT) {

      textEvent.preventDefault();

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
      _refreshPending |= 3;
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onMouseDown(MouseEvent mouseEvent) {

    var mouseX = mouseEvent.localX.toDouble();
    var mouseY = mouseEvent.localY.toDouble();
    var canvasContext = _dummyCanvasContext;

    canvasContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

    for(int line = 0; line < _textLineMetrics.length; line++) {

      var textLineMetrics = _textLineMetrics[line];
      if (textLineMetrics is! TextLineMetrics) continue;  // dart2js_hint

      var text = textLineMetrics._text;
      var lineX = textLineMetrics.x;
      var lineY1 = textLineMetrics.y - textLineMetrics.ascent;
      var lineY2 = textLineMetrics.y + textLineMetrics.descent;

      if (lineY1 <= mouseY && lineY2 >= mouseY) {
        var bestDistance = double.INFINITY;
        var bestIndex = 0;

        for(var c = 0; c <= text.length; c++) {
          var width = canvasContext.measureText(text.substring(0, c)).width.toDouble();
          var distance = (lineX + width - mouseX).abs();
          if (distance < bestDistance) {
            bestDistance = distance;
            bestIndex = c;
          }
        }

        _caretIndex = textLineMetrics._textIndex + bestIndex;
        _caretTime = 0.0;
        _refreshPending |= 3;
      }
    }
  }
}
