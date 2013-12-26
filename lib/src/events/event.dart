part of stagexl;

class Event {

  // DiplayObject events
  static const String ADDED = "added";
  static const String ADDED_TO_STAGE = "addedToStage";
  static const String ENTER_FRAME = "enterFrame";
  static const String EXIT_FRAME = "exitFrame";
  static const String REMOVED = "removed";
  static const String REMOVED_FROM_STAGE = "removedFromStage";
  static const String RESIZE = "resize";
  static const String RENDER = "render";

  // Common events
  static const String OKAY = "okay";
  static const String CANCEL = "cancel";
  static const String CHANGE = "change";
  static const String CONFIRM = "confirm";
  static const String SCROLL = "scroll";
  static const String OPEN = "open";
  static const String CLOSE = "close";
  static const String SELECT= "select";
  static const String COMPLETE = "complete";
  static const String PROGRESS = "progress";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String _type;
  bool _bubbles;
  int _eventPhase = EventPhase.AT_TARGET;
  EventDispatcher _target = null;
  EventDispatcher _currentTarget = null;
  bool _stopsPropagation = false;
  bool _stopsImmediatePropagation = false;

  Event(String type, [bool bubbles = false]) : _type = type, _bubbles = bubbles;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void stopPropagation() {
    _stopsPropagation = true;
  }

  void stopImmediatePropagation() {
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
