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

abstract class DisplayObjectContainer extends InteractiveObject
    implements DisplayObjectParent<DisplayObject> {
  final List<DisplayObject> _children = <DisplayObject>[];
  bool _mouseChildren = true;
  bool _tabChildren = true;

  //----------------------------------------------------------------------------

  @override
  DisplayObjectChildren<DisplayObject> get children =>
      DisplayObjectChildren<DisplayObject>._(this, _children);

  /// The number of children of this container.

  @override
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

  set mouseChildren(bool value) {
    _mouseChildren = value;
  }

  /// Determines whether the children of this container are tab enabled.
  ///
  /// The default is true.

  bool get tabChildren => _tabChildren;

  set tabChildren(bool value) {
    _tabChildren = value;
  }

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

  @override
  void addChild(DisplayObject child) {
    if (child == this) {
      throw ArgumentError('An object cannot be added as a child of itself.');
    } else if (child.parent == this) {
      _addLocalChild(child);
    } else {
      child.removeFromParent();
      _throwIfAncestors(child);
      _children.add(child);
      _setChildParent(child);
    }
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

  @override
  void addChildAt(DisplayObject child, int index) {
    if (index < 0 || index > _children.length) {
      throw ArgumentError('The supplied index is out of bounds.');
    } else if (child == this) {
      throw ArgumentError('An object cannot be added as a child of itself.');
    } else if (child.parent == this) {
      _addLocalChildAt(child, index);
    } else {
      child.removeFromParent();
      _throwIfAncestors(child);
      _children.insert(index, child);
      _setChildParent(child);
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

  @override
  void removeChild(DisplayObject child) {
    if (child.parent != this) {
      throw ArgumentError(
          'The supplied DisplayObject must be a child of the caller.');
    } else {
      final index = _children.indexOf(child);
      _clearChildParent(child);
      _children.removeAt(index);
    }
  }

  /// Removes the child [DisplayObject] from the specified [index] position in
  /// the child list of this [DisplayObjectContainer].
  ///
  /// The parent property of the removed child is set to null, and the object is
  /// garbage collected if no other references to the child exist. The index
  /// positions of any display objects above the child in the
  /// [DisplayObjectContainer] are decreased by 1.

  @override
  void removeChildAt(int index) {
    if (index < 0 || index >= _children.length) {
      throw ArgumentError('The supplied index is out of bounds.');
    } else {
      final child = _children[index];
      _clearChildParent(child);
      _children.removeAt(index);
    }
  }

  /// Removes all child [DisplayObject] instances from the child list of this
  /// [DisplayObjectContainer] instance.
  ///
  /// Optionally, an index range may be specified with [beginIndex] and
  /// [endIndex].
  ///
  /// The parent property of the removed children is set to null, and the
  /// objects are garbage collected if no other references to the children exist.

  @override
  void removeChildren([int beginIndex = 0, int? endIndex]) {
    final length = _children.length;
    final i1 = beginIndex;
    final i2 = endIndex ?? length - 1;
    if (i1 > i2) {
      // do nothing
    } else if (i1 < 0 || i1 >= length || i2 < 0 || i2 >= length) {
      throw ArgumentError('The supplied index is out of bounds.');
    } else {
      for (var i = i1; i <= i2 && i1 < _children.length; i++) {
        removeChildAt(i1);
      }
    }
  }

  /// Replaces the child at the specified [index] position with the new
  /// [child]. The current child at this position is removed.
  ///
  /// The parent property of the removed child is set to null, and the object
  /// is garbage collected if no other references to the child exist.

  @override
  void replaceChildAt(DisplayObject child, int index) {
    if (index < 0 || index >= _children.length) {
      throw ArgumentError('The supplied index is out of bounds.');
    } else if (child == this) {
      throw ArgumentError('An object cannot be added as a child of itself.');
    } else if (child.parent == this) {
      if (_children.indexOf(child) == index) return;
      throw ArgumentError(
          'The display object is already a child of this container.');
    } else {
      child.removeFromParent();
      _throwIfAncestors(child);
      _clearChildParent(_children[index]);
      _children[index] = child;
      _setChildParent(child);
    }
  }

  //----------------------------------------------------------------------------

  /// Returns the child [DisplayObject] at the specified [index].

  @override
  DisplayObject getChildAt(int index) {
    if (index < 0 || index >= _children.length) {
      throw ArgumentError('The supplied index is out of bounds.');
    } else {
      return _children[index];
    }
  }

  /// Returns the child [DisplayObject] that exists with the specified name.
  ///
  /// If more that one child [DisplayObject] has the specified name, the method
  /// returns the first object in the child list.
  ///
  /// The [getChildAt] method is faster than the [getChildByName] method. The
  /// [getChildAt] method accesses a child from a cached array, whereas the
  /// [getChildByName] method has to traverse a list to access a child.

  @override
  DisplayObject? getChildByName(String name) {
    for (var i = 0; i < _children.length; i++) {
      final child = _children[i];
      if (child.name == name) return child;
    }
    return null;
  }

  /// Returns the index position of a child [DisplayObject].

  @override
  int getChildIndex(DisplayObject child) => _children.indexOf(child);

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
      throw ArgumentError('The supplied index is out of bounds.');
    } else if (child.parent != this) {
      throw ArgumentError(
          'The supplied DisplayObject must be a child of the caller.');
    } else {
      _addLocalChildAt(child, index);
    }
  }

  /// Swaps the z-order (front-to-back order) of the two specified child objects.
  ///
  /// All other child objects in the display object container remain in the same
  /// index positions.

  void swapChildren(DisplayObject child1, DisplayObject child2) {
    final index1 = getChildIndex(child1);
    final index2 = getChildIndex(child2);
    if (index1 == -1 || index2 == -1) {
      throw ArgumentError(
          'The supplied DisplayObject must be a child of the caller.');
    } else {
      swapChildrenAt(index1, index2);
    }
  }

  /// Swaps the z-order (front-to-back order) of the child objects at the two
  /// specified index positions in the child list.
  ///
  /// All other child objects in the display object container remain in the same
  /// index positions.

  void swapChildrenAt(int index1, int index2) {
    final child1 = getChildAt(index1);
    final child2 = getChildAt(index2);
    _children[index1] = child2;
    _children[index2] = child1;
  }

  //----------------------------------------------------------------------------

  /// Sorts the child list according to the order specified by the [compare]
  /// Function.

  void sortChildren(int Function(DisplayObject a, DisplayObject b) compare) {
    _children.sort(compare);
  }

  /// Determines whether the specified [DisplayObject] is a child of this
  /// [DisplayObjectContainer] instance or the instance itself.
  ///
  /// The search includes the entire display list including this
  /// [DisplayObjectContainer] instance. Grandchildren, great-grandchildren,
  /// and so on each return true.

  bool contains(DisplayObject child) {
    DisplayObject? localChild = child;
    while (localChild != null) {
      if (localChild == this) return true;
      localChild = localChild.parent;
    }
    return false;
  }

  /// Returns a list of display objects that lie under the specified
  /// point and are children (or grandchildren, and so on) of this
  /// display object container.
  ///
  /// The [point] parameter is in the local coordinate system of
  /// this display object container.

  List<DisplayObject> getObjectsUnderPoint(Point<num> point) {
    final result = <DisplayObject>[];
    final temp = Point<num>(0.0, 0.0);

    for (var child in _children) {
      child.parentToLocal(point, temp);
      if (child is DisplayObjectContainer) {
        result.addAll(child.getObjectsUnderPoint(temp));
      } else if (child.bounds.contains(temp.x, temp.y)) {
        result.add(child);
      }
    }

    return result;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    if (_children.isEmpty) return super.bounds;

    num left = double.infinity;
    num top = double.infinity;
    num right = double.negativeInfinity;
    num bottom = double.negativeInfinity;

    for (var i = 0; i < _children.length; i++) {
      final rectangle = _children[i].boundsTransformed;

      if (rectangle.left < left) left = rectangle.left;
      if (rectangle.top < top) top = rectangle.top;
      if (rectangle.right > right) right = rectangle.right;
      if (rectangle.bottom > bottom) bottom = rectangle.bottom;
    }

    return Rectangle<num>(left, top, right - left, bottom - top);
  }

  //----------------------------------------------------------------------------

  @override
  DisplayObject? hitTestInput(num localX, num localY) {
    localX = localX.toDouble();
    localY = localY.toDouble();

    DisplayObject? hit;

    for (var i = _children.length - 1; i >= 0; i--) {
      final child = _children[i];
      final mask = child.mask;
      final matrix = child.transformationMatrix;

      if (child.visible && child.off == false) {
        final deltaX = localX - matrix.tx;
        final deltaY = localY - matrix.ty;
        var childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
        var childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

        if (mask != null) {
          final maskX = mask.relativeToParent ? localX : childX;
          final maskY = mask.relativeToParent ? localY : childY;
          if (mask.hitTest(maskX, maskY) == false) continue;
        }

        if (child is DisplayObjectContainer3D) {
          final point = Point<num>(childX, childY);
          child.projectionMatrix3D.transformPointInverse(point, point);
          childX = point.x.toDouble();
          childY = point.y.toDouble();
        }

        final displayObject = child.hitTestInput(childX, childY);
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
    for (var i = 0; i < _children.length; i++) {
      final child = _children[i];
      if (child.visible && child.off == false) {
        renderState.renderObject(child);
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  void _throwIfAncestors(DisplayObject child) {
    for (DisplayObjectContainer? a = this;
        a != null;
        a = a.parent as DisplayObjectContainer?) {
      if (a == child) {
        throw ArgumentError(
            "An object cannot be added as a child to one of it's children "
            "(or children's children, etc.).");
      }
    }
  }

  void _addLocalChild(DisplayObject child) {
    final children = _children;
    DisplayObject oldChild;
    var newChild = child;
    for (var i = children.length - 1; i >= 0; i--) {
      oldChild = children[i];
      children[i] = newChild;
      newChild = oldChild;
      if (child == newChild) break;
    }
  }

  void _addLocalChildAt(DisplayObject child, int index) {
    final children = _children;
    children.remove(child);
    if (index > _children.length) index -= 1;
    children.insert(index, child);
  }

  void _setChildParent(DisplayObject child) {
    child._parent = this;
    child.dispatchEvent(Event(Event.ADDED, true));
    if (stage != null) _dispatchStageEvents(child, Event.ADDED_TO_STAGE);
  }

  void _clearChildParent(DisplayObject child) {
    child.dispatchEvent(Event(Event.REMOVED, true));
    if (stage != null) _dispatchStageEvents(child, Event.REMOVED_FROM_STAGE);
    child._parent = null;
  }

  //----------------------------------------------------------------------------

  void _dispatchStageEvents(DisplayObject child, String eventType) {
    // We optimize for the fact that the ADDED_TO_STAGE and REMOVE_FROM_STAGE
    // events do not bubble, and most of the time there are no capturing event
    // listeners. Iterate recursively through all children and children's
    // children and dispatch the ADDED_TO_STAGE or REMOVE_FROM_STAGE event
    // only if necessary.

    var captured = false;
    for (DisplayObject? obj = this;
        obj != null && captured == false;
        obj = obj.parent) {
      if (obj.hasEventListener(eventType, useCapture: true)) captured = true;
    }

    _dispatchStageEventsRecursion(child, Event(eventType), captured);
  }

  void _dispatchStageEventsRecursion(
      DisplayObject displayObject, Event event, bool captured) {
    if (captured || displayObject.hasEventListener(event.type)) {
      displayObject.dispatchEvent(event);
    }
    if (displayObject is DisplayObjectContainer) {
      captured = captured ||
          displayObject.hasEventListener(event.type, useCapture: true);
      final children = displayObject._children;
      for (var i = 0; i < children.length; i++) {
        _dispatchStageEventsRecursion(children[i], event, captured);
      }
    }
  }
}
