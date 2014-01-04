part of stagexl;

abstract class Mask {

  DisplayObject targetSpace = null;
  bool border = false;
  int borderColor = 0xFF000000;
  int borderWidth = 1;

  CanvasRenderingContext2D _context;

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

  final List<Point> _points;
  final Rectangle _bounds = new Rectangle.zero();

  _CustomMask(List<Point> points) : _points = points.toList(growable:false) {
    if (points.length < 3) {
      throw new ArgumentError("A custom mask needs at least 3 points.");
    }

    var maxX = double.NEGATIVE_INFINITY;
    var minX = double.INFINITY;
    var maxY = double.NEGATIVE_INFINITY;
    var minY = double.INFINITY;

    for(int i = 0; i < _points.length; i++) {
      var point = _points[i];
      maxX = max(maxX, point.x);
      minX = min(minX, point.x);
      maxY = max(maxY, point.y);
      minY = min(minY, point.y);
    }
    _bounds.left = minX;
    _bounds.right = maxX;
    _bounds.top = minY;
    _bounds.bottom = maxY;
  }

  _drawCanvasPath(CanvasRenderingContext2D context) {

    for(int i = 0; i < _points.length; i++) {
      var point = _points[i];
      context.lineTo(point.x, point.y);
    }
    context.lineTo(_points[0].x, _points[0].y);
  }

  _drawTriangles(RenderContext context, Matrix matrix) {

  }

  bool hitTest(num x, num y) {

    if (_bounds.contains(x, y) == false) return false;

    // PNPOLY - Point Inclusion in Polygon Test
    // W. Randolph Franklin (WRF)
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

    var hit = false;
    for(int i = 0, j = _points.length - 1; i < _points.length; j = i++) {
      var pointI = _points[i];
      var pointJ = _points[j];
      if ((pointI.y > y) == (pointJ.y > y)) continue;

      num dx = pointJ.x - pointI.x;
      num dy = pointJ.y - pointI.y;
      num tx = x - pointI.x;
      num ty = y - pointI.y;
      if ((tx < ty * dx / dy)) hit = !hit;
    }

    return hit;
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask extends Mask {

  final Shape _shape;

  _ShapeMask(Shape shape) : _shape = shape;

  _drawCanvasPath(CanvasRenderingContext2D context) {
    var mtx = _shape.transformationMatrix;
    context.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    _shape.graphics._drawPath(_context);
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
