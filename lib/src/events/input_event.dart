part of stagexl.events;

enum InputEventMode {
  MouseOnly,
  TouchOnly,
  MouseAndTouch
}

/// The [InputEvent] is a common base class for [MouseEvent] and [TouchEvent].
///
/// This makes it more convenient to use the same event listener for mouse
/// and touch events. The fields that are the same in mouse and touch events
/// are defined in the [InputEvent] class.
///
/// Example:
///
///     StageXL.stageOptions.inputEventMode = InputEventMode.MouseAndTouch;
///
///     var sprite = new Sprite();
///     sprite.onMouseDown.listen(onSpriteSelected);
///     sprite.onTouchBegin.listen(onSpriteSelected);
///
///     void onSpriteSelected(InputEvent inputEvent) {
///       print("{inputEvent.localX}, {inputEvent.localY});
///     }

abstract class InputEvent extends Event {

  /// The mouse or touch event that is currently dispatched. The value is only
  /// set if the code is running in the context of a mouse or touch event
  /// propagation, otherwise the value is `null`.

  static InputEvent current;

  /// The x-coordinate at which the event occurred relative
  /// to the containing display object.

  final num localX;

  /// The y-coordinate at which the event occurred relative
  /// to the containing display object.

  final num localY;

  /// The x-coordinate of the input event relative to the stage.

  final num stageX;

  /// The y-coordinate of the input event relative to the stage.

  final num stageY;

  /// Indicates whether the Alt key is active (true) or inactive (false).

  final bool altKey;

  /// Indicates whether the Ctrl key is active (true) or inactive (false).

  final bool ctrlKey;

  /// Indicates whether the Shift key is active (true) or inactive (false).

  final bool shiftKey;

  /// Creates a new [InputEvent].

  InputEvent(String type, bool bubbles,
      this.localX, this.localY,
      this.stageX, this.stageY,
      this.altKey, this.ctrlKey, this.shiftKey) : super(type, bubbles);

  //---------------------------------------------------------------------------

  bool _isDefaultPrevented = false;

  void preventDefault() {
    _isDefaultPrevented = true;
  }

  bool get isDefaultPrevented => _isDefaultPrevented;
}
