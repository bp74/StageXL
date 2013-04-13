part of stagexl;

class Mask {
  
  DisplayObject targetSpace = null;
  
  Mask();
  
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

  void render(RenderState renderState, Matrix matrix) {
    var context = renderState.context;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _RectangleMask extends Mask {
  
  final Rectangle _rectangle;
  
  _RectangleMask(num x, num y, num width, num height) : _rectangle = new Rectangle(x, y, width, height);
  
  void render(RenderState renderState, Matrix matrix) {
    
    var context = renderState.context;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    
    context.beginPath();
    context.rect(_rectangle.x, _rectangle.y, _rectangle.width, _rectangle.height);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _CirlceMask extends Mask {
  
  final Circle _circle;
  
  _CirlceMask(num x, num y, num radius) : _circle = new Circle(x, y, radius);
  
void render(RenderState renderState, Matrix matrix) {
    
    var context = renderState.context;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty); 
    
    context.beginPath();
    context.arc(_circle.x, _circle.y, _circle.radius, 0, PI * 2.0, false);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _CustomMask extends Mask {
  
  final List<Point> _points;
  
  _CustomMask(List<Point> points) : _points = points.toList(growable:false) {
    
    if (points.length < 3)
      throw new ArgumentError("A custom mask needs at least 3 points.");
  }
  
  void render(RenderState renderState, Matrix matrix) {
    
    var context = renderState.context;
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    
    context.beginPath();
    for(int i = 0; i < _points.length; i++)
      context.lineTo(_points[i].x, _points[i].y);
    context.clip();
  }
}

//-------------------------------------------------------------------------------------------------

class _ShapeMask extends Mask {
  
  final Shape _shape;
  
  _ShapeMask(Shape shape) : _shape = shape;
  
  void render(RenderState renderState, Matrix matrix) {
    
    var context = renderState.context;
    var mtx = matrix.clone();
    mtx.concat(_shape._transformationMatrix);
    
    context.beginPath();
    context.save();
    context.setTransform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    
    _shape.graphics._drawPath(context);
    
    context.restore();
    context.clip();
  }
}
