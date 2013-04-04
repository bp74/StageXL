part of stagexl;

class Mask {
  
  factory Mask.rectangle(num x, num y, num width, num height) {
    return new _RectangleMask(x, y, width, height);
  }
  
  factory Mask.circle(num x, num y, num radius) {
    return new _CirlceMask(x, y, radius);
  }
  
  factory Mask.custom(List<Point> points) {
    if (points.length < 3)
      throw new ArgumentError("A custom mask needs at least 3 points.");
    
    return new _CustomMask(points);
  }
   
  factory Mask.shape(Shape shape) {
    return new _ShapeMask(shape);
  }

  void render(RenderState renderState) {
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask implements Mask {
  
  final Rectangle _rectangle;
  
  _RectangleMask(num x, num y, num width, num height) : _rectangle = new Rectangle(x, y, width, height);
  
  void render(RenderState renderState) {
    
    var context = renderState.context;
    context.beginPath();
    context.rect(_rectangle.x, _rectangle.y, _rectangle.width, _rectangle.height);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask implements Mask {
  
  final Circle _circle;
  
  _CirlceMask(num x, num y, num radius) : _circle = new Circle(x, y, radius);
  
  void render(RenderState renderState) {
    
    var context = renderState.context;
    context.beginPath();
    context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _CustomMask implements Mask {
  
  final List<Point> _points;
  
  _CustomMask(List<Point> points) : _points = points;
  
  void render(RenderState renderState) {
    
    var context = renderState.context;
    context.beginPath();
    for(int i = 0; i < _points.length; i++)
      context.lineTo(_points[i].x, _points[i].y);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask implements Mask {
  
  final Shape _shape;
  
  _ShapeMask(Shape shape) : _shape = shape;
  
  void render(RenderState renderState) {
    
    var context = renderState.context;
    var matrix = _shape._transformationMatrix;
    
    context.beginPath();
    context.save();
    context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    
    _shape.graphics._drawPath(renderState.context);
    
    context.restore();
    context.clip();
  }
}
