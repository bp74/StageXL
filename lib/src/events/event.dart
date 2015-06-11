part of stagexl.events;

/// Holds basic information about an event. 
/// 
/// For many events, such as the events represented by the [Event] class 
/// constants, this basic information is sufficient. Other events, however, may 
/// require more detailed information. Events associated with a mouse click, for 
/// example, need to include additional information about the location of the 
/// click event and whether any keys were pressed during the click event. You 
/// can pass such additional information to event listeners by extending the 
/// Event class, which is what the [MouseEvent] class does.
/// 
/// The methods of the Event class can be used in event listener functions to 
/// affect the behavior of the event object. You can make the current event 
/// listener the last one to process an event by calling the [stopPropagation]
/// or [stopImmediatePropagation] method.
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
  static const String MOUSE_LEAVE = "mouseLeave";

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

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  String _type;
  bool _bubbles;
  EventPhase _eventPhase = EventPhase.AT_TARGET;
  EventDispatcher _target = null;
  EventDispatcher _currentTarget = null;
  bool _isPropagationStopped = false;
  bool _isImmediatePropagationStopped = false;

  /// Creates an [Event] of specified [type].
  Event(String type, [bool bubbles = false]) : _type = type, _bubbles = bubbles;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Prevents processing of any event listeners in nodes subsequent to the 
  /// current node in the event flow. 
  /// 
  /// This method does not affect any event listeners in the current node 
  /// ([currentTarget]). In contrast, the [stopImmediatePropagation] method 
  /// prevents processing of event listeners in both the current node and 
  /// subsequent nodes. Additional calls to this method have no effect. This 
  /// method can be called in any phase of the event flow.

  void stopPropagation() {
    _isPropagationStopped = true;
  }

  /// Prevents processing of any event listeners in the current node and any 
  /// subsequent nodes in the event flow. 
  /// 
  /// This method takes effect immediately, and it affects event listeners in 
  /// the current node. In contrast, the [stopPropagation] method doesn't take 
  /// effect until all the event listeners in the current node finish processing.

  void stopImmediatePropagation() {
    _isPropagationStopped = true;
    _isImmediatePropagationStopped = true;
  }

  /// Indicates if the propagation of this event has been stopped.
  /// 
  /// If true, processing of any event listeners in nodes subsequent to the 
  /// current node in the event flow is prevented. This does not affect any 
  /// event listeners  in the current node ([currentTarget]). In contrast, 
  /// [stopsImmediatePropagation] indicates if processing of event listeners 
  /// in both the current node and subsequent nodes is prevented.

  bool get isPropagationStopped => _isPropagationStopped;
  
  /// Indicates if the propagation of this event has been stopped. 
  /// 
  /// If true, processing of any event listeners in the current node and any 
  /// subsequent nodes in the event flow is prevented. This takes effect 
  /// immediately, and it affects event listeners in the current node. In 
  /// contrast, [stopsPropagation] indicates that it doesn't take effect until 
  /// all the event listeners in the current node finish processing.

  bool get isImmediatePropagationStopped => _isImmediatePropagationStopped;

  /// The type of event.

  String get type => _type;
  
  /// Indicates whether an event is a bubbling event. If the event can bubble, 
  /// this value is true; otherwise it is false.
  ///
  /// When an event occurs, it moves through the three phases of the event flow: 
  /// the capture phase, which flows from the top of the display list hierarchy 
  /// to the node just before the target node; the target phase, which comprises 
  /// the target node; and the bubbling phase, which flows from the node 
  /// subsequent to the target node back up the display list hierarchy.

  bool get bubbles => _bubbles;
  
  /// Indicates whether an event is a capturing event. 

  bool get captures => true;

  /// The current phase in the event flow. 
  /// 
  /// This property can contain the following numeric values:
  ///
  /// * The capture phase ([EventPhase.CAPTURING_PHASE]).
  /// * The target phase ([EventPhase.AT_TARGET]).
  /// * The bubbling phase ([EventPhase.BUBBLING_PHASE]).

  EventPhase get eventPhase => _eventPhase;
  
  /// The event target. 
  /// 
  /// This property contains the target node. For example, if a user clicks an 
  /// OK button, the target node is the display list node containing that button.

  EventDispatcher get target => _target;
  
  /// The object that is actively processing the Event object with an event 
  /// listener. 
  /// 
  /// For example, if a user clicks an OK button, the current target could be 
  /// the node containing that button or one of its ancestors that has 
  /// registered an event listener for that event.

  EventDispatcher get currentTarget => _currentTarget;

}
