part of stagexl.display;

abstract class DisplayObjectContainer extends InteractiveObject {

  final List<DisplayObject> _children = new List<DisplayObject>();
  bool _mouseChildren = true;
  bool _tabChildren = true;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get numChildren => _children.length;

  bool get mouseChildren => _mouseChildren;
  bool get tabChildren => _tabChildren;

  void set mouseChildren(bool value) { _mouseChildren = value; }
  void set tabChildren(bool value) { _tabChildren = value; }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addChild(DisplayObject child) {
    addChildAt(child, _children.length);
  }

  //-------------------------------------------------------------------------------------------------

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
          throw new ArgumentError("An object cannot be added as "
              "a child to one of it's children (or children's children, etc.).");
        }
      }

      _children.insert(index, child);

      child._parent = this;
      child.dispatchEvent(new Event(Event.ADDED, true));

      if (this.stage != null) {
        _dispatchEventDescendants(child, new Event(Event.ADDED_TO_STAGE));
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void removeChild(DisplayObject child) {

    int childIndex = _children.indexOf(child);
    if (childIndex == -1) {
      throw new ArgumentError("The supplied DisplayObject must be a child of the caller.");
    }

    removeChildAt(childIndex);
  }

  //-------------------------------------------------------------------------------------------------

  void removeChildAt(int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    DisplayObject child = _children[index];

    child.dispatchEvent(new Event(Event.REMOVED, true));

    if (this.stage != null) {
      _dispatchEventDescendants(child, new Event(Event.REMOVED_FROM_STAGE));
    }

    child._parent = null;
    _children.removeAt(index);
  }

  //-------------------------------------------------------------------------------------------------

  void removeChildren([int beginIndex = 0, int endIndex = 0x7fffffff]) {

    var length = _children.length;
    if (length == 0) return;

    if (endIndex == 0x7fffffff) {
      endIndex = length - 1;
    }

    if (beginIndex < 0 || endIndex < 0 || beginIndex >= length || endIndex >= length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    for (int i = beginIndex; i <= endIndex; i++) {
      if (beginIndex >= _children.length) break;
      removeChildAt(beginIndex);
    }
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildAt(int index) {

    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }
    return _children[index];
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildByName(String name) {

    for (int i = 0; i < _children.length; i++) {
      DisplayObject child = _children[i];
      if (child.name == name) return child;
    }
    return null;
  }

  //-------------------------------------------------------------------------------------------------

  int getChildIndex(DisplayObject child) {

    return _children.indexOf(child);
  }

  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------

  void swapChildren(DisplayObject child1, DisplayObject child2) {

    int index1 = getChildIndex(child1);
    int index2 = getChildIndex(child2);

    if (index1 == -1 || index2 == -1) {
      throw new ArgumentError("The supplied DisplayObject must be a child of the caller.");
    }

    swapChildrenAt(index1, index2);
  }

  //-------------------------------------------------------------------------------------------------

  void swapChildrenAt(int index1, int index2) {

    DisplayObject child1 = getChildAt(index1);
    DisplayObject child2 = getChildAt(index2);
    _children[index1] = child2;
    _children[index2] = child1;
  }

  //-------------------------------------------------------------------------------------------------

  void sortChildren(Function compareFunction) {
    _children.sort(compareFunction);
  }

  //-------------------------------------------------------------------------------------------------

  bool contains(DisplayObject child) {

    while (child != null) {
      if (child == this) return true;
      child = child.parent;
    }
    return false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    if (returnRectangle == null) {
      returnRectangle = new Rectangle<num>(0, 0, 0, 0);
    }

    if (_children.length == 0) {
      return super.getBoundsTransformed(matrix, returnRectangle);
    }

    num left = double.INFINITY;
    num top = double.INFINITY;
    num right = double.NEGATIVE_INFINITY;
    num bottom = double.NEGATIVE_INFINITY;

    int childrenLength = _children.length;

    for (int i = 0; i < _children.length; i++) {

      DisplayObject child = _children[i];

      _tmpMatrix.copyFromAndConcat(child.transformationMatrix, matrix);
      Rectangle<num> rectangle = child.getBoundsTransformed(_tmpMatrix, returnRectangle);

      if (rectangle.left < left) left = rectangle.left;
      if (rectangle.top < top) top = rectangle.top;
      if (rectangle.right > right) right = rectangle.right;
      if (rectangle.bottom > bottom) bottom = rectangle.bottom;
    }

    returnRectangle.left = left;
    returnRectangle.top = top;
    returnRectangle.width = right - left;
    returnRectangle.height = bottom - top;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    for (int i = 0; i < _children.length; i++) {
      DisplayObject child = _children[i];
      if (child.visible && child.off == false) {
        renderState.renderObject(child);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _collectDescendants(DisplayObject displayObject, List descendants) {

    descendants.add(displayObject);

    if (displayObject is DisplayObjectContainer) {
      var children = displayObject._children;
      for (int i = 0; i < children.length; i++) {
        _collectDescendants(children[i], descendants);
      }
    }
  }

  _dispatchEventDescendants(DisplayObject displayObject, Event event) {

    List descendants = [];
    _collectDescendants(displayObject, descendants);

    for (int i = 0; i < descendants.length; i++) {
      descendants[i].dispatchEvent(event);
    }
  }


}
