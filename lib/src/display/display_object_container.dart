part of stagexl.display;

/// The base class for all objects that can serve as display object containers
/// on the display list.
///
/// The display list manages all objects displayed. Use the
/// [DisplayObjectContainer] class to arrange the display objects in the display
/// list. Each [DisplayObjectContainer] object has its own child list for
/// organizing the z-order of the objects. The z-order is the front-to-back
/// order that determines which object is drawn in front, which is behind, and
/// so on.

abstract class DisplayObjectContainer
    extends InteractiveObject
    implements DisplayObjectParent {

  final List<DisplayObject> _children = new List<DisplayObject>();
  bool _mouseChildren = true;
  bool _tabChildren = true;

  //----------------------------------------------------------------------------

  DisplayObjectChildren get children {
    return new DisplayObjectChildren._(this, _children);
  }

  /// The number of children of this container.

  int get numChildren => _children.length;

  /// Determines whether or not the children of the object are mouse, or user
  /// input device, enabled.
  ///
  /// If an object is enabled, a user can interact with it by using a mouse or
  /// user input device. The default is true.
  ///
  /// This property is useful when you create a button with an instance of the
  /// [Sprite] class (instead of using the [SimpleButton] class). When you use
  /// a [Sprite] instance to create a button, you can choose to decorate the
  /// button by using the [addChild] method to add additional [Sprite]
  /// instances. This process can cause unexpected behavior with mouse events
  /// because the [Sprite] instances you add as children can become the target
  /// object of a mouse event when you expect the parent instance to be the
  /// target object. To ensure that the parent instance serves as the target
  /// objects for mouse events, you can set the [mouseChildren] property of the
  /// parent instance to false.
  ///
  /// No event is dispatched by setting this property. You must use the on...()
  /// event methods to create interactive functionality.

  bool get mouseChildren => _mouseChildren;

  void set mouseChildren(bool value) { _mouseChildren = value; }

  /// Determines whether the children of this container are tab enabled.
  ///
  /// The default is true.

  bool get tabChildren => _tabChildren;

  void set tabChildren(bool value) { _tabChildren = value; }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Adds a child [DisplayObject] to this [DisplayObjectContainer].
  ///
  /// The child is added to the front (top) of all other children. (To add a
  /// child to a specific index position, use [addChildAt].)
  ///
  /// If you add a child object that already has a different display object
  /// container as a parent, the object is removed from the child list of the
  /// other display object container.

  void addChild(DisplayObject child) {
    addChildAt(child, _children.length);
  }

  /// Adds a child [DisplayObject] to this [DisplayObjectContainer] at the
  /// specified [index] position.
  ///
  /// An [index] of 0 represents the back (bottom) of the display list for this
  /// [DisplayObjectContainer].
  ///
  /// If you add a child object that already has a different display object
  /// container as a parent, the object is removed from the child list of the
  /// other display object container.

  void addChildAt(DisplayObject child, int index) {

    if (index < 0 || index > _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    if (child == this) {
      throw new ArgumentError("An object cannot be added as a child of itself.");
    }

    if (child.parent == this) {

      _children.remove(child);
      if (index > _children.length) index -= 1;
      _children.insert(index, child);

    } else {

      child.removeFromParent();

      for (var ancestor = this; ancestor != null; ancestor = ancestor.parent) {
        if (ancestor == child) {
          throw new ArgumentError(
              "An object cannot be added as a child to one of it's children "
              "(or children's children, etc.).");
        }
      }

      _children.insert(index, child);
      child._parent = this;
      _dispatchAddedEvents(child);
    }
  }

  //----------------------------------------------------------------------------

  /// Removes the specified [child] from the child list of this
  /// [DisplayObjectContainer].
  ///
  /// The parent property of the removed child is set to null, and the object is
  /// garbage collected if no other references to the child exist. The index
  /// positions of any display objects above the child in the
  /// [DisplayObjectContainer] are decreased by 1.

  void removeChild(DisplayObject child) {

    int childIndex = _children.indexOf(child);
    if (childIndex == -1) {
      throw new ArgumentError("The supplied DisplayObject must be a child of the caller.");
    }

    removeChildAt(childIndex);
  }

  /// Removes the child [DisplayObject] from the specified [index] position in
  /// the child list of this [DisplayObjectContainer].
  ///
  /// The parent property of the removed child is set to null, and the object is
  /// garbage collected if no other references to the child exist. The index
  /// positions of any display objects above the child in the
  /// [DisplayObjectContainer] are decreased by 1.

  void removeChildAt(int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    DisplayObject child = _children[index];
    _dispatchRemovedEvents(child);
    child._parent = null;
    _children.removeAt(index);
  }

  /// Removes all child [DisplayObject] instances from the child list of this
  /// [DisplayObjectContainer] instance.
  ///
  /// Optionally, an index range may be specified with [beginIndex] and
  /// [endIndex].
  ///
  /// The parent property of the removed children is set to null, and the
  /// objects are garbage collected if no other references to the children exist.

  void removeChildren([int beginIndex, int endIndex]) {

    var length = _children.length;
    if (length == 0) return;

    if (beginIndex == null) beginIndex = 0;
    if (endIndex == null) endIndex = length - 1;

    if (beginIndex < 0 || endIndex < 0 || beginIndex >= length || endIndex >= length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    for (int i = beginIndex; i <= endIndex; i++) {
      if (beginIndex >= _children.length) break;
      removeChildAt(beginIndex);
    }
  }

  /// Replaces the child at the specified [index] position with the new
  /// [child]. The current child at this position is removed.
  ///
  /// The parent property of the removed child is set to null, and the object
  /// is garbage collected if no other references to the child exist.

  void replaceChildAt(DisplayObject child, int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    var oldChild = _children[index];
    var newChild = child;

    if (newChild == this) {
      throw new ArgumentError("An object cannot be added as a child of itself.");
    }

    if (newChild.parent == this) {
      if (_children.indexOf(newChild) == index) return;
      throw new ArgumentError(
          "The display object is already a child of this container.");
    }

    newChild.removeFromParent();

    for (var parent = this.parent; parent != null; parent = parent.parent) {
      if (parent == newChild) throw new ArgumentError(
          "An object cannot be added as a child to one of it's children "
          "(or children's children, etc.).");
    }

    _dispatchRemovedEvents(oldChild);
    oldChild._parent = null;
    newChild._parent = this;
    _children[index] = newChild;
    _dispatchAddedEvents(newChild);

  }

  //----------------------------------------------------------------------------

  /// Returns the child [DisplayObject] at the specified [index].

  DisplayObject getChildAt(int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }
    return _children[index];
  }

  /// Returns the child [DisplayObject] that exists with the specified name.
  ///
  /// If more that one child [DisplayObject] has the specified name, the method
  /// returns the first object in the child list.
  ///
  /// The [getChildAt] method is faster than the [getChildByName] method. The
  /// [getChildAt] method accesses a child from a cached array, whereas the
  /// [getChildByName] method has to traverse a list to access a child.

  DisplayObject getChildByName(String name) {

    for (int i = 0; i < _children.length; i++) {
      DisplayObject child = _children[i];
      if (child.name == name) return child;
    }
    return null;
  }

  /// Returns the index position of a child [DisplayObject].

  int getChildIndex(DisplayObject child) {
    return _children.indexOf(child);
  }

  //---------------------------------------------------------------------------

  /// Changes the position of an existing [child] in this
  /// [DisplayObjectContainer] to the new [index].
  ///
  /// This affects the layering of child objects.
  ///
  /// When you use the [setChildIndex] method and specify an index position that
  /// is already occupied, the only positions that change are those in between
  /// the display object's former and new position. All others will stay the
  /// same. If a child is moved to an index LOWER than its current index, all
  /// children in between will INCREASE by 1 for their index reference. If a
  /// child is moved to an index HIGHER than its current index, all children in
  /// between will DECREASE by 1 for their index reference.

  void setChildIndex(DisplayObject child, int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    int oldIndex = getChildIndex(child);
    if (oldIndex == -1) {
      throw new ArgumentError("The supplied DisplayObject must be a child of the caller.");
    }

    _children.removeAt(oldIndex);
    _children.insert(index, child);
  }

  /// Swaps the z-order (front-to-back order) of the two specified child objects.
  ///
  /// All other child objects in the display object container remain in the same
  /// index positions.

  void swapChildren(DisplayObject child1, DisplayObject child2) {

    int index1 = getChildIndex(child1);
    int index2 = getChildIndex(child2);

    if (index1 == -1 || index2 == -1) {
      throw new ArgumentError("The supplied DisplayObject must be a child of the caller.");
    }

    swapChildrenAt(index1, index2);
  }

  /// Swaps the z-order (front-to-back order) of the child objects at the two
  /// specified index positions in the child list.
  ///
  /// All other child objects in the display object container remain in the same
  /// index positions.

  void swapChildrenAt(int index1, int index2) {

    DisplayObject child1 = getChildAt(index1);
    DisplayObject child2 = getChildAt(index2);
    _children[index1] = child2;
    _children[index2] = child1;
  }

  //----------------------------------------------------------------------------

  /// Sorts the child list according to the order specified by the [compare]
  /// Function.

  void sortChildren(int compare(DisplayObject a, DisplayObject b)) {
    _children.sort(compare);
  }

  /// Determines whether the specified [DisplayObject] is a child of this
  /// [DisplayObjectContainer] instance or the instance itself.
  ///
  /// The search includes the entire display list including this
  /// [DisplayObjectContainer] instance. Grandchildren, great-grandchildren,
  /// and so on each return true.

  bool contains(DisplayObject child) {

    while (child != null) {
      if (child == this) return true;
      child = child.parent;
    }
    return false;
  }

  /// Returns a list of display objects that lie under the specified
  /// point and are children (or grandchildren, and so on) of this
  /// display object container.
  ///
  /// The [point] parameter is in the local coordinate system of
  /// this display object container.

  List<DisplayObject> getObjectsUnderPoint(Point<num> point, [
    List<DisplayObject> returnList]) {

    var tmpPoint = new Point<num>(0.0, 0.0);

    if (returnList is! List) {
      returnList = new List<DisplayObject>();
    }

    for (int i = 0; i < _children.length; i++) {
      var child = _children[i];
      child.parentToLocal(point, tmpPoint);

      if (child is DisplayObjectContainer) {
        child.getObjectsUnderPoint(tmpPoint, returnList);
      } else if (child.bounds.contains(tmpPoint.x, tmpPoint.y)) {
        returnList.add(child);
      }
    }

    return returnList;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {

    if (_children.length == 0) return super.bounds;

    num left = double.INFINITY;
    num top = double.INFINITY;
    num right = double.NEGATIVE_INFINITY;
    num bottom = double.NEGATIVE_INFINITY;

    for (int i = 0; i < _children.length; i++) {
      var rectangle = _children[i].boundsTransformed;

      if (rectangle.left < left) left = rectangle.left;
      if (rectangle.top < top) top = rectangle.top;
      if (rectangle.right > right) right = rectangle.right;
      if (rectangle.bottom > bottom) bottom = rectangle.bottom;
    }

    return new Rectangle<num>(left, top, right - left, bottom - top);
  }

  //----------------------------------------------------------------------------

  @override
  DisplayObject hitTestInput(num localX, num localY) {

    localX = localX.toDouble();
    localY = localY.toDouble();

    DisplayObject hit = null;

    for (int i = _children.length - 1; i >= 0; i--) {
      var child = _children[i];
      var mask = child.mask;
      var matrix = child.transformationMatrix;

      if (child.visible && child.off == false) {
        num deltaX = localX - matrix.tx;
        num deltaY = localY - matrix.ty;
        num childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
        num childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

        if (mask != null) {
          num maskX = mask.relativeToParent ? localX : childX;
          num maskY = mask.relativeToParent ? localY : childY;
          if (mask.hitTest(maskX, maskY) == false) continue;
        }

        var displayObject = child.hitTestInput(childX, childY);
        if (displayObject == null) continue;

        if (displayObject is InteractiveObject && displayObject.mouseEnabled) {
          return _mouseChildren ? displayObject : this;
        }

        hit = this;
      }
    }

    return hit;
  }

  //----------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    for (int i = 0; i < _children.length; i++) {
      DisplayObject child = _children[i];
      if (child.visible && child.off == false) {
        renderState.renderObject(child);
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  void _dispatchAddedEvents(DisplayObject child) {
    child.dispatchEvent(new Event(Event.ADDED, true));
    if (this.stage != null) {
      _dispatchStageEvents(child, Event.ADDED_TO_STAGE);
    }
  }

  void _dispatchRemovedEvents(DisplayObject child) {
    child.dispatchEvent(new Event(Event.REMOVED, true));
    if (this.stage != null) {
      _dispatchStageEvents(child, Event.REMOVED_FROM_STAGE);
    }
  }

  //----------------------------------------------------------------------------

  void _dispatchStageEvents(DisplayObject child, String eventType) {

    // We optimize for the fact that the ADDED_TO_STAGE and REMOVE_FROM_STAGE
    // events do not bubble, and most of the time there are no capturing event
    // listeners. Iterate recursively through all children and children's
    // children and dispatch the ADDED_TO_STAGE or REMOVE_FROM_STAGE event
    // only if necessary.

    var captured = false;
    for(var obj = this; obj != null && captured == false; obj = obj.parent) {
      if (obj.hasEventListener(eventType, useCapture: true)) captured = true;
    }

    _dispatchStageEventsRecursion(child, new Event(eventType), captured);
  }

  void _dispatchStageEventsRecursion(DisplayObject displayObject,
                                     Event event, bool captured) {

    if (captured || displayObject.hasEventListener(event.type)) {
      displayObject.dispatchEvent(event);
    }
    if (displayObject is DisplayObjectContainer) {
      captured = captured ||
        displayObject.hasEventListener(event.type, useCapture: true);
      var children = displayObject._children;
      for(int i = 0; i < children.length; i++) {
        _dispatchStageEventsRecursion(children[i], event, captured);
      }
    }
  }

}
