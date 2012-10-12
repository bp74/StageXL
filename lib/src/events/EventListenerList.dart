part of dartflash;

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

  void add(EventListener eventListener, [bool useCapture = false])
  {
    for(int i = 0; i < _list.length; i++)
      if (_list[i].eventListener == eventListener && _list[i].useCapture == useCapture)
        return;

    if (_eventType == Event.ENTER_FRAME && _list.length == 0)
      _EventListenerListIndex.enterFrame.add(this);

    _list.add(new _EventListenerUseCapture(eventListener, useCapture));
  }


  //-------------------------------------------------------------------------------------------------

  void remove(EventListener eventListener, [bool useCapture = false])
  {
    for(int i = 0; i < _list.length; i++)
    {
      if (_list[i].eventListener == eventListener && _list[i].useCapture == useCapture)
      {
        _list = new List<_EventListenerUseCapture>.from(_list);
        _list.removeAt(i);

        if (_eventType == Event.ENTER_FRAME && _list.length == 0)
          _EventListenerListIndex.enterFrame.remove(this);

        break;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void operator +(EventListener eventListener)
  {
    this.add(eventListener, false);
  }

  void operator -(EventListener eventListener)
  {
    this.remove(eventListener, false);
  }

  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    for(int i = 0; i < _list.length; i++)
      if (event.eventPhase != EventPhase.CAPTURING_PHASE || _list[i].useCapture)
        if (event.stopsImmediatePropagation == false)
          _list[i].eventListener(event);
  }
}



