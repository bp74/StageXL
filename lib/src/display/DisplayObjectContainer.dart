part of stagexl;

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

    if (child.parent == this) {
      int index = _children.indexOf(child);
      _children.removeAt(index);
      _children.add(child);
    } else {
      addChildAt(child, _children.length);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void addChildAt(DisplayObject child, int index) {

    if (index < 0 || index > _children.length)
      throw new ArgumentError("Error #2006: The supplied index is out of bounds.");

    if (child == this)
      throw new ArgumentError("Error #2024: An object cannot be added as a child of itself.");

    if (child.parent == this) {

      _children.removeAt(_children.indexOf(child));

      if (index > _children.length)
        index --;

      _children.insert(index, child);

    } else {

      child.removeFromParent();

      child._setParent(this);
      _children.insert(index, child);

      child.dispatchEvent(new Event(Event.ADDED, true));

      if (this.stage != null)
        _dispatchEventDescendants(child, new Event(Event.ADDED_TO_STAGE));
    }
  }

  //-------------------------------------------------------------------------------------------------

  void removeChild(DisplayObject child) {

    int childIndex = _children.indexOf(child);

    if (childIndex == -1)
      throw new ArgumentError("Error #2025: The supplied DisplayObject must be a child of the caller.");

    removeChildAt(childIndex);
  }

  //-------------------------------------------------------------------------------------------------

  void removeChildAt(int index) {

    if (index < 0 || index >= _children.length)
      throw new ArgumentError("Error #2006: The supplied index is out of bounds.");

    DisplayObject child = _children[index];

    child.dispatchEvent(new Event(Event.REMOVED, true));

    if (this.stage != null)
      _dispatchEventDescendants(child, new Event(Event.REMOVED_FROM_STAGE));

    child._setParent(null);
    _children.removeAt(index);
  }

  //-------------------------------------------------------------------------------------------------

  void removeChildren([int beginIndex = 0, int endIndex = 0x7fffffff]) {

    var length = _children.length;

    if (endIndex == 0x7fffffff) {
      endIndex = length - 1;
    }

    if (beginIndex < 0 || endIndex < 0 || beginIndex >= length || endIndex >= length) {
      throw new ArgumentError("Error #2006: The supplied index is out of bounds.");
    }

    for(int i = beginIndex; i <= endIndex; i++) {
      if (beginIndex >= _children.length) break;
      removeChildAt(beginIndex);
    }
  }

  //-------------------------------------------------------------------------------------------------

  dynamic getChildAt(int index) {

    if (index < 0 || index >= _children.length)
      throw new ArgumentError("Error #2006: The supplied index is out of bounds.");

    return _children[index];
  }

  //-------------------------------------------------------------------------------------------------

  dynamic getChildByName(String name) {

    for(int i = 0; i < _children.length; i++)
      if (_children[i].name == name)
        return _children[i];

      return null;
  }

  //-------------------------------------------------------------------------------------------------

  int getChildIndex(DisplayObject child) {
      return _children.indexOf(child);
  }

  //-------------------------------------------------------------------------------------------------

  void setChildIndex(DisplayObject child, int index) {

    if (index < 0 || index >= _children.length)
      throw new ArgumentError("Error #2006: The supplied index is out of bounds.");

    int oldIndex = getChildIndex(child);

    if (oldIndex == -1)
      throw new ArgumentError("Error #2025: The supplied DisplayObject must be a child of the caller.");

    _children.removeAt(oldIndex);
    _children.insert(index, child);
  }

  //-------------------------------------------------------------------------------------------------

  void swapChildren(DisplayObject child1, DisplayObject child2) {

      int index1 = getChildIndex(child1);
      int index2 = getChildIndex(child2);

      if (index1 == -1 || index2 == -1)
        throw new ArgumentError("Error #2025: The supplied DisplayObject must be a child of the caller.");

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

    for(; child != null; child = child._parent)
      if (child == this)
        return true;

    return false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {

    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    if (_children.length == 0)
      return super.getBoundsTransformed(matrix, returnRectangle);

    num left = double.INFINITY;
    num top = double.INFINITY;
    num right = double.NEGATIVE_INFINITY;
    num bottom = double.NEGATIVE_INFINITY;

    int childrenLength = _children.length;

    for (int i = 0; i < _children.length; i++) {

      DisplayObject child = _children[i];

      _tmpMatrix.copyFromAndConcat(child.transformationMatrix, matrix);
      Rectangle rectangle = child.getBoundsTransformed(_tmpMatrix, returnRectangle);

      if (rectangle.left < left) left = rectangle.left;
      if (rectangle.top < top ) top = rectangle.top;
      if (rectangle.right > right) right = rectangle.right;
      if (rectangle.bottom > bottom) bottom = rectangle.bottom;
    }

    returnRectangle.x = left;
    returnRectangle.y = top;
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
        num maskX = 0.0;
        num maskY = 0.0;

        if (mask != null) {
          if (mask.targetSpace == null) {
            maskX = childX;
            maskY = childY;
          } else if (identical(mask.targetSpace, child)) {
            maskX = childX;
            maskY = childY;
          } else if (identical(mask.targetSpace, this)) {
            maskX = localX;
            maskY = localY;
          } else {
            matrix = this.transformationMatrixTo(mask.targetSpace);
            matrix = (matrix != null) ? matrix : _identityMatrix;
            maskX = localX * matrix.a + localY * matrix.c + matrix.tx;
            maskY = localX * matrix.b + localY * matrix.d + matrix.ty;
          }
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

    for(int i = 0; i < _children.length; i++) {
      DisplayObject child = _children[i];
      if (child.visible && child.off == false) {
        renderState.renderDisplayObject(child);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _collectDescendants(DisplayObject displayObject, List descendants) {

    descendants.add(displayObject);

    if (displayObject is DisplayObjectContainer) {
      var children = displayObject._children;
      for(int i = 0; i < children.length; i++) {
        _collectDescendants(children[i], descendants);
      }
    }
  }

  _dispatchEventDescendants(DisplayObject displayObject, Event event) {

    List descendants = [];
    _collectDescendants(displayObject, descendants);

    for(int i = 0; i < descendants.length; i++) {
      descendants[i].dispatchEvent(event);
    }
  }


}
