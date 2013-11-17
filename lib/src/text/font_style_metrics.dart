part of stagexl;

final Map<String, _FontStyleMetrics> _fontStyleMetrics = new Map<String, _FontStyleMetrics>(); 

_FontStyleMetrics _getFontStyleMetrics(String fontStyle) {
  
  if (_fontStyleMetrics.containsKey(fontStyle) == false) {
    _fontStyleMetrics[fontStyle] = new _FontStyleMetrics(fontStyle);
  }
  
  return _fontStyleMetrics[fontStyle];
}

//-------------------------------------------------------------------------------------------------

class _FontStyleMetrics {
  
  String fontStyle;
  int ascent = 0;
  int descent = 0;
  int height = 0;
  
  _FontStyleMetrics(String fontStyle) {
    
    this.fontStyle = fontStyle;
    
    var text = new html.Element.tag("span");
    text.style.font = this.fontStyle;
    text.text = "Hg";
    
    var block = new html.Element.tag("div");
    block.style.display = "inline-block";
    block.style.width = "1px";
    block.style.height = "0px";
    
    var div = new html.Element.tag("div");
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
      
    } finally {
      div.remove();
    }
  }
}

