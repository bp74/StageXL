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
///     var rifleScope = Sprite();
///     rifleScope.mask = Mask.circle(0, 0, 50);
///     rifleScope.addChild(world);

abstract class Mask implements RenderMask {
  /// You can use the [transformationMatrix] to change the size,
  /// position, scale, rotation etc. from the Mask.

  final Matrix transformationMatrix = Matrix.fromIdentity();

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
    final rectangle = Rectangle<num>(x, y, width, height);
    return _RectangleMask(rectangle);
  }

  /// Create a circular mask.

  factory Mask.circle(num x, num y, num radius) {
    final graphics = Graphics();
    graphics.circle(x, y, radius);
    graphics.fillColor(Color.Magenta);
    return _GraphicsMask(graphics);
  }

  /// Create a custom mask with a polygonal shape defined by [points].

  factory Mask.custom(List<Point<num>> points) {
    final graphics = Graphics();
    points.forEach((p) => graphics.lineTo(p.x, p.y));
    graphics.fillColor(Color.Magenta);
    return _GraphicsMask(graphics);
  }

  /// Create a custom mask defined by a [Graphics] object.

  factory Mask.graphics(Graphics graphics) => _GraphicsMask(graphics);

  /// Create a custom mask defined by a [Shape] object.

  factory Mask.shape(Shape shape) => _ShapeMask(shape);
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

abstract class _TransformedMask extends Mask {
  bool hitTestTransformed(num x, num y);

  @override
  bool hitTest(num x, num y) {
    final mtx = transformationMatrix;
    final deltaX = x - mtx.tx;
    final deltaY = y - mtx.ty;
    final maskX = (mtx.d * deltaX - mtx.c * deltaY) / mtx.det;
    final maskY = (mtx.a * deltaY - mtx.b * deltaX) / mtx.det;
    return hitTestTransformed(maskX, maskY);
  }

  void renderMaskTransformed(RenderState renderState);

  @override
  void renderMask(RenderState renderState) {
    renderState.push(transformationMatrix, 1.0);
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
  Rectangle<num>? getScissorRectangle(RenderState renderState) {
    renderState.push(transformationMatrix, 1.0);
    final matrix = renderState.globalMatrix;
    final aligned = similar(matrix.b, 0.0) && similar(matrix.c, 0.0);
    final result = aligned ? matrix.transformRectangle(rectangle) : null;
    renderState.pop();
    return result;
  }

  @override
  bool hitTestTransformed(num x, num y) => rectangle.contains(x, y);

  @override
  void renderMaskTransformed(RenderState renderState) {
    final renderContext = renderState.renderContext;

    if (renderContext is RenderContextCanvas) {
      renderContext.setTransform(renderState.globalMatrix);
      renderContext.rawContext.rect(
          rectangle.left, rectangle.top, rectangle.width, rectangle.height);
    } else {
      final l = rectangle.left;
      final t = rectangle.top;
      final r = rectangle.right;
      final b = rectangle.bottom;

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
  bool hitTestTransformed(num x, num y) => graphics.hitTest(x, y);

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
    final mtx = shape.transformationMatrix;
    final deltaX = x - mtx.tx;
    final deltaY = y - mtx.ty;
    final maskX = (mtx.d * deltaX - mtx.c * deltaY) / mtx.det;
    final maskY = (mtx.a * deltaY - mtx.b * deltaX) / mtx.det;
    return shape.graphics.hitTest(maskX, maskY);
  }

  @override
  void renderMaskTransformed(RenderState renderState) {
    renderState.globalMatrix.prepend(shape.transformationMatrix);
    shape.graphics.renderMask(renderState);
  }
}
