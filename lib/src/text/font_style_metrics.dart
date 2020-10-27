part of stagexl.text;

final Map<String, _FontStyleMetrics> _fontStyleMetrics =
    <String, _FontStyleMetrics>{};

_FontStyleMetrics _getFontStyleMetrics(TextFormat textFormat) {
  var fontStyle = textFormat._cssFontStyle;
  return _fontStyleMetrics.putIfAbsent(
      fontStyle, () => _FontStyleMetrics(textFormat));
}

//-------------------------------------------------------------------------------------------------

class _FontStyleMetrics {
  int ascent = 0;
  int descent = 0;
  int height = 0;

  _FontStyleMetrics(TextFormat textFormat) {
    var fontStyle = textFormat._cssFontStyle;
    var text = html.Element.tag('span');
    var block = html.Element.tag('div');
    var div = html.Element.tag('div');

    text.style.font = fontStyle;
    text.text = 'Hg';
    block.style.display = 'inline-block';
    block.style.width = '1px';
    block.style.height = '0px';
    div.append(block);
    div.append(text);

    html.document.body!.append(div);

    try {
      block.style.verticalAlign = 'baseline';
      ascent = block.offsetTop - text.offsetTop;
      block.style.verticalAlign = 'bottom';
      height = block.offsetTop - text.offsetTop;
      descent = height - ascent;
    } catch (e) {
      height = textFormat.size as int;
      ascent = textFormat.size * 7 ~/ 8;
      descent = textFormat.size * 2 ~/ 8;
    } finally {
      div.remove();
    }
  }
}
