part of stagexl.display;

/// The [Sprite3D] class enables 3D transformations of 2D display objects.
///
/// Use the [rotationX], [rotationY] and [rotationZ] properties to rotate the
/// display object in 3D space. Use the [offsetX], [offsetY] and [offsetZ]
/// properties to move the display object in 3D space.
///
/// Example:
///
///     var flip = Sprite3D()
///     flip.addChild(bitmap);
///     flip.rotationY = PI / 4
///     flip.addTo(stage);
///
class Sprite3D extends DisplayObjectContainer3D implements Sprite {
  @override
  Graphics? _graphics;

  /// Specifies the Graphics object that belongs to this sprite where vector
  /// drawing commands can occur.

  @override
  Graphics get graphics => _graphics ??= Graphics();

  @override
  set graphics(Graphics value) {
    _graphics = value;
  }

  //----------------------------------------------------------------------------

  /// Specifies the display object over which the sprite is being dragged, or on
  /// which the sprite was dropped.

  @override
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

  @override
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

  @override
  void stopDrag() {
    final stage = this.stage;
    stage?._stopDrag(this);
  }

  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    final bounds = super.bounds;
    return _graphics == null ? bounds : bounds.boundingBox(_graphics!.bounds);
  }

  //----------------------------------------------------------------------------

  /// Designates another sprite to serve as the hit area for a sprite.
  ///
  /// If the hitArea is null (the default), the sprite itself is used as the hit
  /// area. The value of the hitArea property can be a reference to a Sprite
  /// object.
  ///
  /// You can change the hitArea property at any time; the modified sprite
  /// immediately uses the hit area behavior. The sprite designated as the
  /// hit area does not need to be visible; its graphical shape, although not
  /// visible, is still detected as the hit area.
  ///
  /// Note: You must set to false the [mouseEnabled] property of the sprite
  /// designated as the hit area. Otherwise, your sprite button might not work
  /// because the sprite designated as the hit area receives the user input
  /// events instead of your sprite button.

  @override
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
