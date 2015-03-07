part of stagexl.display_ex;

/// This enum defines how the properties (position, rotation, ...) of
/// the Bitmaps in the [BitmapContainer] will affect the rendering.

enum BitmapContainerProperty {
  /// The property is dynamic and therefore updated in every new frame.
  /// This is the behavior you also get with normal DisplayObjects.
  Dynamic,
  /// The property is static and therefore recorded when the Bitmap is
  /// added to the container. Later changes do not affect the rendering.
  Static,
  /// The property is ignored and does not affect the rendering at all.
  Ignore
}

/// The BitmapContainer class is an optimized container for Bitmaps.
///
/// You can only add Bitmaps and you have to decide which properties of the
/// Bitmap should be used for the rendering. If a property is not used you
/// should set it to [BitmapContainerProperty.Ignore]. If a property isn't
/// changed after the Bitmap was added to the container you should set it to
/// [BitmapContainerProperty.Static]. Only properties that change regularly
/// (like the position) should be set to [BitmapContainerProperty.Dynamic].
///
/// You can define the behavior of properties shown below. For best possible
/// performance the [Bitmap.filters] property is not supported.
///
/// [BitmapContainer.bitmapBitmapData]: Default is Static
/// [BitmapContainer.bitmapPosition]: Default is Dynamic
/// [BitmapContainer.bitmapPivot]: Default is Ignore
/// [BitmapContainer.bitmapScale]: Default is Ignore
/// [BitmapContainer.bitmapSkew]: Default is Ignore
/// [BitmapContainer.bitmapRotation]: Default is Ignore
/// [BitmapContainer.bitmapAlpha]: Default is Ignore
/// [BitmapContainer.bitmapVisible]: Default is Ignore

/// Please note that the performance of the [BitmapContainer] my be inferior
/// compared to a standard container like [Sprite]. You will only get better
/// performance if the [BitmapContainer] contains lots of children where
/// several properties are set to ignore or static. Please profile!

class BitmapContainer extends DisplayObjectContainer {

  final BitmapContainerProperty bitmapBitmapData;
  final BitmapContainerProperty bitmapPosition;
  final BitmapContainerProperty bitmapPivot;
  final BitmapContainerProperty bitmapScale;
  final BitmapContainerProperty bitmapSkew;
  final BitmapContainerProperty bitmapRotation;
  final BitmapContainerProperty bitmapAlpha;
  final BitmapContainerProperty bitmapVisible;

  final List<_BitmapContainerBuffer> _buffers = new List<_BitmapContainerBuffer>();

  String _bitmapContainerProgramName = "";

  //---------------------------------------------------------------------------

  BitmapContainer({
    this.bitmapBitmapData: BitmapContainerProperty.Dynamic,
    this.bitmapPosition: BitmapContainerProperty.Dynamic,
    this.bitmapPivot: BitmapContainerProperty.Dynamic,
    this.bitmapScale: BitmapContainerProperty.Dynamic,
    this.bitmapSkew: BitmapContainerProperty.Dynamic,
    this.bitmapRotation: BitmapContainerProperty.Dynamic,
    this.bitmapAlpha: BitmapContainerProperty.Dynamic,
    this.bitmapVisible: BitmapContainerProperty.Dynamic
  }) {

    if (this.bitmapBitmapData == BitmapContainerProperty.Ignore) {
      throw new ArgumentError("The bitmapData property can't be ignored.");
    }

    if (this.bitmapPosition == BitmapContainerProperty.Ignore) {
      throw new ArgumentError("The position properties can't be ignored.");
    }

    _bitmapContainerProgramName = _getBitmapContainerProgramName();
  }

  void dispose() {
    while(_buffers.length > 0) {
      _buffers.removeAt(0).dispose();
    }
  }

  //---------------------------------------------------------------------------

  @override
  void addChildAt(DisplayObject child, int index) {
    if (child is! Bitmap) {
      throw new ArgumentError("BitmapContainer only supports Bitmap children.");
    } else {
      super.addChildAt(child, index);
    }
  }

  // TODO: override other methods that adds or sets children.
  // Only Bitmaps are allowed.

  //---------------------------------------------------------------------------

  /// A rectangle that defines the area of this display object in this display
  /// object's local coordinates.
  ///
  /// The [BitmapContainer] does not calculate the bounds based on its
  /// children, instead a setter is used to define the bounds manually.

  @override
  Rectangle<num> bounds = new Rectangle<num>(0.0, 0.0, 0.0, 0.0);

  /// The hitTestInput is calculated based on the [bounds] rectangle
  /// which is set manually and not calculated dynamically.

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    return bounds.contains(localX, localY) ? this : null;
  }

  @override
  void render(RenderState renderState) {
    var renderContext = renderState.renderContext;
    if (renderContext is RenderContextWebGL) {
      _renderWebGL(renderState);
    } else if (renderContext is RenderContextCanvas) {
      _renderCanvas(renderState);
    } else {
      super.render(renderState);
    }
  }

  //-----------------------------------------------------------------------------------------------

  void _renderWebGL(RenderState renderState) {

    RenderContextWebGL renderContext = renderState.renderContext;

    _BitmapContainerProgram renderProgram = renderContext.getRenderProgram(
        _bitmapContainerProgramName,() => new _BitmapContainerProgram(
            this.bitmapBitmapData, this.bitmapPosition, this.bitmapRotation,
            this.bitmapVisible, this.bitmapPivot, this.bitmapScale,
            this.bitmapAlpha, this.bitmapSkew));

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateBlendMode(renderState.globalBlendMode);
    renderProgram.renderBitmapContainer(renderState, this);
  }

  //-----------------------------------------------------------------------------------------------

  void _renderCanvas(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var renderContextCanvas = renderContext as RenderContextCanvas;

    renderContextCanvas.setTransform(renderState.globalMatrix);
    renderContextCanvas.setAlpha(renderState.globalAlpha);

    // TODO: implement optimized BitmapContainer code for canvas.

    for (int i = 0; i < numChildren; i++) {
      Bitmap bitmap = getChildAt(i);
      if (bitmap.visible && bitmap.off == false) {
        renderState.renderObject(bitmap);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  String _getBitmapContainerProgramName() {
    return r"$BitmapContainerProgram(" +
      this.bitmapBitmapData.toString() + "," +
      this.bitmapPosition.toString() + "," +
      this.bitmapPivot.toString() + "," +
      this.bitmapScale.toString() + "," +
      this.bitmapSkew.toString() + ")" +
      this.bitmapRotation.toString() + "," +
      this.bitmapAlpha.toString() + "," +
      this.bitmapVisible.toString() + ",";
  }

}
