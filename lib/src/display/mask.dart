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

  factory Mask.custom(List<Point> points) {
    return new _CustomMask(points);
  }

  factory Mask.shape(Shape shape) {
    return new _ShapeMask(shape);
  }

  //-----------------------------------------------------------------------------------------------

  bool hitTest(num x, num y);

  _drawCanvasPath(CanvasRenderingContext2D context);
  _drawTriangles(RenderContext context, Matrix matrix);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask extends Mask {

  final Rectangle _rectangle;

  _RectangleMask(num x, num y, num width, num height) : _rectangle = new Rectangle(x, y, width, height);

  _drawCanvasPath(CanvasRenderingContext2D context) {
    context.rect(_rectangle.x, _rectangle.y, _rectangle.width, _rectangle.height);
  }

  _drawTriangles(RenderContext context, Matrix matrix) {
    var l = _rectangle.left;
    var t = _rectangle.top;
    var r = _rectangle.right;
    var b = _rectangle.bottom;
    context.renderTriangle(l, t, r, t, r, b, matrix, Color.Magenta);
    context.renderTriangle(l, t, r, b, l, b, matrix, Color.Magenta);
  }

  bool hitTest(num x, num y) {
    return _rectangle.contains(x, y);
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends Mask {

  final Circle _circle;

  _CirlceMask(num x, num y, num radius) : _circle = new Circle(x, y, radius);

  _drawCanvasPath(CanvasRenderingContext2D context) {
    context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
  }

  _drawTriangles(RenderContext context, Matrix matrix) {

    var steps = 40;
    var centerX = _circle.x;
    var centerY = _circle.y;
    var currentX = centerX + _circle.radius;
    var currentY = centerY;

    var cosR = cos(2 * PI / steps);
    var sinR = sin(2 * PI / steps);
    var tx = centerX - centerX * cosR + centerY * sinR;
    var ty = centerY - centerX * sinR - centerY * cosR;
    var color = Color.Magenta;

    for(int s = 0; s <= steps; s++) {
      var nextX = currentX * cosR - currentY * sinR + tx;
      var nextY = currentX * sinR + currentY * cosR + ty;
      context.renderTriangle(centerX, centerY, currentX, currentY, nextX, nextY, matrix, color);
      currentX = nextX;
      currentY = nextY;
    }
  }

  bool hitTest(num x, num y) {
    return _circle.contains(x, y);
  }
}

//-------------------------------------------------------------------------------------------------

class _CustomMask extends Mask {

  final Polygon _polygon;
  Rectangle _polygonBounds;
  List<int> _polygonTriangles;

  _CustomMask(List<Point> points) : _polygon = new Polygon(points) {
    _polygonBounds = _polygon.getBounds();
    _polygonTriangles = _polygon.triangulate();
  }

  _drawCanvasPath(CanvasRenderingContext2D context) {

    var points = _polygon.points;

    for(int i = 0; i < points.length; i++) {
      var point = points[i];
      context.lineTo(point.x, point.y);
    }
    context.lineTo(points[0].x, points[0].y);
  }

  _drawTriangles(RenderContext context, Matrix matrix) {

    var points = _polygon.points;
    var color = Color.Magenta;

    for(int i = 0; i <= _polygonTriangles.length - 3; i += 3) {
      var p1 = points[_polygonTriangles[i + 0]];
      var p2 = points[_polygonTriangles[i + 1]];
      var p3 = points[_polygonTriangles[i + 2]];
      context.renderTriangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, matrix, color);
    }
  }

  bool hitTest(num x, num y) {
    return _polygonBounds.contains(x, y) ? _polygon.contains(x, y) : false;
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask extends Mask {

  final Shape _shape;

  _ShapeMask(Shape shape) : _shape = shape;

  _drawCanvasPath(CanvasRenderingContext2D context) {
    var mtx = _shape.transformationMatrix;
    context.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    _shape.graphics._drawPath(context);
  }

  _drawTriangles(RenderContext context, Matrix matrix) {

  }

  bool hitTest(num x, num y) {
    var context = _dummyCanvasContext;
    var mtx = _shape.transformationMatrix;
    context.setTransform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    context.beginPath();
    _shape.graphics._drawPath(context);
    return context.isPointInPath(x, y);
  }
}
