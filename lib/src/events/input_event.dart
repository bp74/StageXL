part of stagexl.events;

/// The [InputEvent] is a common interface for [MouseEvent] and [TouchEvent].
///
/// This makes it easy to use the same event listener for mouse and touch
/// events. The fields that are the same in mouse and touch events are
/// defined in the interface of [TouchEvent].
///
/// Example:
///
///     if (Multitouch.supportsTouchEvents) {
///       Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
///     }
///
///     var sprite = new Sprite();
///     sprite.onMouseDown.listen(onSpriteSelected);
///     sprite.onTouchBegin.listen(onSpriteSelected);
///
///     void onSpriteSelected(InputEvent inputEvent) {
///       print("{inputEvent.localX}, {inputEvent.localY});
///     }

abstract class InputEvent {

  /// The x-coordinate at which the event occurred relative
  /// to the containing display object.
  num get localX;

  /// The y-coordinate at which the event occurred relative
  /// to the containing display object.
  num get localY;

  /// The x-coordinate of the input event relative to the stage.
  num get stageX;

  /// The y-coordinate of the input event relative to the stage.
  num get stageY;

  /// Indicates whether the Alt key is active (true) or inactive (false).
  bool get altKey;

  /// Indicates whether the Ctrl key is active (true) or inactive (false).
  bool get ctrlKey;

  /// Indicates whether the Shift key is active (true) or inactive (false).
  bool get shiftKey;
}