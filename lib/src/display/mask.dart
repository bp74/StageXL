part of stagexl;

abstract class Mask {

  DisplayObject targetSpace = null;
  bool border = false;
  int borderColor = 0xFF000000;
  int borderWidth = 1;

  Mask();

  //-----------------------------------------------------------------------------------------------

  factory Mask.rectangle(num x, num y, num width, num height) {
    return new _RectangleMask(x, y, width, height);
  }

  factory Mask.circle(num x, num y, num radius) {
    return new _CirlceMask(x, y, radius);
  }

  factory Mask.custom(List<Point<num>> points) {
    return new _CustomMask(points);
  }

  factory Mask.shape(Shape shape) {
    return new _ShapeMask(shape);
  }

  //-----------------------------------------------------------------------------------------------

  bool hitTest(num x, num y);

  renderMask(RenderState renderState);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask extends Mask {

  final Rectangle<num> _rectangle;

  _RectangleMask(num x, num y, num width, num height) :
    _rectangle = new Rectangle<num>(x, y, width, height);

  bool hitTest(num x, num y) => _rectangle.contains(x, y);

  void renderMask(RenderState renderState) {

    if (renderState.renderContext is RenderContextCanvas) {
      var renderContext = renderState.renderContext as RenderContextCanvas;
      var context = renderContext.rawContext;
      context.rect(_rectangle.left, _rectangle.top, _rectangle.width, _rectangle.height);
    } else {
      var l = _rectangle.left;
      var t = _rectangle.top;
      var r = _rectangle.right;
      var b = _rectangle.bottom;
      renderState.renderTriangle(l, t, r, t, r, b, Color.Magenta);
      renderState.renderTriangle(l, t, r, b, l, b, Color.Magenta);
    }
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends Mask {

  final Circle<num> _circle;

  _CirlceMask(num x, num y, num radius) : _circle = new Circle<num>(x, y, radius);

  bool hitTest(num x, num y) => _circle.contains(x, y);

  void renderMask(RenderState renderState) {

    if (renderState.renderContext is RenderContextCanvas) {
      var renderContext = renderState.renderContext as RenderContextCanvas;
      var context = renderContext.rawContext;
      context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
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

class _CustomMask extends Mask {

  final Polygon _polygon;
  Rectangle<num> _polygonBounds;
  List<int> _polygonTriangles;

  _CustomMask(List<Point<num>> points) : _polygon = new Polygon(points) {
    _polygonBounds = _polygon.getBounds();
    _polygonTriangles = _polygon.triangulate();
  }

  bool hitTest(num x, num y) => _polygonBounds.contains(x, y) ? _polygon.contains(x, y) : false;

  void renderMask(RenderState renderState) {
    var points = _polygon.points;
    var triangles = _polygonTriangles;

    if (renderState.renderContext is RenderContextCanvas) {
      var renderContext = renderState.renderContext as RenderContextCanvas;
      var context = renderContext.rawContext;
      for (int i = 0; i <= points.length; i++) {
        var point = points[i % points.length];
        context.lineTo(point.x, point.y);
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

class _ShapeMask extends Mask {

  final Shape _shape;

  _ShapeMask(Shape shape) : _shape = shape;

  bool hitTest(num x, num y) {
    var context = _dummyCanvasContext;
    var mtx = _shape.transformationMatrix;
    context.setTransform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    context.beginPath();
    _shape.graphics._drawPath(context);
    return context.isPointInPath(x, y);
  }

  void renderMask(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var renderContext = renderState.renderContext as RenderContextCanvas;
      var context = renderContext.rawContext;
      var mtx = _shape.transformationMatrix;
      context.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
      _shape.graphics._drawPath(context);
    } else {
      // TODO: ShapeMask for WebGL
    }
  }
}
