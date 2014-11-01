part of stagexl.display;

class Sprite extends DisplayObjectContainer {

  bool buttonMode = false;
  Sprite hitArea = null;

  Graphics _graphics = null;
  DisplayObject _dropTarget = null;

  Graphics get graphics {
    return (_graphics != null) ? _graphics : _graphics = new Graphics();
  }

  set graphics(Graphics value) => _graphics = value;

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  static Sprite _dragSprite = null;
  static Point<num> _dragSpriteCenter = null;
  static Rectangle<num> _dragSpriteBounds = null;

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

  DisplayObject get dropTarget => _dropTarget;

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

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
