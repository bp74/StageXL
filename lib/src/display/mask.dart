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
///
abstract class Mask implements RenderMask {

  /// You can use the [transformationMatrix] to change the size,
  /// position, scale, rotation etc. from the Mask.
  ///
  final Matrix transformationMatrix = new Matrix.fromIdentity();

  /// Set to `true` to place the [Mask] relative to the DisplayObjects
  /// parent. The default value is `false` and therefore the mask is
  /// placed relative to the DisplayObject where it is applied to.
  ///
  bool relativeToParent = false;

  bool border = false;
  int borderColor = 0xFF000000;
  int borderWidth = 1;

  Mask();

  //-----------------------------------------------------------------------------------------------

  /// Create a rectangluar mask.
  ///
  factory Mask.rectangle(num x, num y, num width, num height) {
    return new _RectangleMask(x, y, width, height);
  }

  /// Create a circular mask.
  ///
  factory Mask.circle(num x, num y, num radius) {
    return new _CirlceMask(x, y, radius);
  }

  /// Create a custom mask with a polygonal shape defined by [points].
  ///
  factory Mask.custom(List<Point<num>> points) {
    return new _CustomMask(points);
  }

  /// Create a custom mask defined by a [Shape]. Currently only the
  /// Canvas2D renderer supports this type of mask. You can't use
  /// this mask with the WebGL renderer.
  ///
  factory Mask.shape(Shape shape) {
    return new _ShapeMask(shape);
  }

  //-----------------------------------------------------------------------------------------------

  bool hitTest(num x, num y);

  void renderMask(RenderState renderState);

}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

abstract class _TransformedMask extends Mask {

  final Matrix globalMatrixOriginal = new Matrix.fromIdentity();

  bool hitTestTransformed(num x, num y);

  void renderMaskTransformed(RenderState renderState);

  bool hitTest(num x, num y) {
    Matrix mtx = this.transformationMatrix;
    num deltaX = x - mtx.tx;
    num deltaY = y - mtx.ty;
    num maskX = (mtx.d * deltaX - mtx.c * deltaY) / mtx.det;
    num maskY = (mtx.a * deltaY - mtx.b * deltaX) / mtx.det;
    return hitTestTransformed(maskX, maskY);
  }

  void renderMask(RenderState renderState) {
    var globalMatrix = renderState.globalMatrix;
    globalMatrixOriginal.copyFrom(globalMatrix);
    globalMatrix.prepend(this.transformationMatrix);
    renderMaskTransformed(renderState);
    globalMatrix.copyFrom(globalMatrixOriginal);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask extends _TransformedMask {

  final Rectangle<num> _rectangle;

  _RectangleMask(num x, num y, num width, num height) :
      _rectangle = new Rectangle<num>(x, y, width, height);

  bool hitTestTransformed(num x, num y) {
    return _rectangle.contains(x, y);
  }

  void renderMaskTransformed(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var rect = _rectangle;

    if (renderContext is RenderContextCanvas) {

      renderContext.setTransform(renderState.globalMatrix);
      renderContext.rawContext.rect(rect.left, rect.top, rect.width, rect.height);

    } else {

      var l = rect.left;
      var t = rect.top;
      var r = rect.right;
      var b = rect.bottom;

      renderState.renderTriangle(l, t, r, t, r, b, Color.Magenta);
      renderState.renderTriangle(l, t, r, b, l, b, Color.Magenta);
    }
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends _TransformedMask {

  final Circle<num> _circle;

  _CirlceMask(num x, num y, num radius) : _circle = new Circle<num>(x, y, radius);

  bool hitTestTransformed(num x, num y) {
    return _circle.contains(x, y);
  }

  void renderMaskTransformed(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var circle = _circle;

    if (renderContext is RenderContextCanvas) {

      renderContext.setTransform(renderState.globalMatrix);
      renderContext.rawContext.arc(circle.x, circle.y, circle.radius, 0, PI * 2.0, false);

    } else {

      var steps = 40;
      var centerX = _circle.x;
      var centerY = _circle.y;
      var currentX = centerX + _circle.radius;
      var currentY = centerY;
      var cosR = cos(2 * PI / steps);
      var sinR = sin(2 * PI / steps);
      var tx = centerX - centerX * cosR + centerY * sinR;
      var ty = centerY - centerX * sinR - centerY * cosR;

      for (int s = 0; s <= steps; s++) {
        var nextX = currentX * cosR - currentY * sinR + tx;
        var nextY = currentX * sinR + currentY * cosR + ty;
        renderState.renderTriangle(centerX, centerY, currentX, currentY, nextX, nextY, Color.Magenta);
        currentX = nextX;
        currentY = nextY;
      }
    }
  }
}

//-------------------------------------------------------------------------------------------------

class _CustomMask extends _TransformedMask {

  final Polygon _polygon;
  Rectangle<num> _polygonBounds;
  List<int> _polygonTriangles;

  _CustomMask(List<Point<num>> points) : _polygon = new Polygon(points) {
    _polygonBounds = _polygon.getBounds();
    _polygonTriangles = _polygon.triangulate();
  }

  bool hitTestTransformed(num x, num y) {
    return _polygonBounds.contains(x, y) ? _polygon.contains(x, y) : false;
  }

  void renderMaskTransformed(RenderState renderState) {

    var points = _polygon.points;
    var triangles = _polygonTriangles;
    var renderContext = renderState.renderContext;

    if (renderContext is RenderContextCanvas) {

      renderContext.setTransform(renderState.globalMatrix);

      for (int i = 0; i <= points.length; i++) {
        var point = points[i % points.length];
        renderContext.rawContext.lineTo(point.x, point.y);
      }

    } else {

      for (int i = 0; i <= triangles.length - 3; i += 3) {
        var p1 = points[triangles[i + 0]];
        var p2 = points[triangles[i + 1]];
        var p3 = points[triangles[i + 2]];
        renderState.renderTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, Color.Magenta);
      }
    }
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask extends _TransformedMask {

  final Shape _shape;

  _ShapeMask(Shape shape) : _shape = shape;

  bool hitTestTransformed(num x, num y) {

    var context = _dummyCanvasContext;
    var mtx = _shape.transformationMatrix;
    context.setTransform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    context.beginPath();

    _shape.graphics._drawPath(context);

    return context.isPointInPath(x, y);
  }

  void renderMaskTransformed(RenderState renderState) {

    var renderContext = renderState.renderContext;

    if (renderContext is RenderContextCanvas) {

      var mtx = _shape.transformationMatrix;
      renderContext.setTransform(renderState.globalMatrix);
      renderContext.rawContext.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
      _shape.graphics._drawPath(renderContext.rawContext);

    } else {

      // TODO: ShapeMask for WebGL

    }
  }
}
