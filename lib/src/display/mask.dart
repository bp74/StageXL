part of stagexl.display;

/// A [Mask] describes a geometric shape to show only a portion of a
/// [DisplayObject]. Pixels inside of the shape are visible and pixels
/// outside of the shape are invisible.
///
/// The mask is placed relative to the [DisplayObject] where it is applied
/// to. However, you can set the [relativeToParent] property to `true` to
/// placed the mask relativ to the DisplayObjects parent.
///
/// Example:
///
///     var rifleScope = new Sprite();
///     rifleScope.mask = new Mask.circle(0, 0, 50);
///     rifleScope.addChild(world);

abstract class Mask implements RenderMask {

  /// You can use the [transformationMatrix] to change the size,
  /// position, scale, rotation etc. from the Mask.

  final Matrix transformationMatrix = new Matrix.fromIdentity();

  /// Set to `true` to place the [Mask] relative to the DisplayObjects
  /// parent. The default value is `false` and therefore the mask is
  /// placed relative to the DisplayObject where it is applied to.

  @override
  bool relativeToParent = false;

  @override
  bool border = false;

  @override
  int borderColor = 0xFF000000;

  @override
  int borderWidth = 1;

  Mask();

  bool hitTest(num x, num y);

  @override
  void renderMask(RenderState renderState);

  //---------------------------------------------------------------------------

  /// Create a rectangular mask.

  factory Mask.rectangle(num x, num y, num width, num height) {
    var rectangle = new Rectangle<num>(x, y, width, height);
    return new _RectangleMask(rectangle);
  }

  /// Create a circular mask.

  factory Mask.circle(num x, num y, num radius) {
    var graphics = new Graphics();
    graphics.circle(x, y, radius);
    graphics.fillColor(Color.Magenta);
    return new _GraphicsMask(graphics);
  }

  /// Create a custom mask with a polygonal shape defined by [points].

  factory Mask.custom(List<Point<num>> points) {
    var graphics = new Graphics();
    points.forEach((p) => graphics.lineTo(p.x, p.y));
    graphics.fillColor(Color.Magenta);
    return new _GraphicsMask(graphics);
  }

  /// Create a custom mask defined by a [Graphics] object.

  factory Mask.graphics(Graphics graphics) {
    return new _GraphicsMask(graphics);
  }

  /// Create a custom mask defined by a [Shape] object.

  factory Mask.shape(Shape shape) {
    return new _ShapeMask(shape);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

abstract class _TransformedMask extends Mask {

  bool hitTestTransformed(num x, num y);

  @override
  bool hitTest(num x, num y) {
    Matrix mtx = this.transformationMatrix;
    num deltaX = x - mtx.tx;
    num deltaY = y - mtx.ty;
    num maskX = (mtx.d * deltaX - mtx.c * deltaY) / mtx.det;
    num maskY = (mtx.a * deltaY - mtx.b * deltaX) / mtx.det;
    return hitTestTransformed(maskX, maskY);
  }

  void renderMaskTransformed(RenderState renderState);

  @override
  void renderMask(RenderState renderState) {
    renderState.push(this.transformationMatrix, 1.0, null);
    renderMaskTransformed(renderState);
    renderState.pop();
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _RectangleMask extends _TransformedMask implements ScissorRenderMask {

  final Rectangle<num> rectangle;

  _RectangleMask(this.rectangle);

  @override
  Rectangle<num> getScissorRectangle(RenderState renderState) {
    renderState.push(this.transformationMatrix, 1.0, null);
    var matrix = renderState.globalMatrix;
    var aligned = similar(matrix.b, 0.0) && similar(matrix.c, 0.0);
    var result = aligned ? matrix.transformRectangle(this.rectangle) : null;
    renderState.pop();
    return result;
  }

  @override
  bool hitTestTransformed(num x, num y) {
    return rectangle.contains(x, y);
  }

  @override
  void renderMaskTransformed(RenderState renderState) {

    var renderContext = renderState.renderContext;

    if (renderContext is RenderContextCanvas) {

      renderContext.setTransform(renderState.globalMatrix);
      renderContext.rawContext.rect(
          rectangle.left, rectangle.top, rectangle.width, rectangle.height);

    } else {

      var l = rectangle.left;
      var t = rectangle.top;
      var r = rectangle.right;
      var b = rectangle.bottom;

      renderState.renderTriangle(l, t, r, t, r, b, Color.Magenta);
      renderState.renderTriangle(l, t, r, b, l, b, Color.Magenta);
    }
  }
}

//-----------------------------------------------------------------------------

class _GraphicsMask extends _TransformedMask {

  final Graphics graphics;

  _GraphicsMask(this.graphics);

  @override
  bool hitTestTransformed(num x, num y) {
    return graphics.hitTest(x, y);
  }

  @override
  void renderMaskTransformed(RenderState renderState) {
    graphics.renderMask(renderState);
  }
}

//-----------------------------------------------------------------------------

class _ShapeMask extends _TransformedMask {

  final Shape shape;

  _ShapeMask(this.shape);

  @override
  bool hitTestTransformed(num x, num y) {
    Matrix mtx = shape.transformationMatrix;
    num deltaX = x - mtx.tx;
    num deltaY = y - mtx.ty;
    num maskX = (mtx.d * deltaX - mtx.c * deltaY) / mtx.det;
    num maskY = (mtx.a * deltaY - mtx.b * deltaX) / mtx.det;
    return shape.graphics.hitTest(maskX, maskY);
  }

  @override
  void renderMaskTransformed(RenderState renderState) {
    renderState.globalMatrix.prepend(shape.transformationMatrix);
    shape.graphics.renderMask(renderState);
  }
}
