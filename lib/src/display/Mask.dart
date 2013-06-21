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
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends Mask {

  final Circle _circle;

  _CirlceMask(num x, num y, num radius) : _circle = new Circle(x, y, radius);

  _drawMask() {
    _context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
  }
}

//-------------------------------------------------------------------------------------------------

class _CustomMask extends Mask {

  final List<Point> _points;

  _CustomMask(List<Point> points) : _points = points.toList(growable:false) {
    if (points.length < 3) {
      throw new ArgumentError("A custom mask needs at least 3 points.");
    }
  }

  _drawMask() {
    for(int i = 0; i < _points.length; i++) {
      _context.lineTo(_points[i].x, _points[i].y);
    }
    _context.lineTo(_points[0].x, _points[0].y);
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask extends Mask {

  final Shape _shape;

  _ShapeMask(Shape shape) : _shape = shape;

  _drawMask() {
    var mtx = _shape._transformationMatrix;
    _context.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    _shape.graphics._drawPath(_context);
  }
}
