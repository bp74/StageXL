class Mouse
{
  static String _customCursor = MouseCursor.AUTO;
  static bool _isCursorHidden = false;
  static EventDispatcher __eventDispatcher;
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
 
  static String get cursor() => _customCursor;
  
  static void set cursor(String value)
  {
    _customCursor = value;
    _eventDispatcher.dispatchEvent(new Event("mouseCursorChanged", false));
  }

  //-------------------------------------------------------------------------------------------------
 
  static void hide()
  {
    _isCursorHidden = true;
    _eventDispatcher.dispatchEvent(new Event("mouseCursorChanged", false));
  }

  static void show()
  {
    _isCursorHidden = false;
    _eventDispatcher.dispatchEvent(new Event("mouseCursorChanged", false));
  }

  //-------------------------------------------------------------------------------------------------
   
  static EventDispatcher get _eventDispatcher()
  {
    if (__eventDispatcher == null)
      __eventDispatcher = new EventDispatcher();
    
    return __eventDispatcher;
  }
  
  static String _getCssStyle(String mouseCursor)
  {
    String cursor = mouseCursor;
    String style = "auto";

    if (_customCursor != MouseCursor.AUTO)
      cursor = _customCursor;

    switch(cursor)
    {
      case MouseCursor.AUTO: style = "auto"; break;
      case MouseCursor.ARROW: style = "default"; break;
      case MouseCursor.BUTTON: style = "pointer"; break;
      case MouseCursor.HAND: style = "move"; break;
      case MouseCursor.IBEAM: style = "text"; break;
      case MouseCursor.WAIT: style = "wait"; break;
    }

    // The cursor style "none" is not standardized, but works quite well.
    
    if (_isCursorHidden)
      style = "none";

    return style;
  }

}
