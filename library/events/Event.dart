class Event 
{
  static final String ADDED = "added";
  static final String ADDED_TO_STAGE = "addedToStage";
  static final String ENTER_FRAME = "enterFrame";
  static final String REMOVED = "removed";
  static final String REMOVED_FROM_STAGE = "removedFromStage";
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  String _type;
  bool _bubbles;
  int _eventPhase;
  
  EventDispatcher _target = null;
  EventDispatcher _currentTarget = null;
  
  bool _stopsPropagation = false;
  bool _stopsImmediatePropagation = false;
      
  Event(String type, [bool bubbles = false])
  {
    _type = type;
    _bubbles = bubbles;    
    _eventPhase = EventPhase.AT_TARGET;
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
  
  bool get stopsPropagation() => _stopsPropagation;
  bool get stopsImmediatePropagation() => _stopsImmediatePropagation; 
  
  String get type() => _type;
  int get eventPhase() => _eventPhase; 
  bool get bubbles() => _bubbles; 
  bool get captures() => true;
           
  EventDispatcher get target() => _target; 
  EventDispatcher get currentTarget() => _currentTarget; 
}
