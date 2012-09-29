class _EventListenerListIndex
{
  static final enterFrame = new _EventListenerListIndex();

  //-------------------------------------------------------------------------------------------------

  List<EventListenerList> _lists;

  _EventListenerListIndex()
  {
    _lists = new List<EventListenerList>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void add(EventListenerList list)
  {
    _lists.add(list);
  }

  //-------------------------------------------------------------------------------------------------

  void remove(EventListenerList list)
  {
    var index = _lists.indexOf(list);

    if (index != -1)
      _lists[index] = null;
  }

  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    var listsLength = _lists.length;
    int c = 0;

    for(int i = 0; i < listsLength; i++)
    {
      EventListenerList eventListenerList = _lists[i];

      if (eventListenerList != null)
      {
        event._target = eventListenerList.eventDispatcher;
        event._currentTarget = eventListenerList.eventDispatcher;
        event._eventPhase = EventPhase.AT_TARGET;

        eventListenerList.dispatchEvent(event);

        if (c != i)
          _lists[c] = eventListenerList;

        c++;
      }
    }

    for(int i = listsLength; i < _lists.length; i++)
      _lists[c++] = _lists[i];

    _lists.length = c;
  }

}