part of stagexl;

abstract class DisplayObject extends EventDispatcher implements BitmapDrawable {

  static int _nextID = 0;

  int _id = _nextID++;
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
  BitmapData _cache = null;
  Rectangle _cacheRectangle = null;
  bool _cacheDebugBorder = false;
  List<BitmapFilter> _filters = null;
  Shadow _shadow = null;
  String _compositeOperation = null;

  String _name = "";
  DisplayObjectContainer _parent = null;

  final Matrix _tmpMatrix = new Matrix.fromIdentity();
  final Matrix _transformationMatrixPrivate = new Matrix.fromIdentity();
  bool _transformationMatrixRefresh = true;

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
  static const EventStreamProvider<ExitFrameEvent> exitFrameEvent = const EventStreamProvider<ExitFrameEvent>(Event.EXIT_FRAME);
  static const EventStreamProvider<RenderEvent> renderEvent = const EventStreamProvider<RenderEvent>(Event.RENDER);

  Stream<EnterFrameEvent> get onEnterFrame => DisplayObject.enterFrameEvent.forTarget(this);
  Stream<ExitFrameEvent> get onExitFrame => DisplayObject.exitFrameEvent.forTarget(this);
  Stream<RenderEvent> get onRender => DisplayObject.renderEvent.forTarget(this);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get x => _x;
  num get y => _y;
  num get pivotX => _pivotX;
  num get pivotY => _pivotY;
  num get scaleX => _scaleX;
  num get scaleY => _scaleY;
  num get skewX => _skewX;
  num get skewY => _skewY;
  num get rotation => _rotation;

  bool get visible => _visible;
  bool get off => _off;
  num get alpha => _alpha;

  Mask get mask => _mask;
  bool get cached => _cache != null;

  List<BitmapFilter> get filters {
    if (_filters == null) _filters = new List<BitmapFilter>();
    return _filters;
  }

  Shadow get shadow => _shadow;
  String get compositeOperation => _compositeOperation;

  String get name => _name;
  DisplayObjectContainer get parent => _parent;

  //-------------------------------------------------------------------------------------------------

  Point get mousePosition {
    var stage = this.stage;
    return (stage != null) ? this.globalToLocal(stage._mousePosition) : null;
  }

  num get mouseX {
    var mp = this.mousePosition;
    return (mp != null) ? mp.x : 0.0;
  }

