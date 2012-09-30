
class _EventListenerUseCapture
{
  Function eventListener;
  bool useCapture;

  _EventListenerUseCapture(this.eventListener, this.useCapture);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class EventListenerList
{
  EventDispatcher _eventDispatcher;
  String _eventType;
  List<_EventListenerUseCapture> _list;

  EventListenerList(EventDispatcher eventDispatcher, String eventType)
  {
    _eventDispatcher = eventDispatcher;
    _eventType = eventType;
    _list = new List<_EventListenerUseCapture>();
  }

  //-------------------------------------------------------------------------------------------------

  EventDispatcher get eventDispatcher => _eventDispatcher;
  String get eventType => _eventType;

  //-------------------------------------------------------------------------------------------------

  void add(Function eventListener, [bool useCapture = false])
  {
    var list = _list;
    var listLength = list.length;

    for(int i = 0; i < listLength; i++)
      if (list[i].eventListener == eventListener && list[i].useCapture == useCapture)
        return;

    if (_eventType == Event.ENTER_FRAME && listLength == 0)
      _EventListenerListIndex.enterFrame.add(this);

    list.add(new _EventListenerUseCapture(eventListener, useCapture));
  }

  void operator +(Function eventListener) 
  {
    this.add(eventListener, false);  
  }
  
  //-------------------------------------------------------------------------------------------------

  void remove(Function eventListener, [bool useCapture = false])
  {
    var list = _list;
    var listLength = list.length;

    for(int i = 0; i < listLength; i++)
    {
      if (list[i].eventListener == eventListener && list[i].useCapture == useCapture)
      {
        _list = new List<_EventListenerUseCapture>.from(list);
        _list.removeAt(i);

        if (_eventType == Event.ENTER_FRAME && _list.length == 0)
          _EventListenerListIndex.enterFrame.remove(this);

        break;
      }
    }
  }

  void operator -(Function eventListener) 
  {
    this.remove(eventListener, false);  
  }
  
  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    var list = _list;
    var listLength = list.length;

    for(int i = 0; i < listLength; i++)
      if (event.eventPhase != EventPhase.CAPTURING_PHASE || list[i].useCapture)
        if (event.stopsImmediatePropagation == false)
          list[i].eventListener(event);
  }
}



