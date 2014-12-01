part of stagexl.display;

/// The Sprite class is a basic display list building block.
/// 
/// It is a display list node that can display graphics and can also contain 
/// children.
class Sprite extends DisplayObjectContainer {

  /// Specifies the button mode of this sprite.
  /// 
  /// If true, this sprite behaves as a button, which means that it triggers the
  /// display of the hand cursor when the pointer passes over the sprite and can
  /// receive a click event if the enter or space keys are pressed when the
  /// sprite has focus. You can suppress the display of the hand cursor by
  /// setting the [useHandCursor] property to false, in which case the pointer
  /// is displayed.
  /// 
  /// Although it is better to use the [SimpleButton] class to create buttons,
  /// you can use the [buttonMode] property to give a sprite some button-like
  /// functionality.
  /// 
  /// To exclude a sprite from the tab order, set the [tabEnabled] property
  /// (inherited from the [InteractiveObject] class and true by default) to
  /// false. 
  /// 
  /// Additionally, consider whether you want the children of your sprite to be
  /// user input enabled. Most buttons do not enable user input interactivity
  /// for their child objects because it confuses the event flow. To disable
  /// user input interactivity for all child objects, you must set the
  /// [mouseChildren] property (inherited from the [DisplayObjectContainer]
  /// class) to false.
  bool buttonMode = false;
  
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
  Sprite hitArea = null;

  Graphics _graphics = null;
  DisplayObject _dropTarget = null;

  /// Specifies the Graphics object that belongs to this sprite where vector 
  /// drawing commands can occur.
  Graphics get graphics {
    return (_graphics != null) ? _graphics : _graphics = new Graphics();
  }

  set graphics(Graphics value) => _graphics = value;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  static Sprite _dragSprite = null;
  static Point<num> _dragSpriteCenter = null;
  static Rectangle<num> _dragSpriteBounds = null;

  /// Lets the user drag the specified sprite. 
  /// 
  /// The sprite remains draggable until explicitly stopped through a call to 
  /// the [stopDrag] method, or until another sprite is made draggable. Only one
  /// sprite is draggable at a time.
  /// 
  /// With [lockCenter] you can specify whether the draggable sprite is locked
  /// to the center of the pointer position (true), or locked to the point where
  /// the user first clicked the sprite (false).
  /// 
  /// [bounds] is the value relative to the coordinates of the Sprite's parent
  /// that specify a constraint rectangle for the Sprite.
  startDrag([bool lockCenter = false, Rectangle<num> bounds = null]) {

    _dragSprite = this;
    _dragSpriteBounds = bounds;

    if (lockCenter) {
      _dragSpriteCenter = this.bounds.center;
    } else {
      var mp = this.mousePosition;
      _dragSpriteCenter = (mp != null) ? mp : new Point<num>(0, 0);
    }

    _updateDrag();
  }

  /// Ends the [startDrag] method.
  /// 
  /// A sprite that was made draggable with the [startDrag] method remains
  /// draggable until a [stopDrag] method is added, or until another sprite
  /// becomes draggable. Only one sprite is draggable at a time.
  stopDrag() {

    if (_dragSprite == this) {
      _dragSprite = null;
      _dragSpriteCenter = null;
      _dragSpriteBounds = null;
    }
  }

  _updateDrag() {

    var mp = this.mousePosition;
    var stage = this.stage;
    var visible = this.visible;

    if (mp != null && this.stage != null) {

      var bounds = _dragSpriteBounds;
      if (bounds != null) {
        var mpParent = this.transformationMatrix.transformPoint(mp);
        if (mpParent.x < bounds.left) mpParent.x = bounds.left;
        if (mpParent.x > bounds.right) mpParent.x = bounds.right;
        if (mpParent.y < bounds.top) mpParent.y = bounds.top;
        if (mpParent.y > bounds.bottom) mpParent.y = bounds.bottom;
        mp = this.transformationMatrix.cloneInvert().transformPoint(mpParent);
      }

      var pivot = new Point(_pivotX, _pivotY).add(mp).subtract(_dragSpriteCenter);
      var location = this.transformationMatrix.transformPoint(pivot);

      this.visible = false;
      _dropTarget = stage.hitTestInput(stage.mouseX, stage.mouseY);

      this.x = location.x;
      this.y = location.y;
      this.visible = visible;
    }
  }

  /// Specifies the display object over which the sprite is being dragged, or on
  /// which the sprite was dropped.
  DisplayObject get dropTarget => _dropTarget;

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    var rectangle = super.bounds;
    if (graphics != null) rectangle.boundingBox(graphics.bounds);
    return rectangle;
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {

    if (this.hitArea != null) {

      var point = new Point(localX, localY);
      this.localToGlobal(point, point);
      this.hitArea.globalToLocal(point, point);

      var target = this.hitArea.hitTestInput(point.x, point.y);
      return target != null ? this : null;
    }

    var target = super.hitTestInput(localX, localY);
    if (target == null && graphics != null) {
      target = graphics.hitTestInput(localX, localY) ? this : null;
    }

    return target;
  }

  @override
  render(RenderState renderState) {
    if (_graphics != null) _graphics.render(renderState);
    super.render(renderState);
  }

}