  num get mouseY {
    var mp = this.mousePosition;
    return (mp != null) ? mp.y : 0.0;
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject get root {

    DisplayObject currentObject = this;

    while (currentObject._parent != null)
      currentObject = currentObject._parent;

    return currentObject;
  }

  Stage get stage {

    DisplayObject root = this.root;
    return (root is Stage) ? root : null;
  }

  //-------------------------------------------------------------------------------------------------

  set x(num value) {
    if (value is num) _x = value;
    _transformationMatrixRefresh = true;
  }

  set y(num value) {
    if (value is num) _y = value;
    _transformationMatrixRefresh = true;
  }

  set pivotX(num value) {
    if (value is num) _pivotX = value;
    _transformationMatrixRefresh = true;
  }

  set pivotY(num value) {
    if (value is num) _pivotY = value;
    _transformationMatrixRefresh = true;
  }

  set scaleX(num value) {
    if (value is num) _scaleX = value;
    _transformationMatrixRefresh = true;
  }

  set scaleY(num value) {
    if (value is num) _scaleY = value;
    _transformationMatrixRefresh = true;
  }

  set skewX(num value) {
    if (value is num) _skewX = value;
    _transformationMatrixRefresh = true;
  }

  set skewY(num value) {
    if (value is num) _skewY = value;
    _transformationMatrixRefresh = true;
  }

  set rotation(num value) {
    if (value is num) _rotation = value;
    _transformationMatrixRefresh = true;
  }

  set visible(bool value) {
    if (value is bool) _visible = value;
  }

  set off(bool value) {
    if (value is bool) _off = value;
  }

  set alpha(num value) {
    if (value is num) _alpha = value;
  }

  set mask(Mask value) {
    _mask = value;
  }

  set filters(List<BitmapFilter> value) {
    _filters = value;
  }

  set shadow(Shadow value) {
    _shadow = value;
  }

  set compositeOperation(String value) {
    _compositeOperation = value;
  }

  set name(String value) {
    _name = value;
  }

  //-------------------------------------------------------------------------------------------------

  void setTransform(num x, num y, [num scaleX, num scaleY, num rotation, num skewX, num skewY, num pivotX, num pivotY]) {
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

  //-------------------------------------------------------------------------------------------------

  num get width => getBoundsTransformed(_transformationMatrix).width;
  num get height => getBoundsTransformed(_transformationMatrix).height;

  void set width(num value) {
    this.scaleX = 1;
    num normalWidth = this.width;
    this.scaleX = (normalWidth != 0.0) ? value / normalWidth : 1.0;
  }

  void set height(num value) {
    this.scaleY = 1;
    num normalHeight = this.height;
    this.scaleY = (normalHeight != 0.0) ? value / normalHeight : 1.0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addTo(DisplayObjectContainer parent) {
    parent.addChild(this);
  }

  void removeFromParent() {
    if (_parent != null)
      _parent.removeChild(this);
  }

  //-------------------------------------------------------------------------------------------------

  bool get _visibleAndNotOff => _visible && !_off;

  Matrix get _transformationMatrix {
    /*
    _transformationMatrixPrivate.identity();
    _transformationMatrixPrivate.translate(-_pivotX, -_pivotY);
    _transformationMatrixPrivate.scale(_scaleX, _scaleY);
    _transformationMatrixPrivate.rotate(_rotation);
    _transformationMatrixPrivate.translate(_x, _y);
    */

    if (_transformationMatrixRefresh) {

      _transformationMatrixRefresh = false;

      num skewXrotation =  _skewX + _rotation;
      num skewYrotation =  _skewY + _rotation;

      if (skewXrotation == 0.0 && skewYrotation == 0.0) {

        _transformationMatrixPrivate.setTo(_scaleX, 0.0, 0.0, _scaleY, _x - _pivotX * _scaleX, _y - _pivotY * _scaleY);

      } else {

        num a, b, c, d;
        num cosX = cos(skewXrotation);
        num sinX = sin(skewXrotation);

        if (skewXrotation == skewYrotation) {
          a =   _scaleX * cosX;
          b =   _scaleX * sinX;
          c = - _scaleY * sinX;
          d =   _scaleY * cosX;
        } else {
          a =   _scaleX * cos(skewYrotation);
          b =   _scaleX * sin(skewYrotation);
          c = - _scaleY * sinX;
          d =   _scaleY * cosX;
        }

        num tx =  _x - (_pivotX * a + _pivotY * c);
        num ty =  _y - (_pivotX * b + _pivotY * d);

        _transformationMatrixPrivate.setTo(a, b, c, d, tx, ty);
      }
    }

    return _transformationMatrixPrivate;
  }

  //-------------------------------------------------------------------------------------------------

  Matrix get transformationMatrix {
    return _transformationMatrix.clone();
  }

  //-------------------------------------------------------------------------------------------------

  Matrix transformationMatrixTo(DisplayObject targetSpace) {

    if (targetSpace == _parent)
      return _transformationMatrix.clone();

    if (targetSpace._parent == this)
      return targetSpace._transformationMatrix.cloneInvert();

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
      return null;

    resultMatrix.concat(targetMatrix);

    return resultMatrix;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {

    if (returnRectangle == null)
      returnRectangle = new Rectangle.zero();

    returnRectangle.x = matrix.tx;
    returnRectangle.y = matrix.ty;
    returnRectangle.width = 0;
    returnRectangle.height = 0;

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle getBounds(DisplayObject targetSpace) {

    Rectangle returnRectangle = new Rectangle.zero();
    Matrix matrix = (targetSpace == null) ? _transformationMatrix : transformationMatrixTo(targetSpace);

    return (matrix != null) ? getBoundsTransformed(matrix, returnRectangle) : returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  bool hitTestObject(DisplayObject other) {

    var stage1 = this.stage;
    var stage2 = other.stage;

    if (stage1 == null || stage2 == null || stage1 != stage2) return false;

    var rect1 = this.getBounds(stage1);
    var rect2 = other.getBounds(stage2);

    return rect1.intersects(rect2);
  }

  //-------------------------------------------------------------------------------------------------

  bool hitTestPoint(num x, num y, [bool shapeFlag = false]) {

    var stage = this.stage;
    if (stage == null) return false;

    if (shapeFlag) {
      var matrix = stage.transformationMatrixTo(this);
      if (matrix == null) return false;

      var stagePoint = new Point(x, y);
      var localPoint = matrix.transformPoint(stagePoint);

      return this.hitTestInput(localPoint.x, localPoint.y) != null;

    } else {

      var rect = this.getBounds(stage);
      return rect.contains(x, y);
    }
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {

    if (getBoundsTransformed(_identityMatrix).contains(localX, localY))
      return this;

    return null;
  }

  //-------------------------------------------------------------------------------------------------

  Point localToGlobal(Point localPoint) {

    _tmpMatrix.identity();

    for(DisplayObject displayObject = this; displayObject != null; displayObject = displayObject._parent)
      _tmpMatrix.concat(displayObject._transformationMatrix);

    return _tmpMatrix.transformPoint(localPoint);
  }

  //-------------------------------------------------------------------------------------------------

  Point globalToLocal(Point globalPoint) {

    _tmpMatrix.identity();

    for(DisplayObject displayObject = this; displayObject != null; displayObject = displayObject._parent)
      _tmpMatrix.concat(displayObject._transformationMatrix);

    _tmpMatrix.invert();

    return _tmpMatrix.transformPoint(globalPoint);
  }

  //-------------------------------------------------------------------------------------------------

  void applyCache(int x, int y, int width, int height, {bool debugBorder: false}) {

    var pixelRatio = Stage.autoHiDpi ? _devicePixelRatio : 1.0;

    _cache = new BitmapData(width, height, true, Color.Transparent, pixelRatio);
    _cacheRectangle = new Rectangle(x, y, width, height);
    _cacheDebugBorder = debugBorder;
    refreshCache();
  }

  void refreshCache() {

    if (_cache == null) return;

    var x = _cacheRectangle.x;
    var y = _cacheRectangle.y;
    var width = _cacheRectangle.width;
    var height = _cacheRectangle.height;

    _cache.clear();
    _cache.draw(this, new Matrix(1.0, 0.0, 0.0, 1.0, - x, - y));

    if (_filters != null) {
      for(int i = 0; i < _filters.length; i++) {
        var sourceRectangle = new Rectangle(0, 0, width, height);
        var destinationPoint = new Point.zero();
        _filters[i].apply(_cache, sourceRectangle, _cache, destinationPoint);
      }
    }

    if (_cacheDebugBorder) {
      _cache.fillRect(new Rectangle(0, 0, width, 1), 0xFFFF00FF);
      _cache.fillRect(new Rectangle(width - 1, 0, 1, height), 0xFFFF00FF);
      _cache.fillRect(new Rectangle(0, height - 1, width, 1), 0xFFFF00FF);
      _cache.fillRect(new Rectangle(0, 0, 1, height), 0xFFFF00FF);
    }
  }

  void removeCache() {
    _cache = null;
  }

  void _renderCache(RenderState renderState) {
    renderState.context.translate(_cacheRectangle.x, _cacheRectangle.y);
    _cache.render(renderState);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event) {

    List<DisplayObject> ancestors = null;

    if (event.captures || event.bubbles) {
      for(DisplayObject ancestor = _parent; ancestor != null; ancestor = ancestor._parent) {
        if (ancestor._hasEventListener(event.type, event.captures, event.bubbles)) {
          if (ancestors == null) ancestors = _displayObjectListPool.pop() as List<DisplayObject>;
          ancestors.add(ancestor);
        }
      }
    }

    if (event.captures && ancestors != null) {
      for(int i = ancestors.length - 1 ; i >= 0 && event.stopsPropagation == false; i--) {
        ancestors[i]._dispatchEventInternal(event, this, ancestors[i], EventPhase.CAPTURING_PHASE);
      }
    }

    if (event.stopsPropagation == false) {
      _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);
    }

    if (event.bubbles && ancestors != null) {
      for(int i = 0; i < ancestors.length && event.stopsPropagation == false; i++) {
        ancestors[i]._dispatchEventInternal(event, this, ancestors[i], EventPhase.BUBBLING_PHASE);
      }
    }

    if (ancestors != null) {
      ancestors.clear();
      _displayObjectListPool.push(ancestors);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _setParent(DisplayObjectContainer value) {

    for(var ancestor = value; ancestor != null; ancestor = ancestor._parent)
      if (ancestor == this)
        throw new ArgumentError("Error #2150: An object cannot be added as a child to one of it's children (or children's children, etc.).");

    _parent = value;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState);

}

