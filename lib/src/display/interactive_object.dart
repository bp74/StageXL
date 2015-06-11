part of stagexl.display;

/// The [InteractiveObject] class is the abstract base class for all display
/// objects with which the user can interact, using the mouse, keyboard, or
/// other user input device.
///
/// The [InteractiveObject] class itself does not include any APIs for rendering
/// content onscreen. To create a custom subclass of the [InteractiveObject]
/// class, extend one of the subclasses that do have APIs for rendering content
/// onscreen, such as the [Sprite], [SimpleButton], or [TextField] classes.
abstract class InteractiveObject extends DisplayObject {

  /// Specifies whether the object receives doubleClick events.
  ///
  /// The default value is false, which means that by default an
  /// [InteractiveObject] instance does not receive doubleClick events. If the
  /// [doubleClickEnabled] property is set to true, the instance receives
  /// doubleClick events within its bounds. The [mouseEnabled] property of this
  /// [InteractiveObject] must also be set to true for the object to receive
  /// doubleClick events.
  ///
  /// No event is dispatched by setting this property.
  bool doubleClickEnabled = false;

  /// Specifies whether this object receives mouse, or other user input,
  /// messages.
  ///
  /// The default value is true, which means that by default any
  /// [InteractiveObject] instance that is on the display list receives mouse
  /// events or other user input events. If [mouseEnabled] is set to false, the
  /// instance does not receive any mouse events (or other user input events
  /// like keyboard events). Any children of this instance on the display list
  /// are not affected. To change the [mouseEnabled] behavior for all children
  /// of an object on the display list, use
  /// [DisplayObjectContainer.mouseChildren].
  ///
  /// No event is dispatched by setting this property.
  bool mouseEnabled = true;

  /// Defines the mouse cursor that is displayed on this interactive object.
  String mouseCursor = MouseCursor.AUTO;

  /// Specifies whether this object is in the tab order.
  ///
  /// If this object is in the tab order, the value is true; otherwise, the
  /// value is false. By default, the value is true.
  bool tabEnabled = true;

  /// Specifies the tab ordering of objects.
  ///
  /// The [tabIndex] property is 0 by default.
  int tabIndex = 0;

  // simulate [useHandCursor] by changing the [mouseCursor] value.

  bool get useHandCursor {
    return mouseCursor == MouseCursor.POINTER;
  }

  set useHandCursor(bool value) {
    mouseCursor = value ? MouseCursor.POINTER : null;
  }

  // mouse events

