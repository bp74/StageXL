part of stagexl.display;

/// A fast container for Bitmap instances.
///
/// This is a replacement for the DisplayObjectContainer (or Sprite) class
/// which may be useful in certain use cases where lots of Bitmap instances
/// are rendered. The BitmapContainer only takes Bitmap instances and also
/// imposes some restrictions:
///
/// * No filters for the Bitmaps are rendered.
/// * No hitTest and bounds calculation.
/// * Adds an additional draw call in WebGL.
///
/// Possible use cases: tile maps, particle effects, bitmap fonts, ...

class BitmapContainer extends DisplayObject implements DisplayObjectParent {

  final List<Bitmap> _children = new List<Bitmap>();
  final Matrix3D _tmpMatrix1 = new Matrix3D.fromIdentity();
  final Matrix3D _tmpMatrix2 = new Matrix3D.fromIdentity();

  //---------------------------------------------------------------------------

  DisplayObjectChildren get children {
    return new DisplayObjectChildren._(this, _children);
  }

  int get numChildren => _children.length;

  //---------------------------------------------------------------------------

  Bitmap getChildAt(int index) {
    return _children[index];
  }

  Bitmap getChildByName(String name) {
    for (int i = 0; i < _children.length; i++) {
      Bitmap child = _children[i];
      if (child.name == name) return child;
    }
    return null;
  }

  int getChildIndex(Bitmap child) {
    return _children.indexOf(child);
  }

  void addChild(Bitmap child) {
    addChildAt(child, _children.length);
  }

  void addChildAt(Bitmap child, int index) {
    if (child is! Bitmap) {
      throw new ArgumentError("Only Bitmap instances allowed.");
    } else if (child.parent == this) {
      _children.remove(child);
      if (index > _children.length) index -= 1;
      _children.insert(index, child);
    } else {
      child.removeFromParent();
      _children.insert(index, child);
      child._parent = this;
    }
  }

  void removeChild(Bitmap child) {
    int childIndex = _children.indexOf(child);
    if (childIndex != -1) removeChildAt(childIndex);
  }

  void removeChildAt(int index) {
    var child = _children.removeAt(index);
    child._parent = null;
  }

  void removeChildren([int beginIndex, int endIndex]) {

    var length = _children.length;
    if (length == 0) return;
    if (beginIndex == null) beginIndex = 0;
    if (endIndex == null) endIndex = length - 1;

    if (beginIndex < 0 || endIndex < 0 ||
        beginIndex >= length || endIndex >= length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    }

    for (int i = beginIndex; i <= endIndex; i++) {
      if (beginIndex >= _children.length) break;
      removeChildAt(beginIndex);
    }
  }

  void replaceChildAt(Bitmap child, int index) {

    if (child is! Bitmap) {
      throw new ArgumentError("Only Bitmap instances allowed.");
    } else if (child.parent == this) {
      if (_children.indexOf(child) == index) return;
      throw new ArgumentError("The display object is already a child of this container.");
    }

    var oldChild = _children[index];
    var newChild = child;

    newChild.removeFromParent();
    oldChild._parent = null;
    newChild._parent = this;
    _children[index] = newChild;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return new Rectangle<num>(0.0, 0.0, 0.0, 0.0);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    return null;
  }

  @override
  void render(RenderState renderState) {
    if (renderState.renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else {
      _renderCanvas2D(renderState);
    }
  }

  //---------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    RenderContextWebGL context = renderState.renderContext;
    var projectionMatrix = context.activeProjectionMatrix;
    var globalMatrix = renderState.globalMatrix;
    var localState = new _BitmapContainerRenderState(renderState);

    _tmpMatrix1.copyFrom(projectionMatrix);
    _tmpMatrix2.copyFrom2DAndConcat(globalMatrix, projectionMatrix);

    context.activateProjectionMatrix(_tmpMatrix2);

    for (int i = 0; i < _children.length; i++) {
      var bitmap = _children[i];
      var bitmapData = bitmap.bitmapData;
      if (bitmapData != null) {
        localState.bitmap = bitmap;
        context.renderTextureQuad(localState, bitmapData.renderTextureQuad);
      }
    }

    context.activateProjectionMatrix(_tmpMatrix1);
  }

  void _renderCanvas2D(RenderState renderState) {

    RenderContextCanvas context = renderState.renderContext;

    for(int i = 0; i < _children.length; i++) {
      var bitmap = _children[i];
      var bitmapData = bitmap.bitmapData;
      if (bitmapData != null) {
        var matrix = bitmap.transformationMatrix;
        renderState.push(matrix, bitmap.alpha, bitmap.blendMode);
        context.renderTextureQuad(renderState, bitmapData.renderTextureQuad);
        renderState.pop();
      }
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _BitmapContainerRenderState extends RenderState {

  Bitmap bitmap = null;
  final BlendMode blendMode;
  final double alpha;

  _BitmapContainerRenderState(RenderState parent)
      : this.blendMode = parent.globalBlendMode,
        this.alpha = parent.globalAlpha,
        super(parent.renderContext) {

    this.currentTime = parent.currentTime;
    this.deltaTime = parent.deltaTime;
  }

  //---------------------------------------------------------------------------

  Matrix get globalMatrix => bitmap.transformationMatrix;
  double get globalAlpha => bitmap.alpha * this.alpha;
  BlendMode get globalBlendMode => bitmap.blendMode ?? this.blendMode;

  //---------------------------------------------------------------------------

  void reset([Matrix matrix, num alpha, BlendMode blendMode]) {
    throw new StateError("Not supported");
  }

  void copyFrom(RenderState renderState) {
    throw new StateError("Not supported");
  }

  void renderObject(RenderObject renderObject) {
    throw new StateError("Not supported");
  }

  void push(Matrix matrix, num alpha, BlendMode blendMode) {
    throw new StateError("Not supported");
  }

  void pop() {
    throw new StateError("Not supported");
  }
}
