part of '../display.dart';

class _MouseButton {
  final String mouseDownEventType;
  final String mouseUpEventType;
  final String mouseClickEventType;
  final String mouseDoubleClickEventType;

  InteractiveObject? target;
  bool buttonDown = false;
  int clickTime = 0;
  int clickCount = 0;

  _MouseButton(this.mouseDownEventType, this.mouseUpEventType,
      this.mouseClickEventType, this.mouseDoubleClickEventType);

  static List<_MouseButton> createDefaults() => [
        _MouseButton(MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP,
            MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK),
        _MouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP,
            MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_CLICK),
        _MouseButton(MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP,
            MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_CLICK)
      ];
}

//------------------------------------------------------------------------------

class _TouchPoint {
  static int _globalTouchPointID = 1;

  final int touchPointID = _globalTouchPointID++;
  final bool primaryTouchPoint;
  final InteractiveObject target;

  InteractiveObject currentTarget;

  _TouchPoint(this.target, this.primaryTouchPoint) : currentTarget = target;
}

//------------------------------------------------------------------------------

class _Drag {
  final Stage stage;
  final Sprite sprite;
  final Point<num> anchor;
  final Rectangle<num>? bounds;
  final int touchPointID;

  _Drag(this.stage, this.sprite, this.anchor, this.bounds, this.touchPointID);

  void update(int touchPointID, Point<num> stagePoint) {
    if (touchPointID != this.touchPointID) return;

    final localPoint = Point<num>(0.0, 0.0);
    final parentPoint = Point<num>(0.0, 0.0);
    final visible = sprite.visible;

    sprite.globalToLocal(stagePoint, localPoint);

    if (bounds != null) {
      final bounds = this.bounds!;
      sprite.localToParent(localPoint, parentPoint);
      if (parentPoint.x < bounds.left) parentPoint.x = bounds.left;
      if (parentPoint.x > bounds.right) parentPoint.x = bounds.right;
      if (parentPoint.y < bounds.top) parentPoint.y = bounds.top;
      if (parentPoint.y > bounds.bottom) parentPoint.y = bounds.bottom;
      sprite.parentToLocal(parentPoint, localPoint);
    }

    localPoint.x = localPoint.x + sprite.pivotX - anchor.x;
    localPoint.y = localPoint.y + sprite.pivotY - anchor.y;

    sprite.localToParent(localPoint, parentPoint);
    sprite.visible = false;
    sprite.dropTarget = stage.hitTestInput(stagePoint.x, stagePoint.y);
    sprite.x = parentPoint.x;
    sprite.y = parentPoint.y;
    sprite.visible = visible;
  }
}
