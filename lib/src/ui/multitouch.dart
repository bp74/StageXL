library stagexl.ui.multitouch;

import 'dart:async';
import 'dart:html' as html;

/// The input modes for touch screen devices.
///
class MultitouchInputMode {
  final String name;
  const MultitouchInputMode(this.name);

  /// Specifies that gesture events are dispatched for the related user 
  /// interaction supported by the current environment, and other touch events 
  /// (such as a simple tap) are interpreted as mouse events.
  static const MultitouchInputMode GESTURE = const MultitouchInputMode("GESTURE");
  
  /// Specifies that all user contact with a touch-enabled device is interpreted
  /// as a type of mouse event.
  static const MultitouchInputMode NONE = const MultitouchInputMode("NONE");
  
  /// Specifies that events are dispatched only for basic touch events, such as 
  /// a single finger tap. When you use this setting, events listed in the 
  /// [TouchEvent] class are dispatched; events listed in the gesture event
  /// classes are not dispatched.
  static const MultitouchInputMode TOUCH_POINT = const MultitouchInputMode("TOUCH_POINT");
}

/// The [Multitouch] class is used opt-in for multi touch support in your
/// application. It also provides an easy way to check if the current device
/// supports multi touch or not.
///
/// Example:
///
///     if (Multitouch.supportsTouchEvents) {
///       Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
///     }
///
///     var sprite = new Sprite();
///     sprite.onMouseDown.listen(_onMouseDown);
///     sprite.onTouchBegin.listen(_onTouchBegin);
///
class Multitouch {

  /// Indicates whether the current environment supports gesture input, such as 
  /// rotating two fingers around a touch screen. 
  /// 
  /// Note: This always returns false because gestures are not implementet yet.
  /// TODO: Implement gesture support.
  static bool supportsGestureEvents = false;
  
  /// Indicates whether the current environment supports basic touch input. 
  /// Touch events are listed in the [TouchEvent] class.
  static bool supportsTouchEvents = _checkTouchEvents();
  
  /// A list of multi-touch contact types supported in the current environment. 
  /// The list of Strings can be used as event types to register event 
  /// listeners. 
  /// 
  /// Note: The list is currently empty because gestures are not implemented yet.
  /// TODO: Implement gesture support.
  static List<String> supportedGestures = [];

  static bool _initialized = false;
  static MultitouchInputMode _inputMode =  MultitouchInputMode.NONE;

  static final _inputModeChangedEvent = new StreamController<MultitouchInputMode>.broadcast();
  static Stream<MultitouchInputMode> onInputModeChanged = _inputModeChangedEvent.stream;

  //------------------------------------------------------------------

  static int get maxTouchPoints => supportsTouchEvents ? 10 : 0;

  /// Returns the multi-touch mode for touch and gesture event handling. 
  static MultitouchInputMode get inputMode => _inputMode;

  /// Sets the multi-touch mode for touch and gesture event handling. Use 
  /// this property to manage whether or not events are dispatched as touch 
  /// events with multiple points of contact and specific events for different 
  /// gestures.
  static set inputMode(MultitouchInputMode value) {
    _inputMode = value;
    _inputModeChangedEvent.add(value);
  }

  //------------------------------------------------------------------

  static bool _checkTouchEvents() {
    try {
      return html.TouchEvent.supported;
    } catch (e) {
      return false;
    }
  }

}
