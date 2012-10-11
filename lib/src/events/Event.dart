part of dartflash;

class Event
{
  static const String ADDED = "added";
  static const String ADDED_TO_STAGE = "addedToStage";
  static const String ENTER_FRAME = "enterFrame";
  static const String REMOVED = "removed";
  static const String REMOVED_FROM_STAGE = "removedFromStage";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String _type;
  bool _bubbles;
  int _eventPhase;
  EventDispatcher _target;
  EventDispatcher _currentTarget;
  bool _stopsPropagation;
  bool _stopsImmediatePropagation;

  Event(String type, [bool bubbles = false])
  {
    _reset(type, bubbles);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _reset(String type, [bool bubbles = false])
  {
    _type = type;
    _bubbles = bubbles;
    _eventPhase = EventPhase.AT_TARGET;
    _target = null;
    _currentTarget = null;
    _stopsPropagation = false;
    _stopsImmediatePropagation = false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void stopPropagation()
  {
    _stopsPropagation = true;
  }

  void stopImmediatePropagation()
  {
    _stopsPropagation = true;
    _stopsImmediatePropagation = true;
  }

  bool get stopsPropagation => _stopsPropagation;
  bool get stopsImmediatePropagation => _stopsImmediatePropagation;

  String get type => _type;
  int get eventPhase => _eventPhase;
  bool get bubbles => _bubbles;
  bool get captures => true;

  EventDispatcher get target => _target;
  EventDispatcher get currentTarget => _currentTarget;
}
