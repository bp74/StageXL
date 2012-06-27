class TextFormat 
{
  String font;
  int size;
  int color;
  bool bold;
  bool italic;
  bool underline;

  String url;
  String target;
  
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
  
  TextFormat([this.font = null, this.size = 12, this.color = 0x000000, 
              this.bold = false,  this.italic = false, this.underline = false, 
              this.url = null, this.target = null, 
              this.align = "left", 
              this.leftMargin = 0, this.rightMargin = 0, this.indent = 0, this.leading = 0]);
}
