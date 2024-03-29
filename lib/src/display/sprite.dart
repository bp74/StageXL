part of '../display.dart';

/// The Sprite class is a basic display list building block.
///
/// It is a display list node that can display graphics and can also contain
/// children.

class Sprite extends DisplayObjectContainer {
  Graphics? _graphics;

  /// Specifies the Graphics object that belongs to this sprite where vector
  /// drawing commands can occur.

  Graphics get graphics => _graphics ??= Graphics();

  set graphics(Graphics value) {
    _graphics = value;
  }

  //----------------------------------------------------------------------------

  /// Specifies the display object over which the sprite is being dragged, or on
  /// which the sprite was dropped.

  DisplayObject? dropTarget;

  /// Lets the user drag this sprite with the mouse or the current touch point.
  ///
  /// If this method is called within the context of a touch event, the drag
  /// will be performed accordingly all future touch events with the same
  /// [TouchEvent.touchPointID]. Otherwise the drag will be performed based
  /// on mouse events.
  ///
  /// The sprite remains draggable until explicitly stopped through a call
  /// to the [stopDrag] method.
  ///
  /// With [lockCenter] you can specify whether the draggable sprite is locked
  /// to the center of the pointer position (true), or locked to the point where
  /// the user first clicked the sprite (false).
  ///
  /// [bounds] is the value relative to the coordinates of the Sprite's
  /// parent that specify a constraint rectangle for the Sprite.

  void startDrag([bool lockCenter = false, Rectangle<num>? bounds]) {
    final stage = this.stage;
    final inputEvent = InputEvent.current;
    final globalPoint = Point<num>(0.0, 0.0);
    var anchorPoint = Point<num>(0.0, 0.0);
    var touchPointID = 0;

    if (inputEvent == null && stage != null) {
      globalPoint.copyFrom(stage.mousePosition);
    } else if (inputEvent is MouseEvent) {
      globalPoint.setTo(inputEvent.stageX, inputEvent.stageY);
    } else if (inputEvent is TouchEvent) {
      globalPoint.setTo(inputEvent.stageX, inputEvent.stageY);
      touchPointID = inputEvent.touchPointID;
    } else {
      return;
    }

    if (lockCenter) {
      anchorPoint = this.bounds.center;
    } else {
      globalToLocal(globalPoint, anchorPoint);
    }

    stage!._startDrag(this, globalPoint, anchorPoint, bounds, touchPointID);
  }

  /// Ends the [startDrag] method.
  ///
  /// A sprite that was made draggable with the [startDrag] method remains
  /// draggable until a [stopDrag] method is added or the sprite was dragged
  /// with a different touch point.

  void stopDrag() {
    final stage = this.stage;
    stage?._stopDrag(this);
  }

  //----------------------------------------------------------------------------

  @override
  List<DisplayObject> getObjectsUnderPoint(Point<num> point) {
    final result = super.getObjectsUnderPoint(point);
    if (_graphics != null && _graphics!.hitTest(point.x, point.y)) {
      result.insert(0, this);
    }
    return result;
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    if (_graphics == null) {
      return super.bounds;
    } else if (numChildren == 0) {
      return _graphics!.bounds;
    } else {
      return _graphics!.bounds.boundingBox(super.bounds);
    }
  }

  //----------------------------------------------------------------------------

  /// Designates another sprite to serve as the hit area for a sprite.
  ///
  /// If the hitArea is null (the default), the sprite itself is used as the hit
  /// area. The value of the hitArea property can be a reference to a Sprite
  /// object.
  ///
  /// You can change the hitArea property at any time; the modified sprite
  /// immediately uses the new hit area behavior. The sprite designated as the
  /// hit area does not need to be visible; its graphical shape, although not
  /// visible, is still detected as the hit area.
  ///
  /// Note: You must set to false the [mouseEnabled] property of the sprite
  /// designated as the hit area. Otherwise, your sprite button might not work
  /// because the sprite designated as the hit area receives the user input
  /// events instead of your sprite button.

  Sprite? hitArea;

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    final hitArea = this.hitArea;
    final graphics = _graphics;
    DisplayObject? target;

    if (hitArea != null) {
      final point = Point<num>(localX, localY);
      localToGlobal(point, point);
      hitArea.globalToLocal(point, point);
      target = hitArea.hitTestInput(point.x, point.y);
      return target != null ? this : null;
    }

    target = super.hitTestInput(localX, localY);

    if (target == null && graphics != null) {
      target = graphics.hitTest(localX, localY) ? this : null;
    }

    return target;
  }

  //----------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    _graphics?.render(renderState);
    super.render(renderState);
  }
}
