part of dartflash;

abstract class DisplayObject extends EventDispatcher implements BitmapDrawable
{
  num _x = 0.0;
  num _y = 0.0;
  num _pivotX = 0.0;
  num _pivotY = 0.0;
  num _scaleX = 1.0;
  num _scaleY = 1.0;
  num _rotation = 0.0;

  Matrix _transformationMatrixPrivate;
  bool _transformationMatrixRefresh;

  num _alpha = 1.0;
  bool _visible = true;
  Mask _mask = null;
  
  String _name = "";
  DisplayObjectContainer _parent = null;

  // for internal use only to minimize memory allocations.
  Matrix _tmpMatrix;
  Matrix _tmpMatrixIdentity;
  
  //-------------------------------------------------------------------------------------------------

  DisplayObject()
  {
    _transformationMatrixPrivate = new Matrix.fromIdentity();
    _transformationMatrixRefresh = true;

    _tmpMatrix = new Matrix.fromIdentity();
    _tmpMatrixIdentity = new Matrix.fromIdentity();
  }

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> addedEvent = const EventStreamProvider<Event>(Event.ADDED);
  static const EventStreamProvider<Event> removedEvent = const EventStreamProvider<Event>(Event.REMOVED);
  static const EventStreamProvider<Event> addedToStageEvent = const EventStreamProvider<Event>(Event.ADDED_TO_STAGE);
  static const EventStreamProvider<Event> removedFromStageEvent = const EventStreamProvider<Event>(Event.REMOVED_FROM_STAGE);
   
  Stream<Event> get onAdded => DisplayObject.addedEvent.forTarget(this);  
  Stream<Event> get onRemoved => DisplayObject.removedEvent.forTarget(this);  
  Stream<Event> get onAddedToStage => DisplayObject.addedToStageEvent.forTarget(this);  
  Stream<Event> get onRemovedFromStage => DisplayObject.removedFromStageEvent.forTarget(this);  

  static const EventStreamProvider<EnterFrameEvent> enterFrameEvent = const EventStreamProvider<EnterFrameEvent>(Event.ENTER_FRAME);
  
  Stream<EnterFrameEvent> get onEnterFrame => DisplayObject.enterFrameEvent.forTarget(this);
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get x => _x;
  num get y => _y;
  num get pivotX => _pivotX;
  num get pivotY => _pivotY;

  num get scaleX => _scaleX;
  num get scaleY => _scaleY;
  num get rotation => _rotation;
  num get alpha => _alpha;

  bool get visible => _visible;
  Mask get mask => _mask;
  String get name => _name;

  DisplayObjectContainer get parent => _parent;

  //-------------------------------------------------------------------------------------------------

  DisplayObject get root
  {
    DisplayObject currentObject = this;

    while (currentObject._parent != null)
      currentObject = currentObject._parent;

    return currentObject;
  }

  //-------------------------------------------------------------------------------------------------

