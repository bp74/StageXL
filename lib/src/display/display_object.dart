part of stagexl.display;

/// The base class for all objects that can be placed on the display list. 
/// 
/// Use the [DisplayObjectContainer] class to arrange the display objects in the 
/// display list. [DisplayObjectContainer] objects can have child display 
/// objects, while other display objects, such as [Shape] and [TextField] 
/// objects, are "leaf" nodes that have only parents and siblings, no children.
/// 
/// The [DisplayObject] class supports basic functionality like the x and y 
/// position of an object, as well as more advanced properties of the object 
/// such as its transformation matrix.
/// 
/// The [DisplayObject] class itself does not include any APIs for rendering 
/// content onscreen. For that reason, if you want to create a custom subclass 
/// of the [DisplayObject] class, you will want to extend one of its subclasses 
/// that do have APIs for rendering content onscreen, such as the [Shape], 
/// [Sprite], [Bitmap], [SimpleButton], [TextField], or [MovieClip] class.
/// 
/// The [DisplayObject] class contains several [BroadcastEvent]s. Normally, the 
/// target of any particular event is a specific [DisplayObject] instance. For 
/// example, the target of an added event is the specific [DisplayObject] 
/// instance that was added to the display list. Having a single target 
/// restricts the placement of event listeners to that target and in some cases 
/// the target's ancestors on the display list. With [BroadcastEvent]s, however, 
/// the target is not a specific [DisplayObject] instance, but rather all 
/// [DisplayObject] instances, including those that are not on the display list. 
/// This means that you can add a listener to any [DisplayObject] instance to 
/// listen for [BroadcastEvent]s. 
abstract class DisplayObject
    extends EventDispatcher
    implements RenderObject, TweenObject, BitmapDrawable {

  static int _nextID = 0;
  final int displayObjectID = _nextID++;

  num _x = 0.0;
  num _y = 0.0;
  num _pivotX = 0.0;
  num _pivotY = 0.0;
  num _scaleX = 1.0;
  num _scaleY = 1.0;
  num _skewX = 0.0;
  num _skewY = 0.0;
  num _rotation = 0.0;

  num _alpha = 1.0;
  bool _visible = true;
  bool _off = false; // disable rendering

  Mask _mask = null;
  BlendMode _blendMode = null;
  List<BitmapFilter> _filters = [];
  RenderTextureQuad _cacheTextureQuad = null;
  bool _cacheDebugBorder = false;

  String _name = "";
  DisplayObjectContainer _parent = null;

  final Matrix _tmpMatrix = new Matrix.fromIdentity();
  final Matrix _transformationMatrix = new Matrix.fromIdentity();
  bool _transformationMatrixRefresh = true;

  @deprecated Shadow shadow;
  @deprecated String compositeOperation;

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> addedEvent = const EventStreamProvider<Event>(Event.ADDED);
  static const EventStreamProvider<Event> removedEvent = const EventStreamProvider<Event>(Event.REMOVED);
  static const EventStreamProvider<Event> addedToStageEvent = const EventStreamProvider<Event>(Event.ADDED_TO_STAGE);
  static const EventStreamProvider<Event> removedFromStageEvent = const EventStreamProvider<Event>(Event.REMOVED_FROM_STAGE);

  // Providers for Broadcast Events
  static const EventStreamProvider<EnterFrameEvent> enterFrameEvent = const EventStreamProvider<EnterFrameEvent>(Event.ENTER_FRAME);
  static const EventStreamProvider<ExitFrameEvent> exitFrameEvent = const EventStreamProvider<ExitFrameEvent>(Event.EXIT_FRAME);
  static const EventStreamProvider<RenderEvent> renderEvent = const EventStreamProvider<RenderEvent>(Event.RENDER);

  /// Dispatched when a display object is added to the display list. 
  /// 
  /// The following methods trigger this event: 
  /// 
  /// * [DisplayObjectContainer.addChild]
  /// * [DisplayObjectContainer.addChildAt]
  EventStream<Event> get onAdded => DisplayObject.addedEvent.forTarget(this);
  
  /// Dispatched when a display object is about to be removed from the display 
  /// list. 
  /// 
  /// Two methods of the [DisplayObjectContainer] class generate this event: 
  /// 
  /// * [DisplayObjectContainer.removeChild]
  /// * [DisplayObjectContainer.removeChildAt]
  /// 
  /// The following methods of a [DisplayObjectContainer] object also generate 
  /// this event if an object must be removed to make room for the new object: 
  /// 
  /// * [DisplayObjectContainer.addChild] 
  /// * [DisplayObjectContainer.addChildAt]
  /// * [DisplayObjectContainer.setChildIndex]
  EventStream<Event> get onRemoved => DisplayObject.removedEvent.forTarget(this);
  
  /// Dispatched when a display object is added to the on stage display list, 
  /// either directly or through the addition of a sub tree in which the display 
  /// object is contained. 
  /// 
  /// The following methods trigger this event: 
  /// 
  /// * [DisplayObjectContainer.addChild]
  /// * [DisplayObjectContainer.addChildAt]
  EventStream<Event> get onAddedToStage => DisplayObject.addedToStageEvent.forTarget(this);
  
  /// Dispatched when a display object is about to be removed from the display 
  /// list, either directly or through the removal of a sub tree in which the 
  /// display object is contained. 
  /// 
  /// Two methods of the [DisplayObjectContainer] class generate this event: 
  /// 
  /// * [DisplayObjectContainer.removeChild]
  /// * [DisplayObjectContainer.removeChildAt]
  /// 
  /// The following methods of a [DisplayObjectContainer] object also generate 
  /// this event if an object must be removed to make room for the new object: 
  /// 
  /// * [DisplayObjectContainer.addChild] 
  /// * [DisplayObjectContainer.addChildAt]
  /// * [DisplayObjectContainer.setChildIndex]
  EventStream<Event> get onRemovedFromStage => DisplayObject.removedFromStageEvent.forTarget(this);

  /// Dispatched when a frame is entered. 
  /// 
  /// This event is a broadcast event, which means that it is dispatched by all 
  /// display objects with a listener registered for this event.
  EventStream<EnterFrameEvent> get onEnterFrame => DisplayObject.enterFrameEvent.forTarget(this);
  
  /// Dispatched when a frame is exited. All frame scripts have been run. 
  /// 
  /// This event is a broadcast event, which means that it is dispatched by all 
  /// display objects with a listener registered for this event.
  EventStream<ExitFrameEvent> get onExitFrame => DisplayObject.exitFrameEvent.forTarget(this);
  
  /// Dispatched when the display list is about to be updated and rendered.
  /// 
  /// This event provides the last opportunity for objects listening for this 
  /// event to make changes before the display list is rendered. You must call 
  /// the [Stage.invalidate] method each time you want a render event to be 
  /// dispatched. This event is a broadcast event, which means that it is 
  /// dispatched by all display objects with a listener registered for this 
  /// event.
  EventStream<RenderEvent> get onRender => DisplayObject.renderEvent.forTarget(this);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  /// The user-defined data associated with this display object.
  dynamic userData = null;

  /// The x-coordinate of the [DisplayObject] instance relative to the 
  /// local coordinates of the parent [DisplayObjectContainer]. 
  /// 
  /// If the object is inside a [DisplayObjectContainer] that has 
  /// transformations, it is in the local coordinate system of the enclosing 
  /// [DisplayObjectContainer].
  num get x => _x;
  
  set x(num value) {
    if (value is num) _x = value;
    _transformationMatrixRefresh = true;
  }

  /// The y-coordinate of the [DisplayObject] instance relative to the 
  /// local coordinates of the parent [DisplayObjectContainer]. 
  /// 
  /// If the object is inside a [DisplayObjectContainer] that has 
  /// transformations, it is in the local coordinate system of the enclosing 
  /// [DisplayObjectContainer].
  num get y => _y;
  
  set y(num value) {
    if (value is num) _y = value;
    _transformationMatrixRefresh = true;
  }

  /// The x-coordinate of the pivot point of this [DisplayObject]. 
  /// 
  /// The pivot point is the point this [DisplayObject] rotates around. It is 
  /// also the anchor point for the x/y-coordinates and the center for all 
  /// transformations like scaling.
  /// 
  /// The default pivot point is (0,0).
  num get pivotX => _pivotX;
  
  set pivotX(num value) {
    if (value is num) _pivotX = value;
    _transformationMatrixRefresh = true;
  }

  /// The y-coordinate of the pivot point of this [DisplayObject].
  /// 
  /// The pivot point is the point this [DisplayObject] rotates around. It is 
  /// also the anchor point for the x/y-coordinates and the center for all 
  /// transformations like scaling.
  /// 
  /// The default pivot point is (0,0).
  num get pivotY => _pivotY;
  
  set pivotY(num value) {
    if (value is num) _pivotY = value;
    _transformationMatrixRefresh = true;
  }
  
  /// The horizontal scale (percentage) of the object as applied from the 
  /// pivot point. 
  /// 
  /// 1.0 equals 100% scale.
  /// 
  /// Scaling the local coordinate system changes the x and y property values, 
  /// which are defined in whole pixels.
  num get scaleX => _scaleX;
  
  set scaleX(num value) {
    if (value is num) _scaleX = value;
    _transformationMatrixRefresh = true;
  }

  /// The vertical scale (percentage) of the object as applied from the 
  /// pivot point. 
  /// 
  /// 1.0 equals 100% scale.
  /// 
  /// Scaling the local coordinate system changes the x and y property values, 
  /// which are defined in whole pixels.
  num get scaleY => _scaleY;
  
  set scaleY(num value) {
    if (value is num) _scaleY = value;
    _transformationMatrixRefresh = true;
  }
  
  /// The horizontal skew of this object.
  num get skewX => _skewX;
  
  set skewX(num value) {
    if (value is num) _skewX = value;
    _transformationMatrixRefresh = true;
  }

  /// The vertical skew of this object.
  num get skewY => _skewY;
  
  set skewY(num value) {
    if (value is num) _skewY = value;
    _transformationMatrixRefresh = true;
  }

  /// The rotation of this [DisplayObject], in radians, from its original 
  /// orientation.
  /// 
  ///     // Convert from degrees to radians.
  ///     this.rotation = degrees * math.PI / 180;
  ///     
  ///     // Convert from radians to degrees.
  ///     num degrees = this.rotation * 180 / math.PI;
  num get rotation => _rotation;
  
  set rotation(num value) {
    if (value is num) _rotation = value;
    _transformationMatrixRefresh = true;
  }

  /// The visibility and availability of the display object. 
  /// 
  /// Display objects that are not visible are disabled. For example, if 
  /// visible=false for an [InteractiveObject] instance, it cannot be clicked.
  bool get visible => _visible;

  set visible(bool value) {
    if (value is bool) _visible = value;
  }
  
  /// The availability and visibility of the display object.
  /// 
  /// Turning off a display object has the same effect as setting the 
  /// [visible] property. This property exists only for compatibility 
  /// reasons to the 'Toolkit for Dart' (a Dart/StageXL code generator 
  /// for Adobe Flash Professional). 
  /// 
  /// It's recommended that you use [visible] instead of this property.
  bool get off => _off;

  set off(bool value) {
    if (value is bool) _off = value;
  }
  
  /// The alpha transparency value of the object specified. 
  /// 
  /// Valid values are 0 (fully transparent) to 1 (fully opaque). The default 
  /// value is 1. Display objects with alpha set to 0 are active, even though 
  /// they are invisible.
  num get alpha => _alpha;

  set alpha(num value) {
    if (value is num) {
      // Clamp values and convert possible integers to double.
      if (value <= 0) value = 0.0;
      if (value >= 1) value = 1.0;
      _alpha = value;
    }
  }

  /// The calling display object is masked by the specified mask object. 
  /// 
  /// By default, a [Mask] is applied relative to this [DisplayObject]. If 
  /// [Mask.relativeToParent] is set to true, the [Mask] is applied relative 
  /// to the parent [DisplayObject]. 
  Mask get mask => _mask;
  
  set mask(Mask value) {
    _mask = value;
  }

  /// The filters currently associated with this [DisplayObject].
  List<BitmapFilter> get filters => _filters;
  
  set filters(List<BitmapFilter> value) {
    _filters = value;
  }

  /// A value from the [BlendMode] class that specifies which blend mode to use. 
  /// 
  /// The blendMode property affects each pixel of the display object. Each 
  /// pixel is composed of three constituent colors (red, green, and blue), and 
  /// each constituent color has a value between 0x00 and 0xFF. StageXL compares 
  /// each constituent color of one pixel with the corresponding color of the 
  /// pixel in the background.
  BlendMode get blendMode => _blendMode;
  
  set blendMode(BlendMode value) {
    _blendMode = value;
  }

  /// The instance name of this [DisplayObject]. 
  /// 
  /// The object can be identified in the child list of its parent display 
  /// object container by calling [DisplayObjectContainer.getChildByName].
  String get name => _name;
  
  set name(String value) {
    _name = value;
  }

  // TODO (marcojakob): Document the cache.
  RenderTextureQuad get cache => _cacheTextureQuad;

  /// The [DisplayObjectContainer] object that contains this display object. 
  /// 
  /// Use the parent property to specify a relative path to display objects that 
  /// are above the current display object in the display list hierarchy.
  DisplayObjectContainer get parent => _parent;
  
  /// Returns a rectangle that defines the area of this [DisplayObject].
  Rectangle<num> get bounds => getBoundsTransformed(_identityMatrix);

  //----------------------------------------------------------------------------

  /// The position of the mouse relative to the local coordinate system of 
  /// the display object.
  Point<num> get mousePosition {
    var stage = this.stage;
    return (stage != null) ? this.globalToLocal(stage._mousePosition) : null;
  }

  /// The x-coordinate of the mouse relative to the local coordinate system of 
  /// the display object.
  num get mouseX {
    var mp = this.mousePosition;
    return (mp != null) ? mp.x : 0.0;
  }

  /// The y-coordinate of the mouse relative to the local coordinate system of 
  /// the display object.
  num get mouseY {
    var mp = this.mousePosition;
    return (mp != null) ? mp.y : 0.0;
  }

  //----------------------------------------------------------------------------

  /// The top-most display object in the portion of the display list's tree 
  /// structure.
  DisplayObject get root {
    DisplayObject currentObject = this;

    while (currentObject._parent != null)
      currentObject = currentObject._parent;

    return currentObject;
  }

  /// The Stage of this [DisplayObject]. 
  /// 
  /// If a [DisplayObject] is not added to the display list, its stage property 
  /// is set to null.
  Stage get stage {
    DisplayObject root = this.root;
    return (root is Stage) ? root : null;
  }

  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------

  /// Sets transformation properties. 
  /// 
  /// This method exists only for compatibility reasons to the 'Toolkit for 
  /// Dart' (a Dart/StageXL code generator for Adobe Flash Professional).
  /// 
  /// It's recommended that you use the setters of [x], [y], [scaleX], etc. 
  /// directly instead of calling this method.
  void setTransform(num x, num y, [num scaleX, num scaleY, num rotation, 
                                   num skewX, num skewY, num pivotX, num pivotY]) {
    if (x is num) _x = x;
    if (y is num) _y = y;
    if (scaleX is num) _scaleX = scaleX;
    if (scaleY is num) _scaleY = scaleY;
    if (rotation is num) _rotation = rotation;
    if (skewX is num) _skewX = skewX;
    if (skewY is num) _skewY = skewY;
    if (pivotX is num) _pivotX = pivotX;
    if (pivotY is num) _pivotY = pivotY;
    _transformationMatrixRefresh = true;
  }

  //----------------------------------------------------------------------------

  /// The width of this [DisplayObject], in stage coordinates. 
  /// 
  /// The width is calculated based on the bounds of the content of the 
  /// [DisplayObject]. When you set the width property, the [scaleX] property is 
  /// adjusted accordingly.
  num get width => getBoundsTransformed(this.transformationMatrix).width;

  void set width(num value) {
    this.scaleX = 1;
    num normalWidth = this.width;
    this.scaleX = (normalWidth != 0.0) ? value / normalWidth : 1.0;
  }

  /// The height of this [DisplayObject], in stage coordinates. 
  /// 
  /// The height is calculated based on the bounds of the content of the 
  /// [DisplayObject]. When you set the width property, the [scaleY] property is 
  /// adjusted accordingly.
  num get height => getBoundsTransformed(this.transformationMatrix).height;
  
  void set height(num value) {
    this.scaleY = 1;
    num normalHeight = this.height;
    this.scaleY = (normalHeight != 0.0) ? value / normalHeight : 1.0;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Convenience method to add this [DisplayObject] to the specified [parent].
  void addTo(DisplayObjectContainer parent) {
    parent.addChild(this);
  }

  /// Removes this [DisplayObject] from its parent.
  void removeFromParent() {
    if (_parent != null) {
      _parent.removeChild(this);
    }
  }

  //----------------------------------------------------------------------------

  /// The transformation matrix.
  Matrix get transformationMatrix {
    /*
    _transformationMatrix.identity();
    _transformationMatrix.translate(-_pivotX, -_pivotY);
    _transformationMatrix.scale(_scaleX, _scaleY);
    _transformationMatrix.rotate(_rotation);
    _transformationMatrix.translate(_x, _y);
    */

    if (_transformationMatrixRefresh) {

      _transformationMatrixRefresh = false;

      num skewXrotation =  _skewX + _rotation;
      num skewYrotation =  _skewY + _rotation;
      num scaleX = _scaleX;
      num scaleY = _scaleY;
      num pivotX = _pivotX;
      num pivotY = _pivotY;

      // ToDo: https://bugzilla.mozilla.org/show_bug.cgi?id=661452
      if (scaleX > -0.0001 && scaleX < 0.0001) scaleX = (scaleX >= 0) ? 0.0001 : -0.0001;
      if (scaleY > -0.0001 && scaleY < 0.0001) scaleY = (scaleY >= 0) ? 0.0001 : -0.0001;

      if (skewXrotation == 0.0 && skewYrotation == 0.0) {

        _transformationMatrix.setTo(scaleX, 0.0, 0.0, scaleY, _x - pivotX * scaleX, _y - pivotY * scaleY);

      } else {

        num a, b, c, d;
        num cosX = cos(skewXrotation);
        num sinX = sin(skewXrotation);

        if (skewXrotation == skewYrotation) {
          a =   scaleX * cosX;
          b =   scaleX * sinX;
          c = - scaleY * sinX;
          d =   scaleY * cosX;
        } else {
          a =   scaleX * cos(skewYrotation);
          b =   scaleX * sin(skewYrotation);
          c = - scaleY * sinX;
          d =   scaleY * cosX;
        }

        num tx =  _x - (pivotX * a + pivotY * c);
        num ty =  _y - (pivotX * b + pivotY * d);

        _transformationMatrix.setTo(a, b, c, d, tx, ty);
      }
    }

    return _transformationMatrix;
  }

  //----------------------------------------------------------------------------

  Matrix transformationMatrixTo(DisplayObject targetSpace) {

    if (targetSpace == this) {
      return new Matrix.fromIdentity();
    }

    if (targetSpace == _parent) {
      return this.transformationMatrix.clone();
    }

    if (targetSpace != null && targetSpace._parent == this) {
      return targetSpace.transformationMatrix.cloneInvert();
    }

    //------------------------------------------------

    Matrix resultMatrix = new Matrix.fromIdentity();
    DisplayObject resultObject = this;

    while (resultObject != targetSpace && resultObject._parent != null) {
      resultMatrix.concat(resultObject.transformationMatrix);
      resultObject = resultObject._parent;
    }

    if (targetSpace == null && resultObject != null) {
      resultMatrix.concat(resultObject.transformationMatrix);
      resultObject = null;
    }

    if (resultObject == targetSpace) {
      return resultMatrix;
    }

    //------------------------------------------------

    Matrix targetMatrix = new Matrix.fromIdentity();
    DisplayObject targetObject = targetSpace;

    while (targetObject != this && targetObject._parent != null) {
      targetMatrix.concat(targetObject.transformationMatrix);
      targetObject = targetObject._parent;
    }

    targetMatrix.invert();

    if (targetObject == this) {
      return targetMatrix;
    }

    if (targetObject != resultObject) {
      return null;
    }

    resultMatrix.concat(targetMatrix);

    return resultMatrix;
  }

  //----------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    if (returnRectangle != null) {
      returnRectangle.setTo(matrix.tx, matrix.ty, 0, 0);
    } else {
      returnRectangle = new Rectangle<num>(matrix.tx, matrix.ty, 0, 0);
    }

    return returnRectangle;
  }

  //----------------------------------------------------------------------------

  /// Returns the bounds of this [DisplayObject] relative to the specified 
  /// [targetSpace].
  Rectangle<num> getBounds(DisplayObject targetSpace) {

    var returnRectangle = new Rectangle<num>(0, 0, 0, 0);
    var matrix = (targetSpace == null) ? transformationMatrix : transformationMatrixTo(targetSpace);

    return (matrix != null) ? getBoundsTransformed(matrix, returnRectangle) : returnRectangle;
  }

  //----------------------------------------------------------------------------

  bool hitTestObject(DisplayObject other) {

    var stage1 = this.stage;
    var stage2 = other.stage;

    if (stage1 == null || stage2 == null || stage1 != stage2) return false;

    var rect1 = this.getBounds(stage1);
    var rect2 = other.getBounds(stage2);

    return rect1.intersects(rect2);
  }

  //----------------------------------------------------------------------------

  /// Evaluates this [DisplayObject] to see if it overlaps or intersects with 
  /// the point specified by the [x] and [y] parameters. 
  /// 
  /// The [x] and [y] parameters specify a point in the coordinate space of the 
  /// [Stage], not the [DisplayObjectContainer] that contains the 
  /// [DisplayObject] (unless that display object container is the Stage).
  /// 
  /// If [shapeFlag] is set to false (the default), the check is done against 
  /// the bounding box. If true, the check is done against the actual pixels
  /// of the object.
  /// 
  /// Returns true if this [DisplayObject] overlaps or intersects with the 
  /// specified point; false otherwise.
  bool hitTestPoint(num x, num y, [bool shapeFlag = false]) {

    var stage = this.stage;
    if (stage == null) return false;

    if (shapeFlag) {
      var matrix = stage.transformationMatrixTo(this);
      if (matrix == null) return false;

      var stagePoint = new Point<num>(x, y);
      var localPoint = matrix.transformPoint(stagePoint);

      return this.hitTestInput(localPoint.x, localPoint.y) != null;

    } else {

      var rect = this.getBounds(stage);
      return rect.contains(x, y);
    }
  }

  //----------------------------------------------------------------------------

  /// Evaluates this [DisplayObject] to see if the coordinates [localX] and 
  /// [localY] are inside this [DisplayObject].
  /// 
  /// If the coordinates are inside, this [DisplayObject] is returned; null
  /// otherwise.
  /// 
  /// [localX] and [localY] are relative to to the origin (0,0) of this
  /// [DisplayObject] (local coordinates).
  DisplayObject hitTestInput(num localX, num localY) {
    return getBoundsTransformed(_identityMatrix).contains(localX, localY) ? this : null;
  }

  //----------------------------------------------------------------------------

  /// Converts the point object from this [DisplayObject]'s (local) coordinates 
  /// to the [Stage] (global) coordinates.
  /// 
  /// This method allows you to convert any given x- and y-coordinates from 
  /// values that are relative to the origin (0,0) of a specific display object 
  /// (local coordinates) to values that are relative to the origin of the 
  /// [Stage] (global coordinates).
  Point<num> localToGlobal(Point<num> localPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    return _tmpMatrix.transformPoint(localPoint);
  }

  //----------------------------------------------------------------------------

  /// Converts the point object from the [Stage] (global) coordinates to this 
  /// [DisplayObject]'s (local) coordinates. 
  /// 
  /// This method allows you to convert any given x- and y-coordinates from 
  /// values that are relative to the origin of the [Stage] (global coordinates) 
  /// to values that are relative to the origin (0,0) of a specific display 
  /// object (local coordinates).
  Point<num> globalToLocal(Point<num> globalPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    _tmpMatrix.invert();

    return _tmpMatrix.transformPoint(globalPoint);
  }

  //----------------------------------------------------------------------------

  /// Caches a rectangular area of this [DisplayObject] for better performance.
  ///
  /// If the cached area changes, the cache must be refreshed using 
  /// [refreshCache] or removed using [removeCache]. Calling [applyCache] again 
  /// with the same parameters will refresh the cache.
  void applyCache(int x, int y, int width, int height, {bool debugBorder: false}) {

    var pixelRatio = Stage.autoHiDpi ? env.devicePixelRatio : 1.0;

    var renderTexture = _cacheTextureQuad == null
        ? new RenderTexture(width, height, true, Color.Transparent, pixelRatio)
        : _cacheTextureQuad.renderTexture..resize(width, height);

    _cacheTextureQuad = new RenderTextureQuad(renderTexture, 0, x, y, 0, 0, width, height);
    _cacheDebugBorder = debugBorder;

    refreshCache();
  }

  /// Refreshes the cached area of this [DisplayObject].
  void refreshCache() {

    if (_cacheTextureQuad == null) return;

    var canvas = _cacheTextureQuad.renderTexture.canvas;
    var matrix = _cacheTextureQuad.drawMatrix;
    var renderContext = new RenderContextCanvas(canvas);
    var renderState = new RenderState(renderContext, matrix);

    renderContext.clear(Color.Transparent);
    render(renderState);

    if (_filters != null) {
      var cacheBitmapData = new BitmapData.fromRenderTextureQuad(_cacheTextureQuad);
      for(int i = 0; i < _filters.length; i++) {
        _filters[i].apply(cacheBitmapData);
      }
    }

    if (_cacheDebugBorder) {
      canvas.context2D
          ..setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
          ..lineWidth = 1
          ..lineJoin = "miter"
          ..lineCap = "butt"
          ..strokeStyle = "#FF00FF"
          ..strokeRect(0.5, 0.5, canvas.width - 1, canvas.height - 1);
    }

    _cacheTextureQuad.renderTexture.update();
  }

  /// Removes the previousely cached area of this [DisplayObject].
  void removeCache() {
    if (_cacheTextureQuad != null) {
      _cacheTextureQuad.renderTexture.dispose();
      _cacheTextureQuad = null;
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  void dispatchEvent(Event event) {

    List<EventDispatcher> ancestors = null;

    if (event.captures || event.bubbles) {
      for(DisplayObject ancestor = parent; ancestor != null; ancestor = ancestor.parent) {
        if(ancestor.hasEventListenersFor(event)) {
          if (ancestors == null) ancestors = [];
          ancestors.add(ancestor);
        }
      }
    }

    if (ancestors != null && event.captures) {
      for(int i = ancestors.length - 1 ; i >= 0; i--) {
        ancestors[i].dispatchEventRaw(event, this, EventPhase.CAPTURING_PHASE);
        if (event.stopsPropagation) return;
      }
    }

    dispatchEventRaw(event, this, EventPhase.AT_TARGET);
    if (event.stopsPropagation) return;

    if (ancestors != null && event.bubbles) {
      for(int i = 0; i < ancestors.length; i++) {
        ancestors[i].dispatchEventRaw(event, this, EventPhase.BUBBLING_PHASE);
        if (event.stopsPropagation) return;
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Renders this [DisplayObject].
  void render(RenderState renderState);

}

