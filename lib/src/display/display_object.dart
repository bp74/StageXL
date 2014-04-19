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
  Shadow _shadow = null;
  String _compositeOperation = null;
  List<BitmapFilter> _filters = null;
  RenderTextureQuad _cacheTextureQuad = null;
  bool _cacheDebugBorder = false;

  String _name = "";
  DisplayObjectContainer _parent = null;

  final Matrix _tmpMatrix = new Matrix.fromIdentity();
  final Matrix _transformationMatrix = new Matrix.fromIdentity();
  bool _transformationMatrixRefresh = true;

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> addedEvent = const EventStreamProvider<Event>(Event.ADDED);
  static const EventStreamProvider<Event> removedEvent = const EventStreamProvider<Event>(Event.REMOVED);
  static const EventStreamProvider<Event> addedToStageEvent = const EventStreamProvider<Event>(Event.ADDED_TO_STAGE);
  static const EventStreamProvider<Event> removedFromStageEvent = const EventStreamProvider<Event>(Event.REMOVED_FROM_STAGE);

  EventStream<Event> get onAdded => DisplayObject.addedEvent.forTarget(this);
  EventStream<Event> get onRemoved => DisplayObject.removedEvent.forTarget(this);
  EventStream<Event> get onAddedToStage => DisplayObject.addedToStageEvent.forTarget(this);
  EventStream<Event> get onRemovedFromStage => DisplayObject.removedFromStageEvent.forTarget(this);

  static const EventStreamProvider<EnterFrameEvent> enterFrameEvent = const EventStreamProvider<EnterFrameEvent>(Event.ENTER_FRAME);
  static const EventStreamProvider<ExitFrameEvent> exitFrameEvent = const EventStreamProvider<ExitFrameEvent>(Event.EXIT_FRAME);
  static const EventStreamProvider<RenderEvent> renderEvent = const EventStreamProvider<RenderEvent>(Event.RENDER);

  EventStream<EnterFrameEvent> get onEnterFrame => DisplayObject.enterFrameEvent.forTarget(this);
  EventStream<ExitFrameEvent> get onExitFrame => DisplayObject.exitFrameEvent.forTarget(this);
  EventStream<RenderEvent> get onRender => DisplayObject.renderEvent.forTarget(this);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  /// Gets or sets user-defined data associated with the display object.
  dynamic userData = null;

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
  bool get cached => _cacheTextureQuad != null;

  List<BitmapFilter> get filters {
    if (_filters == null) _filters = new List<BitmapFilter>();
    return _filters;
  }

  Shadow get shadow => _shadow;
  String get compositeOperation => _compositeOperation;

  String get name => _name;
  DisplayObjectContainer get parent => _parent;

  //-------------------------------------------------------------------------------------------------

  Point<num> get mousePosition {
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
    if (value is num) {
      // Clamp values and convert possible integers to double.
      if (value <= 0) value = 0.0;
      if (value >= 1) value = 1.0;
      _alpha = value;
    }
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

  num get width => getBoundsTransformed(this.transformationMatrix).width;
  num get height => getBoundsTransformed(this.transformationMatrix).height;

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

  //-------------------------------------------------------------------------------------------------

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

  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {

    if (returnRectangle != null) {
      returnRectangle.setTo(matrix.tx, matrix.ty, 0, 0);
    } else {
      returnRectangle = new Rectangle<num>(matrix.tx, matrix.ty, 0, 0);
    }

    return returnRectangle;
  }

  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBounds(DisplayObject targetSpace) {

    var returnRectangle = new Rectangle<num>(0, 0, 0, 0);
    var matrix = (targetSpace == null) ? transformationMatrix : transformationMatrixTo(targetSpace);

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

      var stagePoint = new Point<num>(x, y);
      var localPoint = matrix.transformPoint(stagePoint);

      return this.hitTestInput(localPoint.x, localPoint.y) != null;

    } else {

      var rect = this.getBounds(stage);
      return rect.contains(x, y);
    }
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    return getBoundsTransformed(_identityMatrix).contains(localX, localY) ? this : null;
  }

  //-------------------------------------------------------------------------------------------------

  Point<num> localToGlobal(Point<num> localPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    return _tmpMatrix.transformPoint(localPoint);
  }

  //-------------------------------------------------------------------------------------------------

  Point<num> globalToLocal(Point<num> globalPoint) {

    _tmpMatrix.identity();

    for (var current = this; current != null; current = current._parent) {
      _tmpMatrix.concat(current.transformationMatrix);
    }

    _tmpMatrix.invert();

    return _tmpMatrix.transformPoint(globalPoint);
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Caches a rectangular area of the display object for better performance.
   *
   * If the cached area changes, the cache must be refreshed using [refreshCache] or
   * removed using [removeCache]. Calling [applyCache] again with the same parameters
   * will refresh the cache.
   */
  void applyCache(int x, int y, int width, int height, {bool debugBorder: false}) {

    var pixelRatio = Stage.autoHiDpi ? _devicePixelRatio : 1.0;

    var renderTexture = _cacheTextureQuad == null
        ? new RenderTexture(width, height, true, Color.Transparent, pixelRatio)
        : _cacheTextureQuad.renderTexture..resize(width, height);

    _cacheTextureQuad = new RenderTextureQuad(renderTexture, 0, x, y, 0, 0, width, height);
    _cacheDebugBorder = debugBorder;

    refreshCache();
  }

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

  void removeCache() {
    if (_cacheTextureQuad != null) {
      _cacheTextureQuad.renderTexture.dispose();
      _cacheTextureQuad = null;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event) {

    List<DisplayObject> ancestors = null;

    if (event.captures || event.bubbles) {
      for(DisplayObject ancestor = parent; ancestor != null; ancestor = ancestor.parent) {
        if(ancestor._hasPropagationEventListeners(event)) {
          if (ancestors == null) ancestors = [];
          ancestors.add(ancestor);
        }
      }
    }

    if (ancestors != null && event.captures) {
      for(int i = ancestors.length - 1 ; i >= 0; i--) {
        ancestors[i]._dispatchEventInternal(event, this, EventPhase.CAPTURING_PHASE);
        if (event.stopsPropagation) return;
      }
    }

    _dispatchEventInternal(event, this, EventPhase.AT_TARGET);
    if (event.stopsPropagation) return;

    if (ancestors != null && event.bubbles) {
      for(int i = 0; i < ancestors.length; i++) {
        ancestors[i]._dispatchEventInternal(event, this, EventPhase.BUBBLING_PHASE);
        if (event.stopsPropagation) return;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState);

  //-------------------------------------------------------------------------------------------------

  void _renderInternal(RenderState renderState) {

    RenderState maskRenderState;
    RenderState shadowRenderState;
    Mask mask = _mask;
    Shadow shadow = _shadow;

    // render mask and shadow (begin)

    if (mask != null) {
      maskRenderState = new RenderState(renderState.renderContext, renderState.globalMatrix);
      if (mask.targetSpace != null && identical(this, mask.targetSpace) == false) {
        maskRenderState.globalMatrix.prepend(mask.targetSpace.transformationMatrixTo(this));
      }
      maskRenderState.renderContext.beginRenderMask(maskRenderState, mask);
    }

    if (shadow != null) {
      shadowRenderState = new RenderState(renderState.renderContext, renderState.globalMatrix);
      if (shadow.targetSpace != null && identical(this, shadow.targetSpace) == false) {
        shadowRenderState.globalMatrix.prepend(shadow.targetSpace.transformationMatrixTo(this));
      }
      shadowRenderState.renderContext.beginRenderShadow(shadowRenderState, shadow);
    }

    // render DisplayObject

    if (_cacheTextureQuad != null) {
      renderState.renderQuad(_cacheTextureQuad);
    } else if (_filters != null && _filters.length > 0) {
      _renderFiltered(renderState);
    } else {
      render(renderState);
    }

    // render mask and shadow (end)

    if (shadow != null) {
      shadowRenderState.renderContext.endRenderShadow(shadowRenderState, shadow);
    }

    if (mask != null) {
      maskRenderState.renderContext.endRenderMask(maskRenderState, mask);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _renderFiltered(RenderState renderState) {

    RenderContext renderContext = renderState.renderContext;

    if (renderContext is RenderContextWebGL) {

      var bounds = this.getBoundsTransformed(_identityMatrix);
      var boundsLeft = bounds.left.floor();
      var boundsTop = bounds.top.floor();
      var boundsRight = bounds.right.ceil();
      var boundsBottom = bounds.bottom.ceil();

      for (int i = 0; i < filters.length; i++) {
        var overlap = filters[i].overlap;
        boundsLeft += overlap.left;
        boundsTop += overlap.top;
        boundsRight += overlap.right;
        boundsBottom += overlap.bottom;
      }

      var boundsWidth = boundsRight - boundsLeft;
      var boundsHeight = boundsBottom - boundsTop;

      var currentRenderFrameBuffer = renderContext.activeRenderFrameBuffer;
      var flattenRenderFrameBuffer = renderContext.requestRenderFrameBuffer(boundsWidth, boundsHeight);
      var flattenRenderTexture = flattenRenderFrameBuffer.renderTexture;
      var flattenRenderTextureQuad = new RenderTextureQuad(
          flattenRenderTexture, 0, boundsLeft, boundsTop, 0, 0, boundsWidth, boundsHeight);
      var flattenRenderState = new RenderState(renderContext, flattenRenderTextureQuad.bufferMatrix);

      renderContext.activateRenderFrameBuffer(flattenRenderFrameBuffer);
      renderContext.clear(0);
      render(flattenRenderState);

      //----------------------------------------------

      var renderFrameBufferMap = new Map<int, RenderFrameBuffer>();
      renderFrameBufferMap[0] = flattenRenderFrameBuffer;

      RenderTextureQuad sourceRenderTextureQuad = null;
      RenderFrameBuffer sourceRenderFrameBuffer = null;
      RenderFrameBuffer targetRenderFrameBuffer = null;
      RenderState filterRenderState = flattenRenderState;

      for (int i = 0; i < filters.length; i++) {

        BitmapFilter filter = filters[i];
        List<int> renderPassSources = filter.renderPassSources;
        List<int> renderPassTargets = filter.renderPassTargets;

        for (int pass = 0; pass < renderPassSources.length; pass++) {

          int renderPassSource = renderPassSources[pass];
          int renderPassTarget = renderPassTargets[pass];

          // get sourceRenderTextureQuad

          if (renderFrameBufferMap.containsKey(renderPassSource)) {
            sourceRenderFrameBuffer = renderFrameBufferMap[renderPassSource];
            sourceRenderTextureQuad = new RenderTextureQuad(
                sourceRenderFrameBuffer.renderTexture, 0,
                boundsLeft, boundsTop, 0, 0, boundsWidth, boundsHeight);
          } else {
            throw new StateError("Invalid renderPassSource!");
          }

          // get targetRenderFrameBuffer

          if (i == filters.length - 1 && renderPassTarget == renderPassTargets.last) {
            targetRenderFrameBuffer = currentRenderFrameBuffer;
            filterRenderState.copyFrom(renderState);
            renderContext.activateRenderFrameBuffer(targetRenderFrameBuffer);
          } else if (renderFrameBufferMap.containsKey(renderPassTarget)) {
            targetRenderFrameBuffer = renderFrameBufferMap[renderPassTarget];
            filterRenderState.reset(targetRenderFrameBuffer.renderTexture.quad.bufferMatrix);
            filterRenderState.globalMatrix.prependTranslation(-boundsLeft, -boundsTop);
            renderContext.activateRenderFrameBuffer(targetRenderFrameBuffer);
          } else {
            targetRenderFrameBuffer = renderContext.requestRenderFrameBuffer(boundsWidth, boundsHeight);
            filterRenderState.reset(targetRenderFrameBuffer.renderTexture.quad.bufferMatrix);
            filterRenderState.globalMatrix.prependTranslation(-boundsLeft, -boundsTop);
            renderFrameBufferMap[renderPassTarget] = targetRenderFrameBuffer;
            renderContext.activateRenderFrameBuffer(targetRenderFrameBuffer);
            renderContext.clear(0);
          }

          // render filter

          filter.renderFilter(filterRenderState, sourceRenderTextureQuad, pass);

          // release obsolete source RenderFrameBuffer

          if (renderPassSources.skip(pass + 1).every((rps) => rps != renderPassSource)) {
            renderFrameBufferMap.remove(renderPassSource);
            renderContext.releaseRenderFrameBuffer(sourceRenderFrameBuffer);
          }
        }

        renderFrameBufferMap.clear();
        renderFrameBufferMap[0] = targetRenderFrameBuffer;
      }

    } else {

      render(renderState);

    }
  }

}

