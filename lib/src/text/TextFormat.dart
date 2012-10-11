part of dartflash;

class TextFormat
{
  String font;
  int size;
  int color;
  bool bold;
  bool italic;
  bool underline;

  String align;
  int leftMargin;
  int rightMargin;
  int indent;
  int leading;

  int letterSpacing = 0;
  int blockIndent = 0;
  bool bullet = false;
  bool kerning = false;

  //-------------------------------------------------------------------------------------------------

  TextFormat( this.font, this.size, this.color, {
    this.bold         : false,
    this.italic       : false,
    this.underline    : false,
    this.align        : "left",
    this.leftMargin   : 0,
    this.rightMargin  : 0,
    this.indent       : 0,
    this.leading      : 0  });

}
