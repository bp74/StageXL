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
/// * No added or removed events are dispatched.
/// * Adds an additional draw call in WebGL.
///
/// Possible use cases: tile maps, particle effects, bitmap fonts, ...

class BitmapContainer extends DisplayObject
    implements DisplayObjectParent<Bitmap> {

  final List<Bitmap> _children = new List<Bitmap>();
  final Matrix3D _tmpMatrix1 = new Matrix3D.fromIdentity();
  final Matrix3D _tmpMatrix2 = new Matrix3D.fromIdentity();

  //---------------------------------------------------------------------------

  @override
  DisplayObjectChildren<Bitmap> get children {
    return new DisplayObjectChildren<Bitmap>._(this, _children);
  }

  @override
  int get numChildren => _children.length;

  //---------------------------------------------------------------------------

  @override
  Bitmap getChildAt(int index) {
    return _children[index];
  }

  @override
  Bitmap getChildByName(String name) {
    for (int i = 0; i < _children.length; i++) {
      Bitmap child = _children[i];
      if (child.name == name) return child;
    }
    return null;
  }

  @override
  int getChildIndex(Bitmap child) {
    return _children.indexOf(child);
  }

  @override
  void addChild(Bitmap child) {
    if (child.parent == this) {
      _addLocalChild(child);
    } else {
      child.removeFromParent();
      _children.add(child);
      child._parent = this;
    }
  }

  @override
  void addChildAt(Bitmap child, int index) {
    if (index < 0 || index > _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    } else if (child.parent == this) {
      _addLocalChildAt(child, index);
    } else {
      child.removeFromParent();
      _children.insert(index, child);
      child._parent = this;
    }
  }

  @override
  void removeChild(Bitmap child) {
    if (child.parent != this) {
      throw new ArgumentError("The supplied Bitmap must be a child of the caller.");
    } else {
      int index = _children.indexOf(child);
      child._parent = null;
      _children.removeAt(index);
    }
  }

  @override
  void removeChildAt(int index) {
    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    } else {
      Bitmap child = _children[index];
      child._parent = null;
      _children.removeAt(index);
    }
  }

  @override
  void removeChildren([int beginIndex, int endIndex]) {
    int length = _children.length;
    int i1 = beginIndex is int ? beginIndex : 0;
    int i2 = endIndex is int ? endIndex : length - 1;
    if (i1 > i2) {
      // do nothing
    } else if (i1 < 0 || i1 >= length || i2 < 0 || i2 >= length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    } else {
      for (int i = i1; i <= i2 && i1 < _children.length; i++) {
        removeChildAt(i1);
      }
    }
  }

  @override
  void replaceChildAt(Bitmap child, int index) {
    if (index < 0 || index >= _children.length) {
      throw new ArgumentError("The supplied index is out of bounds.");
    } else if (child.parent == this) {
      if (_children.indexOf(child) == index) return;
      throw new ArgumentError("The bitmap is already a child of this container.");
    } else {
      var oldChild = _children[index];
      var newChild = child;
      newChild.removeFromParent();
      oldChild._parent = null;
      newChild._parent = this;
      _children[index] = newChild;
    }
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

  void _addLocalChild(Bitmap child) {
    List<Bitmap> children = _children;
    Bitmap oldChild;
    Bitmap newChild = child;
    for (int i = children.length - 1; i >= 0; i--) {
      oldChild = children[i];
      children[i] = newChild;
      newChild = oldChild;
      if (child == newChild) break;
    }
  }

  void _addLocalChildAt(DisplayObject child, int index) {
    List<DisplayObject> children = _children;
    children.remove(child);
    if (index > _children.length) index -= 1;
    children.insert(index, child);
  }

  //---------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    var context = renderState.renderContext as RenderContextWebGL;
    var projectionMatrix = context.activeProjectionMatrix;
    var globalMatrix = renderState.globalMatrix;
    var localState = new _BitmapContainerRenderState(renderState);

    _tmpMatrix1.copyFrom(projectionMatrix);
    _tmpMatrix2.copyFrom2DAndConcat(globalMatrix, projectionMatrix);

    context.activateProjectionMatrix(_tmpMatrix2);

    for (int i = 0; i < _children.length; i++) {
      var bitmap = _children[i];
      if (bitmap.visible) {
        var bitmapData = bitmap.bitmapData;
        if (bitmapData != null) {
          localState.bitmap = bitmap;
          context.renderTextureQuad(localState, bitmapData.renderTextureQuad);
        }
      }
    }

    context.activateProjectionMatrix(_tmpMatrix1);
  }

  void _renderCanvas2D(RenderState renderState) {

    var context = renderState.renderContext as RenderContextCanvas;

    for (int i = 0; i < _children.length; i++) {
      var bitmap = _children[i];
      if (bitmap.visible) {
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
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _BitmapContainerRenderState extends RenderState {

  Bitmap bitmap;
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

  @override
  Matrix get globalMatrix => bitmap.transformationMatrix;

  @override
  double get globalAlpha => bitmap.alpha * this.alpha;

  @override
  BlendMode get globalBlendMode => bitmap.blendMode ?? this.blendMode;

  //---------------------------------------------------------------------------

  @override
  void reset([Matrix matrix, num alpha, BlendMode blendMode]) {
    throw new StateError("Not supported");
  }

  @override
  void copyFrom(RenderState renderState) {
    throw new StateError("Not supported");
  }

  @override
  void renderObject(RenderObject renderObject) {
    throw new StateError("Not supported");
  }

  @override
  void push(Matrix matrix, num alpha, BlendMode blendMode) {
    throw new StateError("Not supported");
  }

  @override
  void pop() {
    throw new StateError("Not supported");
  }
}