  static const EventStreamProvider<MouseEvent> mouseOutEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OUT);
  static const EventStreamProvider<MouseEvent> mouseOverEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OVER);
  static const EventStreamProvider<MouseEvent> mouseRollOutEvent = const EventStreamProvider<MouseEvent>(MouseEvent.ROLL_OUT);
  static const EventStreamProvider<MouseEvent> mouseRollOverEvent = const EventStreamProvider<MouseEvent>(MouseEvent.ROLL_OVER);
  static const EventStreamProvider<MouseEvent> mouseMoveEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_MOVE);
  static const EventStreamProvider<MouseEvent> mouseDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.CLICK);
  static const EventStreamProvider<MouseEvent> mouseDoubleClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.DOUBLE_CLICK);
  static const EventStreamProvider<MouseEvent> mouseMiddleDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseMiddleUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseMiddleClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_CLICK);
  static const EventStreamProvider<MouseEvent> mouseRightDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseRightUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseRightClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_CLICK);
  static const EventStreamProvider<MouseEvent> mouseWheelEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_WHEEL);
  static const EventStreamProvider<MouseEvent> mouseContextMenu = const EventStreamProvider<MouseEvent>(MouseEvent.CONTEXT_MENU);

  /// Dispatched when the user moves a pointing device away from an
  /// InteractiveObject instance.
  /// 
  /// The event target is the object previously under the pointing device. If
  /// the target is a [SimpleButton] instance, the button displays the upState
  /// display object as the default behavior.
  /// 
  /// The mouseOut event is dispatched each time the mouse leaves the area of
  /// any child object of the display object container, even if the mouse
  /// remains over another child object of the display object container. This is
  /// different behavior than the purpose of the [onMouseRollOut] event, which
  /// is to simplify the coding of rollover behaviors for display object
  /// containers with children. When the mouse leaves the area of a display
  /// object or the area of any of its children to go to an object that is not
  /// one of its children, the display object dispatches the rollOut event. The
  /// rollOut events are dispatched consecutively up the parent chain of the
  /// object.
  EventStream<MouseEvent> get onMouseOut => InteractiveObject.mouseOutEvent.forTarget(this);
  
  /// Dispatched when the user moves a pointing device over an
  /// InteractiveObject instance.
  /// 
  /// If the target is a [SimpleButton] instance, the object displays the
  /// overState or upState display object, depending on whether the mouse button
  /// is down, as the default behavior.
  /// 
  /// The [onMouseOver] event is dispatched each time the mouse enters the area
  /// of any child object of the display object container, even if the mouse was
  /// already over another child object of the display object container. This is
  /// different behavior than the purpose of the [onMouseRollOver] event, which
  /// is to simplify the coding of rollout behaviors for display object
  /// containers with children. When the mouse enters the area of a display
  /// object or the area of any of its children from an object that is not one
  /// of its children, the display object dispatches the rollOver event. The
  /// rollOver events are dispatched consecutively down the parent chain of the
  /// object.
  EventStream<MouseEvent> get onMouseOver => InteractiveObject.mouseOverEvent.forTarget(this);
  
  /// Dispatched when the user moves a pointing device away from an
  /// InteractiveObject instance.
  /// 
  /// The event target is the object previously under the pointing device or a
  /// parent of that object. The rollOut events are dispatched consecutively up
  /// the parent chain of the object.
  /// 
  /// The purpose of the rollOut event is to simplify the coding of rollover
  /// behaviors for display object containers with children. When the mouse
  /// leaves the area of a display object or the area of any of its children to
  /// go to an object that is not one of its children, the display object
  /// dispatches the rollOut event. This is different behavior than that of the
  /// [onMouseOut] event, which is dispatched each time the mouse leaves the
  /// area of any child object of the display object container, even if the
  /// mouse remains over another child object of the display object container.
  EventStream<MouseEvent> get onMouseRollOut => InteractiveObject.mouseRollOutEvent.forTarget(this);
  
  /// Dispatched when the user moves a pointing device over an InteractiveObject
  /// instance.
  /// 
  /// The event target is the object under the pointing device or a parent of
  /// that object. The rollOver events are dispatched consecutively down the
  /// parent chain of the object.
  /// 
  /// The purpose of the rollOver event is to simplify the coding of rollout
  /// behaviors for display object containers with children. When the mouse
  /// enters the area of a display object or the area of any of its children
  /// from an object that is not one of its children, the display object
  /// dispatches the rollOver event. This is different behavior than that of the
  /// [onMouseOver] event, which is dispatched each time the mouse enters the
  /// area of any child object of the display object container, even if the
  /// mouse was already over another child object of the display object
  /// container.
  EventStream<MouseEvent> get onMouseRollOver => InteractiveObject.mouseRollOverEvent.forTarget(this);
  
  /// Dispatched when a user moves the pointing device while it is over an
  /// InteractiveObject.
  /// 
  /// If the target is a text field that the user is selecting, the selection is
  /// updated as the default behavior.
  EventStream<MouseEvent> get onMouseMove => InteractiveObject.mouseMoveEvent.forTarget(this);
  
  /// Dispatched when a user presses the pointing device button over an
  /// InteractiveObject instance.
  /// 
  /// If the target is a [SimpleButton] instance, the [SimpleButton] instance
  /// displays the downState display object as the default behavior. If the
  /// target is a selectable text field, the text field begins selection as the
  /// default behavior.
  EventStream<MouseEvent> get onMouseDown => InteractiveObject.mouseDownEvent.forTarget(this);
  
  /// Dispatched when a user releases the pointing device button over an
  /// InteractiveObject instance.
  /// 
  /// If the target is a [SimpleButton] instance, the object displays the
  /// upState display object. If the target is a selectable text field, the text
  /// field ends selection as the default behavior.
  EventStream<MouseEvent> get onMouseUp => InteractiveObject.mouseUpEvent.forTarget(this);
  
  /// Dispatched when a user presses and releases the main button of the user's
  /// pointing device over the same InteractiveObject.
  /// 
  /// For a click event to occur, it must always follow this series of events in
  /// the order of occurrence: mouseDown event, then mouseUp. The target object
  /// must be identical for both of these events; otherwise the click event does
  /// not occur. Any number of other mouse events can occur at any time between
  /// the mouseDown or mouseUp events; the click event still occurs.
  EventStream<MouseEvent> get onMouseClick => InteractiveObject.mouseClickEvent.forTarget(this);
  
  /// Dispatched when a user presses and releases the main button of a pointing
  /// device twice in rapid succession over the same InteractiveObject when that
  /// object's [doubleClickEnabled] flag is set to true.
  /// 
  /// For a doubleClick event to occur, it must immediately follow the following
  /// series of events: mouseDown, mouseUp, click, mouseDown, mouseUp. All of
  /// these events must share the same target as the doubleClick event. The
  /// second click, represented by the second mouseDown and mouseUp events, must
  /// occur within a specific period of time after the click event. The
  /// allowable length of this period varies by operating system and can often
  /// be configured by the user. If the target is a selectable text field, the
  /// word under the pointer is selected as the default behavior. If the target
  /// InteractiveObject does not have its [doubleClickEnabled] flag set to true
  /// it receives two click events.
  EventStream<MouseEvent> get onMouseDoubleClick => InteractiveObject.mouseDoubleClickEvent.forTarget(this);
  
  /// Dispatched when a user presses the middle pointing device button over an
  /// InteractiveObject instance.
  EventStream<MouseEvent> get onMouseMiddleDown => InteractiveObject.mouseMiddleDownEvent.forTarget(this);
  
  /// Dispatched when a user releases the pointing device button over an
  /// InteractiveObject instance.
  EventStream<MouseEvent> get onMouseMiddleUp => InteractiveObject.mouseMiddleUpEvent.forTarget(this);
  
  /// Dispatched when a user presses and releases the middle button of the
  /// user's pointing device over the same InteractiveObject.
  /// 
  /// For a middleClick event to occur, it must always follow this series of
  /// events in the order of occurrence: middleMouseDown event, then
  /// middleMouseUp. The target object must be identical for both of these
  /// events; otherwise the middleClick event does not occur. Any number of
  /// other mouse events can occur at any time between the middleMouseDown or
  /// middleMouseUp events; the middleClick event still occurs.
  EventStream<MouseEvent> get onMouseMiddleClick => InteractiveObject.mouseMiddleClickEvent.forTarget(this);
  
  /// Dispatched when a user presses the right button over an InteractiveObject
  /// instance.
  EventStream<MouseEvent> get onMouseRightDown => InteractiveObject.mouseRightDownEvent.forTarget(this);
  
  /// Dispatched when a user releases the right button over an InteractiveObject
  /// instance.
  EventStream<MouseEvent> get onMouseRightUp => InteractiveObject.mouseRightUpEvent.forTarget(this);
  
  /// Dispatched when a user presses and releases the right button of the user's
  /// pointing device over the same InteractiveObject.
  /// 
  /// For a rightClick event to occur, it must always follow this series of
  /// events in the order of occurrence: rightMouseDown event, then
  /// rightMouseUp. The target object must be identical for both of these
  /// events; otherwise the rightClick event does not occur. Any number of other
  /// mouse events can occur at any time between the rightMouseDown or
  /// rightMouseUp events; the rightClick event still occurs.
  EventStream<MouseEvent> get onMouseRightClick => InteractiveObject.mouseRightClickEvent.forTarget(this);
  
  /// Dispatched when a mouse wheel is spun over an InteractiveObject instance.
  /// 
  /// If the target is a text field, the text scrolls as the default behavior.
  EventStream<MouseEvent> get onMouseWheel => InteractiveObject.mouseWheelEvent.forTarget(this);
  
  /// Dispatched when a user gesture triggers the context menu associated with
  /// this interactive object.
  EventStream<MouseEvent> get onMouseContextMenu => InteractiveObject.mouseContextMenu.forTarget(this);

  // touch events

  static const EventStreamProvider<TouchEvent> touchOutEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OUT);
  static const EventStreamProvider<TouchEvent> touchOverEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OVER);
  static const EventStreamProvider<TouchEvent> touchMoveEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_MOVE);
  static const EventStreamProvider<TouchEvent> touchBeginEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_BEGIN);
  static const EventStreamProvider<TouchEvent> touchEndEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_END);
  static const EventStreamProvider<TouchEvent> touchCancelEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_CANCEL);
  static const EventStreamProvider<TouchEvent> touchRollOut = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_ROLL_OUT);
  static const EventStreamProvider<TouchEvent> touchRollOver = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_ROLL_OVER);
  static const EventStreamProvider<TouchEvent> touchTap = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_TAP);

  /// Dispatched when the user moves the point of contact away from
  /// InteractiveObject instance on a touch-enabled device.
  ///
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchOut => InteractiveObject.touchOutEvent.forTarget(this);
  
  /// Dispatched when the user moves the point of contact over an
  /// InteractiveObject instance on a touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchOver => InteractiveObject.touchOverEvent.forTarget(this);
  
  /// Dispatched when the user touches the device, and is continuously
  /// dispatched until the point of contact is removed.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchMove => InteractiveObject.touchMoveEvent.forTarget(this);
  
  /// Dispatched when the user first contacts a touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchBegin => InteractiveObject.touchBeginEvent.forTarget(this);
  
  /// Dispatched when the user removes contact with a touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchEnd => InteractiveObject.touchEndEvent.forTarget(this);
  
  /// Dispatched when the touch event is canceled.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchCancel => InteractiveObject.touchCancelEvent.forTarget(this);
  
  /// Dispatched when the user moves the point of contact away from an
  /// InteractiveObject instance on a touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchRollOut => InteractiveObject.touchRollOut.forTarget(this);
  
  /// Dispatched when the user moves the point of contact over an
  /// InteractiveObject instance on a touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchRollOver => InteractiveObject.touchRollOver.forTarget(this);
  
  /// Dispatched when the user lifts the point of contact over the same
  /// InteractiveObject instance on which the contact was initiated on a
  /// touch-enabled device.
  /// 
  /// You have to opt-in for touch events by setting the InputEventMode
  /// to `TouchOnly` or `MouseAndTouch` in the stage options.

  EventStream<TouchEvent> get onTouchTap => InteractiveObject.touchTap.forTarget(this);

  // keyboard events

  static const EventStreamProvider<KeyboardEvent> keyUpEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_UP);
  static const EventStreamProvider<KeyboardEvent> keyDownEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_DOWN);

  /// Dispatched when the user releases a key.
  /// 
  /// Mappings between keys and specific characters vary by device and operating
  /// system.
  EventStream<KeyboardEvent> get onKeyUp => InteractiveObject.keyUpEvent.forTarget(this);
  
  /// Dispatched when the user presses a key.
  /// 
  /// Mappings between keys and specific characters vary by device and operating
  /// system.
  EventStream<KeyboardEvent> get onKeyDown => InteractiveObject.keyDownEvent.forTarget(this);

  // text events

  static const EventStreamProvider<TextEvent> textInputEvent = const EventStreamProvider<TextEvent>(TextEvent.TEXT_INPUT);

  /// Dispatched when a user enters one or more characters of text.
  EventStream<TextEvent> get onTextInput => InteractiveObject.textInputEvent.forTarget(this);
}
