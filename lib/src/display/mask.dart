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

  beginRenderMask(RenderState renderState, Matrix matrix) {

    _context = renderState.context;
    _context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _context.beginPath();
    _drawMask();
    _context.save();
    _context.clip();
  }

  endRenderMask() {

    _context.restore();

    if (border) {
      _context.strokeStyle = _color2rgba(borderColor);
      _context.lineWidth = borderWidth;
      _context.lineCap = "round";
      _context.lineJoin = "round";
      _context.stroke();
    }
  }

  bool hitTest(num x, num y);

  _drawMask();
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask extends Mask {

  final Rectangle _rectangle;

  _RectangleMask(num x, num y, num width, num height) : _rectangle = new Rectangle(x, y, width, height);

  _drawMask() {
    _context.rect(_rectangle.x, _rectangle.y, _rectangle.width, _rectangle.height);
  }

  bool hitTest(num x, num y) {
    return _rectangle.contains(x, y);
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends Mask {

  final Circle _circle;

  _CirlceMask(num x, num y, num radius) : _circle = new Circle(x, y, radius);

  _drawMask() {
    _context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
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

  _drawMask() {
    for(int i = 0; i < _points.length; i++) {
      var point = _points[i];
      _context.lineTo(point.x, point.y);
    }
    _context.lineTo(_points[0].x, _points[0].y);
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

  _drawMask() {
    var mtx = _shape.transformationMatrix;
    _context.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    _shape.graphics._drawPath(_context);
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
