class DisplayObjectContainer extends InteractiveObject
{
  List<DisplayObject> _children;
  bool _mouseChildren = true;
  bool _tabChildren = true;

  DisplayObjectContainer()
  {
    _children = new List<DisplayObject>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get numChildren() => _children.length;

  bool get mouseChildren() => _mouseChildren;
  bool get tabChildren() => _tabChildren;

  void set mouseChildren(bool value) { _mouseChildren = value; }
  void set tabChildren(bool value) { _tabChildren = value; }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  DisplayObject addChild(DisplayObject child)
  {
    if (child.parent == this)
    {
      int index = _children.indexOf(child);
      _children.removeRange(index, 1);
      _children.add(child);
    }
    else
    {
      addChildAt(child, _children.length);
    }

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject addChildAt(DisplayObject child, int index)
  {
    if (index < 0 && index > _children.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    if (child == this)
      throw new IllegalArgumentException("Error #2024: An object cannot be added as a child of itself.");

    if (child.parent == this)
    {
      int currentIndex = _children.indexOf(child);
      _children.removeRange(currentIndex, 1);

      if (index > _children.length)
        index --;

      _children.insertRange(index, 1, child);
    }
    else
    {
      child.removeFromParent();

      child._setParent(this);
      _children.insertRange(index, 1, child);

      child.dispatchEvent(new Event(Event.ADDED, true));

      if (this.stage != null)
        _dispatchEventOnChildren(child, new Event(Event.ADDED_TO_STAGE));
    }

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject removeChild(DisplayObject child)
  {
    int childIndex = _children.indexOf(child);

    if (childIndex == -1)
      throw new IllegalArgumentException("Error #2025: The supplied DisplayObject must be a child of the caller.");

    return removeChildAt(childIndex);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject removeChildAt(int index)
  {
    if (index < 0 && index >= _children.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    DisplayObject child = _children[index];

    child.dispatchEvent(new Event(Event.REMOVED, true));

    if (this.stage != null)
      _dispatchEventOnChildren(child, new Event(Event.REMOVED_FROM_STAGE));

    child._setParent(null);
    _children.removeRange(index, 1);

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildAt(int index)
  {
    if (index < 0 && index >= _children.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    return _children[index];
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildByName(String name)
  {
    var childrenLength = _children.length;

    for(int i = 0; i < childrenLength; i++)
      if (_children[i].name == name)
        return _children[i];

      return null;
  }

  //-------------------------------------------------------------------------------------------------

  int getChildIndex(DisplayObject child)
  {
      return _children.indexOf(child);
  }

  //-------------------------------------------------------------------------------------------------

  void setChildIndex(DisplayObject child, int index)
  {
    if (index < 0 && index >= _children.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    int oldIndex = getChildIndex(child);

    if (oldIndex == -1)
      throw new IllegalArgumentException("Error #2025: The supplied DisplayObject must be a child of the caller.");

    _children.removeRange(oldIndex, 1);
    _children.insertRange(index, 1, child);
  }

  //-------------------------------------------------------------------------------------------------

  void swapChildren(DisplayObject child1, DisplayObject child2)
  {
      int index1 = getChildIndex(child1);
      int index2 = getChildIndex(child2);

      if (index1 == -1 || index2 == -1)
        throw new IllegalArgumentException("Error #2025: The supplied DisplayObject must be a child of the caller.");

      swapChildrenAt(index1, index2);
  }

  //-------------------------------------------------------------------------------------------------

  void swapChildrenAt(int index1, int index2)
  {
    DisplayObject child1 = getChildAt(index1);
    DisplayObject child2 = getChildAt(index2);
    _children[index1] = child2;
    _children[index2] = child1;
  }

  //-------------------------------------------------------------------------------------------------

  void sortChildren(Function compareFunction)
  {
    _children.sort(compareFunction);
  }

  //-------------------------------------------------------------------------------------------------

  bool contains(DisplayObject child)
  {
    for(; child != null; child = child._parent)
      if (child == this)
        return true;

    return false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle = null])
  {
    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    if (_children.length == 0)
      return super.getBoundsTransformed(matrix, returnRectangle);

    num left = double.INFINITY;
    num top = double.INFINITY;
    num right = double.NEGATIVE_INFINITY;
    num bottom = double.NEGATIVE_INFINITY;

    int childrenLength = _children.length;

    for (int i = 0; i < childrenLength; i++)
    {
      _tmpMatrix.copyFromAndConcat(_children[i]._transformationMatrix, matrix);

      Rectangle rectangle = _children[i].getBoundsTransformed(_tmpMatrix, returnRectangle);

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

  DisplayObject hitTestInput(num localX, num localY)
  {
    DisplayObject hit = null;

    for (int i = _children.length - 1; i >= 0; i--)
    {
      DisplayObject child = _children[i];

      if (child.visible)
      {
        Matrix matrix = child._transformationMatrix;

        double deltaX = localX - matrix.tx;
        double deltaY = localY - matrix.ty;
        double childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
        double childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

        var displayObject = child.hitTestInput(childX, childY);

        if (displayObject != null)
        {
          if (displayObject is InteractiveObject)
            if (displayObject.mouseEnabled)
              return _mouseChildren ? displayObject : this;

          hit = this;
        }
      }
    }

    return hit;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState)
  {
    var childrenLength = _children.length;

    for(int i = 0; i < childrenLength; i++)
    {
      DisplayObject child = _children[i];

      if (child.visible)
        renderState.renderDisplayObject(child);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _dispatchEventOnChildren(DisplayObject displayObject, Event event)
  {
    displayObject.dispatchEvent(event);

    if (displayObject is DisplayObjectContainer)
    {
      List<DisplayObject> children = new List<DisplayObject>.from(displayObject._children);
      int childrenLength = children.length;

      for(int i = 0; i < childrenLength; i++)
        _dispatchEventOnChildren(children[i], event);
    }
  }


}
