part of stagexl.text;

class TextFormat {

  String font;
  num size;
  int color;
  num strokeWidth;
  int strokeColor;
  GraphicsGradient fillGradient;

  int weight;
  bool bold;
  bool italic;
  bool underline;
  String align;

  num topMargin;
  num bottomMargin;
  num leftMargin;
  num rightMargin;
  num indent;
  num leading;

  //-------------------------------------------------------------------------------------------------

  TextFormat(this.font, this.size, this.color, {
    this.strokeWidth  : 0.0,
    this.strokeColor  : Color.Black,
    this.fillGradient : null,
    this.weight       : 400,
    this.bold         : false,
    this.italic       : false,
    this.underline    : false,
    this.align        : "left",
    this.topMargin    : 0.0,
    this.bottomMargin : 0.0,
    this.leftMargin   : 0.0,
    this.rightMargin  : 0.0,
    this.indent       : 0.0,
    this.leading      : 0.0
  });

  //-------------------------------------------------------------------------------------------------

  TextFormat clone() => new TextFormat(font, size, color,
      strokeWidth: strokeWidth, strokeColor: strokeColor, fillGradient: fillGradient,
      weight: weight, bold: bold, italic: italic, underline: underline, align: align,
      topMargin: topMargin, bottomMargin: bottomMargin, leftMargin: leftMargin, rightMargin: rightMargin,
      indent: indent, leading: leading);

  //-------------------------------------------------------------------------------------------------

  String get _cssFontStyle {
    var fontStyle = "${weight} ${size}px ${font}";
    if (bold) fontStyle = "bold ${size}px ${font}";
    if (italic) fontStyle = "italic $fontStyle";
    return fontStyle;
  }

}
