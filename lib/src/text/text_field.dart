// ignore_for_file: prefer_interpolation_to_compose_strings, use_string_buffers

part of '../text.dart';

class TextField extends InteractiveObject {
  String _text = '';
  late TextFormat _defaultTextFormat;

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
  String _passwordChar = '•';
  int _backgroundColor = Color.White;
  int _borderColor = Color.Black;
  int maxChars = 0;
  num _width = 100;
  num _height = 100;

  num _textWidth = 0.0;
  num _textHeight = 0.0;
  final List<TextLineMetrics> _textLineMetrics = <TextLineMetrics>[];

  int _refreshPending = 3; // bit 0: textLineMetrics, bit 1: cache
  bool _cacheAsBitmap = true;

  RenderTexture? _renderTexture;
  RenderTextureQuad? _renderTextureQuad;

  //-------------------------------------------------------------------------------------------------

  TextField([String text = '', TextFormat? textFormat]) : _text = text {
    defaultTextFormat = textFormat ?? TextFormat('Arial', 12, 0x000000);

    onKeyDown.listen(_onKeyDown);
    onTextInput.listen(_onTextInput);
    onMouseDown.listen(_onMouseDown);
  }

  //-------------------------------------------------------------------------------------------------

  RenderTexture? get renderTexture => _renderTexture;

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

  //-------------------------------------------------------------------------------------------------

  @override
  set width(num value) {
    _width = value.toDouble();
    _refreshPending |= 3;
  }

  @override
  set height(num value) {
    _height = value.toDouble();
    _refreshPending |= 3;
  }

  set text(String value) {
    _text = value;
    _caretIndex = _text.length;
    _refreshPending |= 3;
  }

  set textColor(int value) {
    _defaultTextFormat.color = value;
    _refreshPending |= 2;
  }

  set defaultTextFormat(TextFormat value) {
    _defaultTextFormat = value.clone();
    _refreshPending |= 3;
  }

  set autoSize(String value) {
    _autoSize = value;
    _refreshPending |= 3;
  }

  set type(String value) {
    _type = value;
    _refreshPending |= 3;
  }

  set wordWrap(bool value) {
    _wordWrap = value;
    _refreshPending |= 3;
  }

  set multiline(bool value) {
    _multiline = value;
    _refreshPending |= 3;
  }

  set displayAsPassword(bool value) {
    _displayAsPassword = value;
    _refreshPending |= 3;
  }

  set passwordChar(String value) {
    _passwordChar = value[0];
    _refreshPending |= 3;
  }

  set background(bool value) {
    _background = value;
    _refreshPending |= 2;
  }

  set backgroundColor(int value) {
    _backgroundColor = value;
    _refreshPending |= 2;
  }

  set border(bool value) {
    _border = value;
    _refreshPending |= 2;
  }

  set borderColor(int value) {
    _borderColor = value;
    _refreshPending |= 2;
  }

  set cacheAsBitmap(bool value) {
    if (value) _refreshPending |= 2;
    _cacheAsBitmap = value;
  }

  //-------------------------------------------------------------------------------------------------

  @override
  num get x {
    _refreshTextLineMetrics();
    return super.x;
  }

  @override
  num get width {
    _refreshTextLineMetrics();
    return _width;
  }

  @override
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

  String getLineText(int lineIndex) => getLineMetrics(lineIndex)._text;

  int getLineLength(int lineIndex) => getLineText(lineIndex).length;

