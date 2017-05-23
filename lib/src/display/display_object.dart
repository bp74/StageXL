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
    implements RenderObject, TweenObject2D, BitmapDrawable {

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
  bool _off = false;

  Mask _mask;
  BlendMode _blendMode;
  List<BitmapFilter> _filters = <BitmapFilter>[];
  _DisplayObjectCache _cache;

  String _name = "";
  DisplayObjectParent _parent;

  final Matrix _transformationMatrix = new Matrix.fromIdentity();
  bool _transformationMatrixRefresh = true;

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> addedEvent = const EventStreamProvider<Event>(Event.ADDED);
  static const EventStreamProvider<Event> removedEvent = const EventStreamProvider<Event>(Event.REMOVED);
  static const EventStreamProvider<Event> addedToStageEvent = const EventStreamProvider<Event>(Event.ADDED_TO_STAGE);
  static const EventStreamProvider<Event> removedFromStageEvent = const EventStreamProvider<Event>(Event.REMOVED_FROM_STAGE);

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

  dynamic userData;

  /// The x-coordinate of is display object relative to the
  /// local coordinates of the parent [DisplayObjectContainer].
  ///
  /// If the object is inside a [DisplayObjectContainer] that has
  /// transformations, it is in the local coordinate system of the enclosing
  /// [DisplayObjectContainer].

  @override
  num get x => _x;

  @override
  set x(num value) {
    if (value is num) _x = value;
    _transformationMatrixRefresh = true;
  }

  /// The y-coordinate of this display object relative to the
  /// local coordinates of the parent [DisplayObjectContainer].
  ///
  /// If the object is inside a [DisplayObjectContainer] that has
  /// transformations, it is in the local coordinate system of the enclosing
  /// [DisplayObjectContainer].

  @override
  num get y => _y;

  @override
  set y(num value) {
    if (value is num) _y = value;
    _transformationMatrixRefresh = true;
  }

  /// The x-coordinate of the pivot point of this display object.
  ///
  /// The pivot point is the point this display Object rotates around. It is
  /// also the anchor point for the x/y-coordinates and the center for all
  /// transformations like scaling.
  ///
  /// The default pivot point is (0,0).

  @override
  num get pivotX => _pivotX;

  @override
  set pivotX(num value) {
    if (value is num) _pivotX = value;
    _transformationMatrixRefresh = true;
  }

  /// The y-coordinate of the pivot point of this display object.
  ///
  /// The pivot point is the point this display object rotates around. It is
  /// also the anchor point for the x/y-coordinates and the center for all
  /// transformations like scaling.
  ///
  /// The default pivot point is (0,0).

  @override
  num get pivotY => _pivotY;

  @override
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

  @override
  num get scaleX => _scaleX;

  @override
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

  @override
  num get scaleY => _scaleY;

  @override
  set scaleY(num value) {
    if (value is num) _scaleY = value;
    _transformationMatrixRefresh = true;
  }

  /// The horizontal skew of this object.

  @override
  num get skewX => _skewX;

  @override
  set skewX(num value) {
    if (value is num) _skewX = value;
    _transformationMatrixRefresh = true;
  }

  /// The vertical skew of this object.

  @override
  num get skewY => _skewY;

  @override
  set skewY(num value) {
    if (value is num) _skewY = value;
    _transformationMatrixRefresh = true;
  }

  /// The rotation of this display object, in radians, from its original
  /// orientation.
  ///
  ///     // Convert from degrees to radians.
  ///     this.rotation = degrees * math.PI / 180;
  ///
  ///     // Convert from radians to degrees.
  ///     num degrees = this.rotation * 180 / math.PI;

  @override
  num get rotation => _rotation;

  @override
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
  /// Turning off a display object is similar to setting the [visible] property.
  /// The [off] property is used by third party runtimes like StageXL_GAF and
  /// StageXL_Toolkit to disable a DisplayObject without changing the [visible]
  /// state or removing it from the container. It's recommended that users
  /// do not use [off] but [visible] instead.

  bool get off => _off;

  set off(bool value) {
    if (value is bool) _off = value;
  }

  /// The alpha transparency value of the object specified.
  ///
  /// Valid values are 0 (fully transparent) to 1 (fully opaque). The default
  /// value is 1. Display objects with alpha set to 0 are active, even though
  /// they are invisible.

  @override
  num get alpha => _alpha;

  @override
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
  /// By default, a [Mask] is applied relative to this display object. If
  /// [Mask.relativeToParent] is set to true, the [Mask] is applied relative
  /// to the parent display object.

  @override
  Mask get mask => _mask;

  set mask(Mask value) {
    _mask = value;
  }

  /// The filters currently associated with this display object.

  @override
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

  @override
  BlendMode get blendMode => _blendMode;

  set blendMode(BlendMode value) {
    _blendMode = value;
  }

  /// The instance name of this display object.
  ///
  /// The object can be identified in the child list of its parent display
  /// object container by calling [DisplayObjectContainer.getChildByName].

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  /// This getter gives you access to the underlying [RenderTextureQuad] if
  /// a cache is applied to this display object. If no cache is applied this
  /// value is ´null´.
  ///
  /// See also [applyCache], [refreshCache] and [removeCache].

  @override
  RenderTextureQuad get cache {
    return _cache != null ? _cache.renderTextureQuad : null;
  }

  /// The [DisplayObjectContainer] object that contains this display object.
  ///
  /// Use the parent property to specify a relative path to display objects that
  /// are above the current display object in the display list hierarchy.

  DisplayObjectParent get parent => _parent;

  //----------------------------------------------------------------------------

  /// The position of the mouse relative to the local coordinate system of
  /// the display object.

  Point<num> get mousePosition {
    var stage = this.stage;
    if (stage == null) return null;
    var localPoint = new Point<num>(0.0, 0.0);
    return this.globalToLocal(stage.mousePosition, localPoint);
  }

  /// The x-coordinate of the mouse relative to the local coordinate system of
  /// the display object.
  ///
  /// If you need both [mouseX] and [mouseY], it is more efficient to use the
  /// [mousePosition] getter.

  num get mouseX {
    var mp = this.mousePosition;
    return (mp != null) ? mp.x : 0.0;
  }

  /// The y-coordinate of the mouse relative to the local coordinate system of
  /// the display object.
  ///
  /// If you need both [mouseX] and [mouseY], it is more efficient to use the
  /// [mousePosition] getter.

  num get mouseY {
    var mp = this.mousePosition;
    return (mp != null) ? mp.y : 0.0;
  }

  //----------------------------------------------------------------------------

  /// The top-most display object in the portion of the display list's tree
  /// structure.

  DisplayObject get root {
    DisplayObject obj = this;
    while(obj.parent != null) obj = obj.parent;
    return obj;
  }

  /// The [Stage] of this display object.
  ///
  /// If this display object is not added to the display list,
  /// the [stage] property returns null.

  Stage get stage {
    DisplayObject root = this.root;
    return (root is Stage) ? root : null;
  }

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

  /// The width of this display object with the applied transformation.
  ///
  /// Setting the width may change the [scaleX], [scaleY], [skewX] and [skewY]
  /// properties, depending on the previously applied transformation.

  num get width => this.boundsTransformed.width;

  set width(num value) {
    var bounds = this.bounds;
    var matrix = this.transformationMatrix;
    var boundsTransformed = matrix.transformRectangle(bounds, bounds);
    var scale = value / boundsTransformed.width;
    var ma = scale.isFinite ? matrix.a * scale : 1.0;
    var mc = scale.isFinite ? matrix.c * scale : 0.0;
    _reverseMatrix(ma, matrix.b, mc, matrix.d);
  }

  /// The height of this display object with the applied transformation.
  ///
  /// Setting the height may change the [scaleX], [scaleY], [skewX] and [skewY]
  /// properties, depending on the previously applied transformation.

  num get height => this.boundsTransformed.height;

  set height(num value) {
    var bounds = this.bounds;
    var matrix = this.transformationMatrix;
    var boundsTransformed = matrix.transformRectangle(bounds, bounds);
    var scale = value / boundsTransformed.height;
    var mb = scale.isFinite ? matrix.b * scale : 0.0;
    var md = scale.isFinite ? matrix.d * scale : 1.0;
    _reverseMatrix(matrix.a, mb, matrix.c, md);
  }

  //----------------------------------------------------------------------------

  /// The transformation matrix of this display object relative to
  /// this display object's parent.
  ///
  /// The transformation matrix is calculated according the following
  /// properties of this display object: [x], [y], [pivotX], [pivotY],
  /// [rotation], [scaleX], [scaleY], [skewX] and [skewY]

  @override
  Matrix get transformationMatrix {

    // _transformationMatrix.identity();
    // _transformationMatrix.translate(-_pivotX, -_pivotY);
    // _transformationMatrix.scale(_scaleX, _scaleY);
    // _transformationMatrix.rotate(_rotation);
    // _transformationMatrix.translate(_x, _y);

    if (_transformationMatrixRefresh) {

      _transformationMatrixRefresh = false;

      var matrix = _transformationMatrix;
      num rotation = _rotation;
      num scaleX = _scaleX;
      num scaleY = _scaleY;
      num skewX = _skewX;
      num skewY = _skewY;

      // Having a scale of 0 is bad, the matrix.det gets zero which causes
      // infinite values on a inverted matrix. It also causes a bug on
      // Firefox in some Linux distrubutions:
      // https://bugzilla.mozilla.org/show_bug.cgi?id=661452

      if (scaleX > -0.0001 && scaleX < 0.0001) scaleX = (scaleX >= 0) ? 0.0001 : -0.0001;
      if (scaleY > -0.0001 && scaleY < 0.0001) scaleY = (scaleY >= 0) ? 0.0001 : -0.0001;

      if (skewX != 0.0 || skewY != 0.0) {
        num ma = scaleX * cos(skewY + rotation);
        num mb = scaleX * sin(skewY + rotation);
        num mc = -scaleY * sin(skewX + rotation);
        num md = scaleY * cos(skewX + rotation);
        num mx = _x - _pivotX * ma - _pivotY * mc;
        num my = _y - _pivotX * mb - _pivotY * md;
        matrix.setTo(ma, mb, mc, md, mx, my);
      } else if (rotation != 0.0) {
        num cr = cos(rotation);
        num sr = sin(rotation);
        num ma = scaleX * cr;
        num mb = scaleX * sr;
        num mc = -scaleY * sr;
        num md = scaleY * cr;
        num mx = _x - _pivotX * ma - _pivotY * mc;
        num my = _y - _pivotX * mb - _pivotY * md;
        matrix.setTo(ma, mb, mc, md, mx, my);
      } else {
        num mx = _x - _pivotX * scaleX;
        num my = _y - _pivotY * scaleY;
        matrix.setTo(scaleX, 0.0, 0.0, scaleY, mx, my);
      }
    }

    return _transformationMatrix;
  }

  //----------------------------------------------------------------------------

  /// The global 2D transformation matrix of this display object.
  ///
  /// Note: You can get the global transformation matrix either with the
  /// [globalTransformationMatrix] or the [globalTransformationMatrix3D]
  /// getter. You only need to use a 3D transformation matrix if
  /// you are working with 3D display objects.

  Matrix get globalTransformationMatrix {

    var result = new Matrix.fromIdentity();

    for (var obj = this; obj != null; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        throw new StateError("Can't calculate 2D matrix for 3D display object.");
      } else {
        result.concat(obj.transformationMatrix);
      }
    }

    return result;
  }

  /// The global 3D transformation matrix of this display object.
  ///
  /// Note: You can get the global transformation matrix either with the
  /// [globalTransformationMatrix] or the [globalTransformationMatrix3D]
  /// getter. You only need to use a 3D transformation matrix if
  /// you are working with 3D display objects.

  Matrix3D get globalTransformationMatrix3D {

    var result = new Matrix3D.fromIdentity();

    for (var obj = this; obj != null; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        result.concat(obj.projectionMatrix3D);
      }
      result.concat2D(obj.transformationMatrix);
    }

    return result;
  }

  //----------------------------------------------------------------------------

  /// The 2D transformation matrix relative to the given [targetSpace].
  ///
  /// Note: You can get the transformation matrix either with the
  /// [getTransformationMatrix] or the [getTransformationMatrix3D]
  /// method. You only need to use a 3D transformation matrix if
  /// you are working with 3D display objects.

  Matrix getTransformationMatrix(DisplayObject targetSpace) {

    if (targetSpace == null) return this.globalTransformationMatrix;
    if (targetSpace == this) return new Matrix.fromIdentity();

    var ancestor = _getCommonAncestor(targetSpace);
    if (ancestor == null) return null;

    var resultMatrix = new Matrix.fromIdentity();
    for (var obj = this; obj != ancestor; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        throw new StateError("Can't calculate 2D matrix for 3D display object.");
      }
      resultMatrix.concat(obj.transformationMatrix);
    }

    if (identical(targetSpace, ancestor)) return resultMatrix;

    var targetMatrix = new Matrix.fromIdentity();
    for (var obj = targetSpace; obj != ancestor; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        throw new StateError("Can't calculate 2D matrix for 3D display object.");
      }
      targetMatrix.concat(obj.transformationMatrix);
    }

    targetMatrix.invert();
    resultMatrix.concat(targetMatrix);
    return resultMatrix;
  }

  /// The 3D transformation matrix relative to the given [targetSpace].
  ///
  /// Note: You can get the transformation matrix either with the
  /// [getTransformationMatrix] or the [getTransformationMatrix3D]
  /// method. You only need to use a 3D transformation matrix if
  /// you are working with 3D display objects.

  Matrix3D getTransformationMatrix3D(DisplayObject targetSpace) {

    if (targetSpace == null) return this.globalTransformationMatrix3D;
    if (targetSpace == this) return new Matrix3D.fromIdentity();

    var ancestor = _getCommonAncestor(targetSpace);
    if (ancestor == null) return null;

    var resultMatrix = new Matrix3D.fromIdentity();
    for (var obj = this; obj != ancestor; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        resultMatrix.concat(obj.projectionMatrix3D);
      }
      resultMatrix.concat2D(obj.transformationMatrix);
    }

    if (identical(targetSpace, ancestor)) return resultMatrix;

    var targetMatrix = new Matrix3D.fromIdentity();
    for (var obj = targetSpace; obj != ancestor; obj = obj.parent) {
      if (obj is DisplayObjectContainer3D) {
        targetMatrix.concat(obj.projectionMatrix3D);
      }
      targetMatrix.concat2D(obj.transformationMatrix);
    }

    targetMatrix.invert();
    resultMatrix.concat(targetMatrix);
    return resultMatrix;
  }

  //----------------------------------------------------------------------------

  /// Add this display object to the specified [parent].

  void addTo(DisplayObjectParent parent) {
    parent.addChild(this);
  }

  /// Removes this display object from its parent.

  void removeFromParent() {
    if (this.parent != null) {
      this.parent.removeChild(this);
    }
  }

  //----------------------------------------------------------------------------

  /// Returns a rectangle that defines the area of this display object in
  /// this display object's local coordinates.

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, 0.0, 0.0);
  }

  /// Returns a rectangle that defines the area of this display object in
  /// this display object's parent coordinates.

  Rectangle<num> get boundsTransformed {
    var rectangle = this.bounds;
    var matrix = this.transformationMatrix;
    return matrix.transformRectangle(rectangle, rectangle);
  }

  /// Returns the bounds of this display object relative to the specified
  /// [targetSpace].
  ///
  /// This method may return ´null´ if this display objects has no
  /// relation to the [targetSpace].

  Rectangle<num> getBounds(DisplayObject targetSpace) {
    var rectangle = this.bounds;
    var matrix = this.getTransformationMatrix3D(targetSpace);
    if (matrix == null) return null;
    return matrix.transformRectangle(rectangle, rectangle);
  }

  /// Aligns the display object's pivot point relative to the current bounds.

  void alignPivot([
    HorizontalAlign hAlign = HorizontalAlign.Center,
    VerticalAlign vAlign = VerticalAlign.Center]) {

    var b = this.bounds;
    if (hAlign == HorizontalAlign.Left) this.pivotX = b.left;
    if (hAlign == HorizontalAlign.Center) this.pivotX = b.left + b.width / 2;
    if (hAlign == HorizontalAlign.Right) this.pivotX = b.right;
    if (vAlign == VerticalAlign.Top) this.pivotY = b.top;
    if (vAlign == VerticalAlign.Center) this.pivotY = b.top + b.height / 2;
    if (vAlign == VerticalAlign.Bottom) this.pivotY = b.bottom;
  }

  //----------------------------------------------------------------------------

  /// Evaluates this display object to see if it overlaps or intersects with
  /// the bounding box of the [other] display object.

  bool hitTestObject(DisplayObject other) {

    var otherBounds = other.getBounds(this);
    if (otherBounds == null) return false;

    return this.bounds.intersects(otherBounds);
  }

  /// Evaluates this display object to see if it overlaps or intersects with
  /// the point specified by the [x] and [y] parameters.
  ///
  /// The [x] and [y] parameters specify a point in the coordinate space of the
  /// [Stage], not the [DisplayObjectContainer] that contains the
  /// display object (unless that display object container is the Stage).
  ///
  /// If [shapeFlag] is set to false (the default), the check is done against
  /// the bounding box. If true, the check is done against the actual pixels
  /// of the object.
  ///
  /// Returns true if this display object overlaps or intersects with the
  /// specified point; false otherwise.

  bool hitTestPoint(num x, num y, [bool shapeFlag = false]) {

    var point = new Point<num>(x, y);
    this.globalToLocal(point, point);

    return shapeFlag
      ? this.hitTestInput(point.x, point.y) != null
      : this.bounds.contains(point.x, point.y);
  }

  /// Evaluates this display object to see if the coordinates [localX] and
  /// [localY] are inside this display object.
  ///
  /// If the coordinates are inside, this display object is returned; null
  /// otherwise.
  ///
  /// [localX] and [localY] are relative to to the origin (0,0) of this
  /// display object (local coordinates).

  DisplayObject hitTestInput(num localX, num localY) {
    return this.bounds.contains(localX, localY) ? this : null;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Converts the point object from this display object's local coordinates
  /// to this display object's parent coordinates.
  ///
  /// This method allows you to convert any given x- and y-coordinates from
  /// values that are relative to the origin (0,0) of this display object's
  /// local coordinates to values that are relative to the origin of this
  /// display object's parent coordinates.

  Point<num> localToParent(Point<num> localPoint, [Point<num> returnPoint]) {

    var p = returnPoint is Point ? returnPoint : new Point<num>(0.0, 0.0);
    var x = localPoint.x.toDouble();
    var y = localPoint.y.toDouble();
    var m = this.transformationMatrix;

    p.x = x * m.a + y * m.c + m.tx;
    p.y = x * m.b + y * m.d + m.ty;

    return p;
  }

  /// Converts the point object from this display obejct's parent coordinates
  /// to this display object's local coordinates.
  ///
  /// This method allows you to convert any given x- and y-coordinates from
  /// values that are relative to the origin (0,0) of this display object's
  /// parent coordinates to values that are relative to the origin of this
  /// display object's local coordinates.

  Point<num> parentToLocal(Point<num> parentPoint, [Point<num> returnPoint]) {

    var p = returnPoint is Point ? returnPoint : new Point<num>(0.0, 0.0);
    var x = parentPoint.x.toDouble();
    var y = parentPoint.y.toDouble();
    var m = this.transformationMatrix;

    p.x = (m.d * (x - m.tx) - m.c * (y - m.ty)) / m.det;
    p.y = (m.a * (y - m.ty) - m.b * (x - m.tx)) / m.det;

    return p;
  }

  /// Converts the point object from this display object's local coordinates
  /// to the [Stage] global coordinates.
  ///
  /// This method allows you to convert any given x- and y-coordinates from
  /// values that are relative to the origin (0,0) of this display object's
  /// local coordinates to values that are relative to the origin of the
  /// [Stage]'s global coordinates.

  Point<num> localToGlobal(Point<num> localPoint, [Point<num> returnPoint]) {

    var p = returnPoint is Point ? returnPoint : new Point<num>(0.0, 0.0);
    p.x = localPoint.x.toDouble();
    p.y = localPoint.y.toDouble();

    for (var obj = this; obj != null; obj = obj.parent) {
      obj.localToParent(p, p);
    }

    return p;
  }

  /// Converts the point object from the [Stage]'s global coordinates to this
  /// display object's local coordinates.
  ///
  /// This method allows you to convert any given x- and y-coordinates from
  /// values that are relative to the origin (0,0) of the [Stage]'s global
  /// coordinates to values that are relative to the origin of this display
  /// object's local coordinates.

  Point<num> globalToLocal(Point<num> globalPoint, [Point<num> returnPoint]) {

    var p = returnPoint is Point ? returnPoint : new Point<num>(0.0, 0.0);
    p.x = globalPoint.x.toDouble();
    p.y = globalPoint.y.toDouble();

    _globalToLocalRecursion(p);
    return p;
  }

  void _globalToLocalRecursion(Point<num> point) {
    if (parent != null) parent._globalToLocalRecursion(point);
    this.parentToLocal(point, point);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Draws the specified area of this display object to an internal render
  /// texture and the engine will use this texture to optimize performance.
  ///
  /// This is useful when the display object contains many static children or
  /// a [Graphics] vector object. If the cached area changes, the cache must be
  /// refreshed using [refreshCache] or removed using [removeCache].

  void applyCache(num x, num y, num width, num height, {
      bool debugBorder: false, num pixelRatio: 1.0}) {

    _cache = _cache != null ? _cache : new _DisplayObjectCache(this);
    _cache.debugBorder = debugBorder;
    _cache.pixelRatio = pixelRatio;
    _cache.bounds = new Rectangle<num>(x, y, width, height);
    _cache.update();
  }

  /// Refreshes the cached area of this display object.

  void refreshCache() {
    if (_cache != null) _cache.update();
  }

  /// Removes the previously cached area of this display object.

  void removeCache() {
    if (_cache != null) _cache.dispose();
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  void dispatchEvent(Event event) {

    List<EventDispatcher> ancestors = new List<EventDispatcher>();

    for(DisplayObject p = this.parent; p != null; p = p.parent) {
      ancestors.add(p);
    }

    for(int i = ancestors.length - 1; i >= 0 && event.captures; i--) {
      ancestors[i].dispatchEventRaw(event, this, EventPhase.CAPTURING_PHASE);
      if (event.isPropagationStopped) return;
    }

    dispatchEventRaw(event, this, EventPhase.AT_TARGET);
    if (event.isPropagationStopped) return;

    for(int i = 0; i < ancestors.length && event.bubbles; i++) {
      ancestors[i].dispatchEventRaw(event, this, EventPhase.BUBBLING_PHASE);
      if (event.isPropagationStopped) return;
    }
  }

  //----------------------------------------------------------------------------

  /// Renders this display object with the given [renderState].
  /// The display object is rendered without its filters.

  @override
  void render(RenderState renderState) {
    // implement in derived class.
  }

  /// Renders this display object with the given [renderState].
  /// The display object is rendered with its filters.
  ///
  /// Note: You do not need to override this method in a derived
  /// class since the [render] method will be used by default.
  /// Only implement this method for performance optimizations.

  @override
  void renderFiltered(RenderState renderState) {
    renderState.renderObjectFiltered(this);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  DisplayObject _getCommonAncestor(DisplayObject other) {

    var obj1 = this;
    var obj2 = other;
    var depth1 = 0;
    var depth2 = 0;

    for(var o = obj1; o.parent != null; o = o.parent) { depth1 += 1; }
    for(var o = obj2; o.parent != null; o = o.parent) { depth2 += 1; }
    while(depth1 > depth2) { obj1 = obj1.parent; depth1 -= 1; }
    while(depth2 > depth1) { obj2 = obj2.parent; depth2 -= 1; }

    while(identical(obj1, obj2) == false) {
      obj1 = obj1.parent;
      obj2 = obj2.parent;
    }

    return obj1;
  }

  void _reverseMatrix(num ma, num mb, num mc, num md) {

    var skewX = atan2(-mc, md), cosX = cos(skewX), sinX = sin(skewX);
    var skewY = atan2( mb, ma), cosY = cos(skewY), sinY = sin(skewY);

    _transformationMatrixRefresh = true;
    _scaleX = (cosY * cosY > sinY * sinY) ? ma / cosY :  mb / sinY;
    _scaleY = (cosX * cosX > sinX * sinX) ? md / cosX : -mc / sinX;
    _skewX = skewX - _rotation;
    _skewY = skewY - _rotation;
  }
}