  Stage get stage
  {
    DisplayObject root = this.root;

    if (root is Stage)
      return root;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  set x(num value) { _x = value; _transformationMatrixRefresh = true; }
  set y(num value) { _y = value; _transformationMatrixRefresh = true; }
  set pivotX(num value) { _pivotX = value; _transformationMatrixRefresh = true; }
  set pivotY(num value) { _pivotY = value; _transformationMatrixRefresh = true; }
  
  set scaleX(num value) { _scaleX = value; _transformationMatrixRefresh = true; }
  set scaleY(num value) { _scaleY = value; _transformationMatrixRefresh = true; }
  set rotation(num value) { _rotation = value; _transformationMatrixRefresh = true; }
  set alpha(num value) { _alpha = value; _transformationMatrixRefresh = true; }

  set visible(bool value) { _visible = value; _transformationMatrixRefresh = true; }

  set mask(Mask value) { _mask = value; }
  set name(String value) { _name = value; }

  //-------------------------------------------------------------------------------------------------

  num get width => getBoundsTransformed(_transformationMatrix).width;
  num get height => getBoundsTransformed(_transformationMatrix).height;

  void set width(num value)
  {
    this.scaleX = 1;
    num normalWidth = this.width;
    this.scaleX = (normalWidth != 0.0) ? value / normalWidth : 1.0;
  }

  void set height(num value)
  {
    this.scaleY = 1;
    num normalHeight = this.height;
    this.scaleY = (normalHeight != 0.0) ? value / normalHeight : 1.0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addTo(DisplayObjectContainer parent)
  {
    parent.addChild(this);
  }

  void removeFromParent()
  {
    if (_parent != null)
      _parent.removeChild(this);
  }

  //-------------------------------------------------------------------------------------------------

  Matrix get _transformationMatrix
  {
    /*
    _transformationMatrixPrivate.identity();
    _transformationMatrixPrivate.translate(-_pivotX, -_pivotY);
    _transformationMatrixPrivate.scale(_scaleX, _scaleY);
    _transformationMatrixPrivate.rotate(_rotation);
    _transformationMatrixPrivate.translate(_x, _y);
    */

    if (_transformationMatrixRefresh)
    {
      _transformationMatrixRefresh = false;

      if (_rotation == 0.0)
      {
        _transformationMatrixPrivate.setTo(_scaleX, 0.0, 0.0, _scaleY, _x - _pivotX * _scaleX, _y - _pivotY * _scaleY);
      }
      else
      {
        double cosR = cos(_rotation);
        double sinR = sin(_rotation);

        double a =   _scaleX * cosR;
        double b =   _scaleX * sinR;
        double c = - _scaleY * sinR;
        double d =   _scaleY * cosR;
        double tx =  _x - _pivotX * a - _pivotY * c;
        double ty =  _y - _pivotX * b - _pivotY * d;

        _transformationMatrixPrivate.setTo(a, b, c, d, tx, ty);
      }
    }

    return _transformationMatrixPrivate;
  }

  //-------------------------------------------------------------------------------------------------

  Matrix get transformationMatrix
  {
    return _transformationMatrix.clone();
  }

  //-------------------------------------------------------------------------------------------------

  Matrix transformationMatrixTo(DisplayObject targetSpace)
  {
    if (targetSpace == _parent)
      return _transformationMatrix.clone();

    if (targetSpace._parent == this)
      return _transformationMatrix.cloneInvert();

    //------------------------------------------------

    Matrix resultMatrix = new Matrix.fromIdentity();
    DisplayObject resultObject = this;

    while(resultObject != targetSpace && resultObject._parent != null) {
      resultMatrix.concat(resultObject._transformationMatrix);
      resultObject = resultObject._parent;
    }

    if (targetSpace == null && resultObject != null) {
      resultMatrix.concat(resultObject._transformationMatrix);
      resultObject = null;
    }

    if (resultObject == targetSpace)
      return resultMatrix;

    //------------------------------------------------

    Matrix targetMatrix = new Matrix.fromIdentity();
    DisplayObject targetObject = targetSpace;

    while(targetObject != this && targetObject._parent != null) {
      targetMatrix.concat(targetObject._transformationMatrix);
      targetObject = targetObject._parent;
    }

    targetMatrix.invert();

    if (targetObject == this)
      return targetMatrix;

    if (targetObject != resultObject)
      throw new ArgumentError("Error #9001: The supplied DisplayObject has no relationship to the caller.");

    resultMatrix.concat(targetMatrix);

    return resultMatrix;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle])
  {
    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    returnRectangle.x = matrix.tx;
    returnRectangle.y = matrix.ty;
    returnRectangle.width = 0;
    returnRectangle.height = 0;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBounds(DisplayObject targetSpace)
  {
    Rectangle returnRectangle = new Rectangle.zero();
    Matrix matrix = (targetSpace == null) ? _transformationMatrix : transformationMatrixTo(targetSpace);

    return getBoundsTransformed(matrix, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  bool hitTestObject(DisplayObject other)
  {
    //ToDo

    throw new UnimplementedError("Error #2014: Feature is not available at this time.");
  }

  //-------------------------------------------------------------------------------------------------

  bool hitTestPoint(num x, num y, [bool shapeFlag = false])
  {
    Stage stage = this.stage;

    if (stage == null)
      return false;

    Matrix matrix = this.transformationMatrixTo(stage);
    matrix.invert();

    Point point = new Point(x, y);
    point.transform(matrix);

    return getBoundsTransformed(_tmpMatrixIdentity).contains(point.x, point.y);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY)
  {
    if (getBoundsTransformed(_tmpMatrixIdentity).contains(localX, localY))
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  Point localToGlobal(Point localPoint)
  {
    _tmpMatrix.identity();

    for(DisplayObject displayObject = this; displayObject != null; displayObject = displayObject._parent)
      _tmpMatrix.concat(displayObject._transformationMatrix);

    return _tmpMatrix.transformPoint(localPoint);
  }

  //-------------------------------------------------------------------------------------------------

  Point globalToLocal(Point globalPoint)
  {
    _tmpMatrix.identity();

    for(DisplayObject displayObject = this; displayObject != null; displayObject = displayObject._parent)
      _tmpMatrix.concat(displayObject._transformationMatrix);

    _tmpMatrix.invert();

    return _tmpMatrix.transformPoint(globalPoint);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    List<DisplayObject> ancestors = null;

    if (event.captures || event.bubbles)
      for(DisplayObject ancestor = _parent; ancestor != null; ancestor = ancestor._parent)
        if (ancestor.hasEventListener(event.type)) {
          if (ancestors == null) ancestors = new List<DisplayObject>();
          ancestors.add(ancestor);
        }

    if (event.captures && ancestors != null)
      for(int i = ancestors.length - 1 ; i >= 0; i--)
        if (event.stopsPropagation == false)
          ancestors[i]._dispatchEventInternal(event, this, ancestors[i], EventPhase.CAPTURING_PHASE);

    if (event.stopsPropagation == false)
      _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);

    if (event.bubbles && ancestors != null)
      for(int i = 0; i < ancestors.length; i++)
        if (event.stopsPropagation == false)
          ancestors[i]._dispatchEventInternal(event, this, ancestors[i], EventPhase.BUBBLING_PHASE);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _setParent(DisplayObjectContainer value)
  {
    for(var ancestor = value; ancestor != null; ancestor = ancestor._parent)
      if (ancestor == this)
        throw new ArgumentError("Error #2150: An object cannot be added as a child to one of it's children (or children's children, etc.).");

    _parent = value;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState);

}

