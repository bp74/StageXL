class DisplayObjectContainer extends InteractiveObject
{
  List<DisplayObject> _childrens;
  bool _mouseChildren = true;
  bool _tabChildren = true;

  DisplayObjectContainer()
  {
    _childrens = new List<DisplayObject>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get numChildren() => _childrens.length;

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
      int index = _childrens.indexOf(child);
      _childrens.removeRange(index, 1);
      _childrens.add(child);
    }
    else
    {
      addChildAt(child, _childrens.length);
    }

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject addChildAt(DisplayObject child, int index)
  {
    if (index < 0 && index > _childrens.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    if (child == this)
      throw new IllegalArgumentException("Error #2024: An object cannot be added as a child of itself.");

    if (child.parent == this)
    {
      int currentIndex = _childrens.indexOf(child);
      _childrens.removeRange(currentIndex, 1);

      if (index > _childrens.length)
        index --;

      _childrens.insertRange(index, 1, child);
    }
    else
    {
      child.removeFromParent();

      child._setParent(this);
      _childrens.insertRange(index, 1, child);

      child.dispatchEvent(new Event(Event.ADDED, true));

      if (this.stage != null)
        _dispatchEventOnChildren(child, new Event(Event.ADDED_TO_STAGE));
    }

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject removeChild(DisplayObject child)
  {
    int childIndex = _childrens.indexOf(child);

    if (childIndex == -1)
      throw new IllegalArgumentException("Error #2025: The supplied DisplayObject must be a child of the caller.");

    return removeChildAt(childIndex);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject removeChildAt(int index)
  {
    if (index < 0 && index >= _childrens.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    DisplayObject child = _childrens[index];

    child.dispatchEvent(new Event(Event.REMOVED, true));

    if (this.stage != null)
      _dispatchEventOnChildren(child, new Event(Event.REMOVED_FROM_STAGE));

    child._setParent(null);
    _childrens.removeRange(index, 1);

    return child;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildAt(int index)
  {
    if (index < 0 && index >= _childrens.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    return _childrens[index];
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject getChildByName(String name)
  {
    var childrensLength = _childrens.length;

    for(int i = 0; i < childrensLength; i++)
      if (_childrens[i].name == name)
        return _childrens[i];

      return null;
  }

  //-------------------------------------------------------------------------------------------------

  int getChildIndex(DisplayObject child)
  {
      return _childrens.indexOf(child);
  }

  //-------------------------------------------------------------------------------------------------

  void setChildIndex(DisplayObject child, int index)
  {
    if (index < 0 && index >= _childrens.length)
      throw new IllegalArgumentException("Error #2006: The supplied index is out of bounds.");

    int oldIndex = getChildIndex(child);

    if (oldIndex == -1)
      throw new IllegalArgumentException("Error #2025: The supplied DisplayObject must be a child of the caller.");

    _childrens.removeRange(oldIndex, 1);
    _childrens.insertRange(index, 1, child);
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
    _childrens[index1] = child2;
    _childrens[index2] = child1;
  }

  //-------------------------------------------------------------------------------------------------

  void sortChildren(Function compareFunction)
  {
    _childrens.sort(compareFunction);
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

    if (_childrens.length == 0)
      return super.getBoundsTransformed(matrix, returnRectangle);

    num left = double.INFINITY;
    num top = double.INFINITY;
    num right = double.NEGATIVE_INFINITY;
    num bottom = double.NEGATIVE_INFINITY;

    int childrensLength = _childrens.length;

    for (int i = 0; i < childrensLength; i++)
    {
      _tmpMatrix.copyFromAndConcat(_childrens[i]._transformationMatrix, matrix);

      Rectangle rectangle = _childrens[i].getBoundsTransformed(_tmpMatrix, returnRectangle);

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

    for (int i = _childrens.length - 1; i >= 0; i--)
    {
      DisplayObject children = _childrens[i];

      if (children.visible)
      {
        Matrix matrix = children._transformationMatrix;

        double deltaX = localX - matrix.tx;
        double deltaY = localY - matrix.ty;
        double childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
        double childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

        var displayObject = children.hitTestInput(childX, childY);

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
    var childrensLength = _childrens.length;

    for(int i = 0; i < childrensLength; i++)
    {
      DisplayObject child = _childrens[i];

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
      DisplayObjectContainer displayObjectContainer = displayObject;

      List<DisplayObject> childrens = new List<DisplayObject>.from(displayObjectContainer._childrens);
      int childrenLength = childrens.length;

      for(int i =0; i < childrenLength; i++)
        _dispatchEventOnChildren(childrens[i], event);
    }
  }




}