  @override
  Matrix get transformationMatrix {
    _refreshTextLineMetrics();
    return super.transformationMatrix;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds => Rectangle<num>(0.0, 0.0, width, height);

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    if (localX < 0 || localX >= width) return null;
    if (localY < 0 || localY >= height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    _refreshTextLineMetrics();

    if (renderState.renderContext is RenderContextWebGL || _cacheAsBitmap) {
      _refreshCache(renderState.globalMatrix);
      renderState.renderTextureQuad(_renderTextureQuad!);
    } else if (renderState.renderContext is RenderContextCanvas) {
      final renderContextCanvas =
          renderState.renderContext as RenderContextCanvas;
      renderContextCanvas.setTransform(renderState.globalMatrix);
      renderContextCanvas.setAlpha(renderState.globalAlpha);
      _renderText(renderContextCanvas.rawContext);
    }

    // draw cursor for INPUT text fields

    _caretTime += renderState.deltaTime;

    if (_type == TextFieldType.INPUT) {
      final stage = this.stage;
      if (stage != null &&
          stage.focus == this &&
          _caretTime.remainder(0.8) < 0.4) {
        final x1 = _caretX;
        final y1 = _caretY;
        final x3 = _caretX + _caretWidth;
        final y3 = _caretY + _caretHeight;
        final color = _defaultTextFormat.color;
        renderState.renderTriangle(x1, y1, x3, y1, x3, y3, color);
        renderState.renderTriangle(x1, y1, x3, y3, x1, y3, color);
      }
    }
  }

  @override
  void renderFiltered(RenderState renderState) {
    if (_type == TextFieldType.INPUT) {
      super.renderFiltered(renderState);
    } else if (renderState.renderContext is RenderContextWebGL ||
        _cacheAsBitmap) {
      _refreshTextLineMetrics();
      _refreshCache(renderState.globalMatrix);
      renderState.renderTextureQuadFiltered(_renderTextureQuad!, filters);
    } else {
      super.renderFiltered(renderState);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _refreshTextLineMetrics() {
    if ((_refreshPending & 1) == 0) {
      return;
    } else {
      _refreshPending &= 255 - 1;
    }

    _textLineMetrics.clear();

    //-----------------------------------
    // split lines

    var startIndex = 0;
    String? checkLine = '';
    String? validLine = '';
    var lineWidth = 0.0;
    var lineIndent = 0;

    final textFormat = _defaultTextFormat;
    final textFormatSize = textFormat.size;
    final textFormatStrokeWidth = textFormat.strokeWidth;
    final textFormatLeftMargin = textFormat.leftMargin;
    final textFormatRightMargin = textFormat.rightMargin;
    final textFormatTopMargin = textFormat.topMargin;
    final textFormatBottomMargin = textFormat.bottomMargin;
    final textFormatIndent = textFormat.indent;
    final textFormatLeading = textFormat.leading;
    final textFormatAlign = textFormat.align;
    final textFormatVerticalAlign = textFormat.verticalAlign;

    final fontStyle = textFormat._cssFontStyle;
    final fontStyleMetrics = _getFontStyleMetrics(textFormat);
    final fontStyleMetricsAscent = fontStyleMetrics.ascent;
    final fontStyleMetricsDescent = fontStyleMetrics.descent;

    var availableWidth = _width - textFormatLeftMargin - textFormatRightMargin;
    final canvasContext = _dummyCanvasContext;
    final paragraphLines = <int>[];
    final paragraphSplit = RegExp(r'\r\n|\r|\n');
    final paragraphs = _text.split(paragraphSplit);

    canvasContext.font = fontStyle + ' '; // IE workaround
    canvasContext.textAlign = 'start';
    canvasContext.textBaseline = 'alphabetic';
    canvasContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

    for (var p = 0; p < paragraphs.length; p++) {
      var paragraph = paragraphs[p];
      paragraphLines.add(_textLineMetrics.length);

      if (_wordWrap == false) {
        paragraph = _passwordEncoder(paragraph);
        _textLineMetrics.add(TextLineMetrics._internal(paragraph, startIndex));
        startIndex += paragraph.length + 1;
      } else {
        checkLine = null;
        lineIndent = textFormatIndent.toInt();

        final words = paragraph.split(' ');

        for (var w = 0; w < words.length; w++) {
          final word = words[w];

          validLine = checkLine;
          checkLine = (validLine == null) ? word : '$validLine $word';
          checkLine = _passwordEncoder(checkLine);
          lineWidth = canvasContext.measureText(checkLine).width!.toDouble();

          if (lineIndent + lineWidth >= availableWidth) {
            if (validLine == null) {
              _textLineMetrics
                  .add(TextLineMetrics._internal(checkLine, startIndex));
              startIndex += checkLine.length + 1;
              checkLine = null;
              lineIndent = 0;
            } else {
              _textLineMetrics
                  .add(TextLineMetrics._internal(validLine, startIndex));
              startIndex += validLine.length + 1;
              checkLine = _passwordEncoder(word);
              lineIndent = 0;
            }
          }
        }

        if (checkLine != null) {
          _textLineMetrics
              .add(TextLineMetrics._internal(checkLine, startIndex));
          startIndex += checkLine.length + 1;
        }
      }
    }

    //-----------------------------------
    // calculate metrics

    _textWidth = 0.0;
    _textHeight = 0.0;

    for (var line = 0; line < _textLineMetrics.length; line++) {
      final textLineMetrics = _textLineMetrics[line];

      final indent = paragraphLines.contains(line) ? textFormatIndent : 0;
      final offsetX = textFormatLeftMargin + indent;
      final offsetY = textFormatTopMargin +
          textFormatSize +
          line * (textFormatLeading + textFormatSize + fontStyleMetricsDescent);

      final width =
          canvasContext.measureText(textLineMetrics._text).width!.toDouble();

      textLineMetrics._x = offsetX;
      textLineMetrics._y = offsetY;
      textLineMetrics._width = width;
      textLineMetrics._height = textFormatSize;
      textLineMetrics._ascent = fontStyleMetricsAscent;
      textLineMetrics._descent = fontStyleMetricsDescent;
      textLineMetrics._leading = textFormatLeading;
      textLineMetrics._indent = indent;

      _textWidth = max(_textWidth,
          textFormatLeftMargin + indent + width + textFormatRightMargin);
      _textHeight = offsetY + fontStyleMetricsDescent + textFormatBottomMargin;
    }

    _textWidth += textFormatStrokeWidth * 2;
    _textHeight += textFormatStrokeWidth * 2;

    //-----------------------------------
    // calculate TextField autoSize

    final autoWidth = _wordWrap ? _width : _textWidth.ceil();
    final autoHeight = _textHeight.ceil();

    if (_width != autoWidth || _height != autoHeight) {
      switch (_autoSize) {
        case TextFieldAutoSize.LEFT:
          _width = autoWidth;
          _height = autoHeight;
          break;
        case TextFieldAutoSize.RIGHT:
          super.x -= autoWidth - _width;
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
    // calculate TextFormat verticalAlign

    var heightOffset = textFormatStrokeWidth;
    switch (textFormatVerticalAlign) {
      case TextFormatVerticalAlign.CENTER:
        heightOffset = (_height - _textHeight) / 2;
        break;
      case TextFormatVerticalAlign.BOTTOM:
        heightOffset = _height - _textHeight - textFormatStrokeWidth;
        break;
    }

    //-----------------------------------
    // calculate TextFormat align

    for (var line = 0; line < _textLineMetrics.length; line++) {
      final textLineMetrics = _textLineMetrics[line];

      switch (textFormatAlign) {
        case TextFormatAlign.CENTER:
        case TextFormatAlign.JUSTIFY:
          textLineMetrics._x += (availableWidth - textLineMetrics.width) / 2;
          break;
        case TextFormatAlign.RIGHT:
        case TextFormatAlign.END:
          textLineMetrics._x += availableWidth - textLineMetrics.width;
          break;
        default:
          textLineMetrics._x += textFormatStrokeWidth;
      }

      textLineMetrics._y += heightOffset;
    }

    //-----------------------------------
    // calculate caret position

    if (_type == TextFieldType.INPUT) {
      for (var line = _textLineMetrics.length - 1; line >= 0; line--) {
        final textLineMetrics = _textLineMetrics[line];

        if (_caretIndex >= textLineMetrics._textIndex) {
          final textIndex = _caretIndex - textLineMetrics._textIndex;
          final text = textLineMetrics._text.substring(0, textIndex);
          _caretLine = line;
          _caretX = textLineMetrics.x +
              canvasContext.measureText(text).width!.toDouble();
          _caretY = textLineMetrics.y - fontStyleMetricsAscent * 0.9;
          _caretWidth = 2.0;
          _caretHeight = textFormatSize;
          break;
        }
      }

      var shiftX = 0.0;
      var shiftY = 0.0;

      while (shiftX + _caretX > _width) {
        shiftX -= _width * 0.2;
      }
      while (shiftX + _caretX < 0) {
        shiftX += _width * 0.2;
      }
      while (shiftY + _caretY + _caretHeight > _height) {
        shiftY -= textFormatSize;
      }
      while (shiftY + _caretY < 0) {
        shiftY += textFormatSize;
      }

      _caretX += shiftX;
      _caretY += shiftY;

      for (var line = 0; line < _textLineMetrics.length; line++) {
        final textLineMetrics = _textLineMetrics[line];
        textLineMetrics._x += shiftX;
        textLineMetrics._y += shiftY;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _refreshCache(Matrix globalMatrix) {
    final pixelRatioGlobal = sqrt(globalMatrix.det.abs());
    final pixelRatioCache = _renderTextureQuad?.pixelRatio ?? 0.0;
    if (pixelRatioCache < pixelRatioGlobal * 0.80) _refreshPending |= 2;
    if (pixelRatioCache > pixelRatioGlobal * 1.25) _refreshPending |= 2;
    if ((_refreshPending & 2) == 0) return;

    _refreshPending &= 255 - 2;

    final width = max(1, _width * pixelRatioGlobal).ceil();
    final height = max(1, _height * pixelRatioGlobal).ceil();

    if (_renderTexture == null) {
      _renderTexture = RenderTexture(width, height, Color.Transparent);
      _renderTextureQuad =
          _renderTexture!.quad.withPixelRatio(pixelRatioGlobal);
    } else {
      _renderTexture!.resize(width, height);
      _renderTextureQuad =
          _renderTexture!.quad.withPixelRatio(pixelRatioGlobal);
    }

    final matrix = _renderTextureQuad!.drawMatrix;
    final context = _renderTexture!.canvas.context2D;
    context.setTransform(
        matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.clearRect(0, 0, _width, _height);

    _renderText(context);
    _renderTexture!.update();
  }

  //-------------------------------------------------------------------------------------------------

  void _renderText(CanvasRenderingContext2D context) {
    final textFormat = _defaultTextFormat;
    final lineWidth =
        (textFormat.bold ? textFormat.size / 10 : textFormat.size / 20).ceil();

    context.save();
    context.beginPath();
    context.rect(0, 0, _width, _height);
    context.clip();

    context.font = textFormat._cssFontStyle + ' '; // IE workaround
    context.textAlign = 'start';
    context.textBaseline = 'alphabetic';
    context.lineCap = 'round';
    context.lineJoin = 'round';

    if (_background) {
      context.fillStyle = color2rgba(_backgroundColor);
      context.fillRect(0, 0, _width, _height);
    }

    if (textFormat.strokeWidth > 0) {
      context.lineWidth = textFormat.strokeWidth * 2;
      context.strokeStyle = color2rgb(textFormat.strokeColor);
      for (var i = 0; i < _textLineMetrics.length; i++) {
        final lm = _textLineMetrics[i];
        context.strokeText(lm._text, lm.x, lm.y);
      }
    }

    context.lineWidth = lineWidth;
    context.strokeStyle = color2rgb(textFormat.color);
    context.fillStyle = textFormat.fillGradient != null
        ? _getCanvasGradient(context, textFormat.fillGradient!)
        : color2rgb(textFormat.color);

    for (var i = 0; i < _textLineMetrics.length; i++) {
      final lm = _textLineMetrics[i];
      context.fillText(lm._text, lm.x, lm.y);
      if (textFormat.underline) {
        num underlineY = (lm.y + lineWidth).round();
        if (lineWidth % 2 != 0) underlineY += 0.5;
        context.beginPath();
        context.moveTo(lm.x, underlineY);
        context.lineTo(lm.x + lm.width, underlineY);
        context.stroke();
      }
    }

    if (_border) {
      context.strokeStyle = color2rgba(_borderColor);
      context.lineWidth = 1;
      context.strokeRect(0, 0, _width, _height);
    }

    context.restore();
  }

  //-------------------------------------------------------------------------------------------------

  String _passwordEncoder(String text) {
    if (_displayAsPassword == false) return text;

    var newText = '';
    for (var i = 0; i < text.length; i++) {
      newText = '$newText$_passwordChar';
    }
    return newText;
  }

  //-------------------------------------------------------------------------------------------------

  CanvasGradient _getCanvasGradient(
      CanvasRenderingContext2D context, GraphicsGradient gradient) {
    final sx = gradient.startX;
    final sy = gradient.startY;
    final sr = gradient.startRadius;
    final ex = gradient.endX;
    final ey = gradient.endY;
    final er = gradient.endRadius;

    CanvasGradient canvasGradient;

    switch (gradient.type) {
      case GraphicsGradientType.Linear:
        canvasGradient = context.createLinearGradient(sx, sy, ex, ey);
        break;
      case GraphicsGradientType.Radial:
        canvasGradient = context.createRadialGradient(sx, sy, sr, ex, ey, er);
        break;
    }

    for (var colorStop in gradient.colorStops) {
      final offset = colorStop.offset;
      final color = color2rgba(colorStop.color);
      canvasGradient.addColorStop(offset, color);
    }

    return canvasGradient;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onKeyDown(KeyboardEvent keyboardEvent) {
    if (_type == TextFieldType.INPUT) {
      _refreshTextLineMetrics();

      final text = _text;
      final textLength = text.length;
      final textLineMetrics = _textLineMetrics;
      final caretIndex = _caretIndex;
      final caretLine = _caretLine;
      var caretIndexNew = -1;

      switch (keyboardEvent.keyCode) {
        case html.KeyCode.BACKSPACE:
          keyboardEvent.preventDefault();
          if (caretIndex > 0) {
            _text =
                text.substring(0, caretIndex - 1) + text.substring(caretIndex);
            caretIndexNew = caretIndex - 1;
          }
          break;

        case html.KeyCode.END:
          keyboardEvent.preventDefault();
          final tlm = textLineMetrics[caretLine];
          caretIndexNew = tlm._textIndex + tlm._text.length;
          break;

        case html.KeyCode.HOME:
          keyboardEvent.preventDefault();
          final tlm = textLineMetrics[caretLine];
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
            final tlmFrom = textLineMetrics[caretLine];
            final tlmTo = textLineMetrics[caretLine - 1];
            final lineIndex =
                min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
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
            final tlmFrom = textLineMetrics[caretLine];
            final tlmTo = textLineMetrics[caretLine + 1];
            final lineIndex =
                min(caretIndex - tlmFrom._textIndex, tlmTo._text.length);
            caretIndexNew = tlmTo._textIndex + lineIndex;
          } else {
            caretIndexNew = textLength;
          }
          break;

        case html.KeyCode.DELETE:
          keyboardEvent.preventDefault();
          if (caretIndex < textLength) {
            _text =
                text.substring(0, caretIndex) + text.substring(caretIndex + 1);
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

  void _onTextInput(TextEvent textEvent) {
    if (_type == TextFieldType.INPUT) {
      textEvent.preventDefault();

      final textLength = _text.length;
      final caretIndex = _caretIndex;
      var newText = textEvent.text;

      if (newText == '\r') newText = '\n';
      if (newText == '\n' && _multiline == false) newText = '';
      if (newText == '') return;
      if (maxChars != 0 && textLength >= maxChars) return;

      _text = _text.substring(0, caretIndex) +
          newText +
          _text.substring(caretIndex);
      _caretIndex = _caretIndex + newText.length;
      _caretTime = 0.0;
      _refreshPending |= 3;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _onMouseDown(MouseEvent mouseEvent) {
    final mouseX = mouseEvent.localX.toDouble();
    final mouseY = mouseEvent.localY.toDouble();
    final canvasContext = _dummyCanvasContext;

    canvasContext.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);

    for (var line = 0; line < _textLineMetrics.length; line++) {
      final textLineMetrics = _textLineMetrics[line];

      final text = textLineMetrics._text;
      final lineX = textLineMetrics.x;
      final lineY1 = textLineMetrics.y - textLineMetrics.ascent;
      final lineY2 = textLineMetrics.y + textLineMetrics.descent;

      if (lineY1 <= mouseY && lineY2 >= mouseY) {
        var bestDistance = double.infinity;
        var bestIndex = 0;

        for (var c = 0; c <= text.length; c++) {
          final width =
              canvasContext.measureText(text.substring(0, c)).width!.toDouble();
          final distance = (lineX + width - mouseX).abs();
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
