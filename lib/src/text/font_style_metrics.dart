part of stagexl.text;

final Map<String, _FontStyleMetrics> _fontStyleMetrics = new Map<String, _FontStyleMetrics>();

_FontStyleMetrics _getFontStyleMetrics(TextFormat textFormat) {
  String fontStyle = textFormat._cssFontStyle;
  return _fontStyleMetrics.putIfAbsent(fontStyle, () => new _FontStyleMetrics(textFormat));
}

//-------------------------------------------------------------------------------------------------

class _FontStyleMetrics {

  int ascent = 0;
  int descent = 0;
  int height = 0;

  _FontStyleMetrics(TextFormat textFormat) {
    if (env.isCocoonJS) {
      _fromEstimation(textFormat);
    } else {
      _fromHtml(textFormat);
    }
  }

  void _fromEstimation(TextFormat textFormat) {
    this.height = textFormat.size;
    this.ascent = textFormat.size * 7 ~/ 8;
    this.descent = textFormat.size * 2 ~/ 8;
  }

  void _fromHtml(TextFormat textFormat) {

    var fontStyle = textFormat._cssFontStyle;
    var text = new html.Element.tag("span");
    var block = new html.Element.tag("div");
    var div = new html.Element.tag("div");

    text.style.font = fontStyle;
    text.text = "Hg";
    block.style.display = "inline-block";
    block.style.width = "1px";
    block.style.height = "0px";
    div.append(block);
    div.append(text);

    html.document.body.append(div);

    try {
      block.style.verticalAlign = "baseline";
      this.ascent = block.offsetTop - text.offsetTop;
      block.style.verticalAlign = "bottom";
      this.height = block.offsetTop - text.offsetTop;
      this.descent = height - ascent;
    } catch (e) {
      _fromEstimation(textFormat);
    } finally {
      div.remove();
    }
  }

}

