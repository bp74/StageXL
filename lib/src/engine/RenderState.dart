part of stagexl;

class RenderState {
  
  final CanvasRenderingContext2D _context;
  final List<Matrix> _matrices = new List<Matrix>(100);
  final List<double> _alphas = new List<double>(100);
  final List<String> _composite = new List<String>(100);
  int _depth = 0;
  num _currentTime = 0.0;
  num _deltaTime = 0.0;

  RenderState.fromCanvasRenderingContext2D(CanvasRenderingContext2D context, [Matrix matrix]) :
    _context = context {

    for(int i = 0; i < 100; i++) {
      _matrices[i] = new Matrix.fromIdentity();
      _alphas[i] = 1.0;
      _composite[i] = CompositeOperation.SOURCE_OVER;
    }
   
    var m = _matrices[0];
    if (matrix != null) m.copyFrom(matrix);
    
    _context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
    _context.globalAlpha = _alphas[0];
    _context.globalCompositeOperation = _composite[0];
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get context => _context;
  num get currentTime => _currentTime;
  num get deltaTime => _deltaTime;
  
  //-------------------------------------------------------------------------------------------------

  void reset([Matrix matrix, num currentTime, num deltaTime]) {
    
    _depth = 0;
    _currentTime = ?currentTime ? currentTime : 0.0;
    _deltaTime = ?deltaTime ? deltaTime : 0.0;

    var m = _matrices[0];
    if (matrix != null) m.copyFrom(matrix);
    
    _context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
    _context.globalAlpha = _alphas[0];
    _context.globalCompositeOperation = _composite[0];
    
    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
  }
 
  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject) {

    var matrix = displayObject._transformationMatrix;
    var alpha = displayObject._alpha;
    var mask = displayObject._mask;
    var shadow = displayObject._shadow;
    var cache = displayObject._cache;
    var composite = displayObject._compositeOperation;
    
    var d1 = _depth;
    var d2 = _depth + 1;
    var m1 = _matrices[d1];
    var m2 = _matrices[d2];
    var a1 = _alphas[d1];
    var a2 = _alphas[d2] = alpha * a1;
    var c1 = _composite[d1];
    var c2 = _composite[d2] = ((composite == null) ? c1 : composite);
    
    m2.copyFromAndConcat(matrix, m1);
    _depth = d2;
    
    // save context 
    if (mask != null || shadow != null) {
      _context.save();      
    }
    
    // apply Mask
    if (mask != null) {
      
      if (mask.targetSpace == null) {
        matrix = m2;
      } else if (identical(mask.targetSpace, displayObject)) {
        matrix = m2;
      } else if (identical(mask.targetSpace, displayObject.parent)) {
        matrix = m1;
      } else {
        matrix = mask.targetSpace.transformationMatrixTo(displayObject);
        if (matrix == null) matrix = _identityMatrix; else matrix.concat(m2);
      }
      
      mask.render(this, matrix);
    }

    // apply shadow
    if (shadow != null) {
      
      if (shadow.targetSpace == null) {
        matrix = m2;
      } else if (identical(shadow.targetSpace, displayObject)) {
        matrix = m2;
      } else if (identical(shadow.targetSpace, displayObject.parent)) {
        matrix = m1;
      } else {
        matrix = shadow.targetSpace.transformationMatrixTo(displayObject);
        if (matrix == null) matrix = _identityMatrix; else matrix.concat(m2);
      }
      
      shadow.render(this, matrix);
    }

    // render DisplayObject
    
    _context.setTransform(m2.a, m2.b, m2.c, m2.d, m2.tx, m2.ty);
    _context.globalAlpha = a2;
    _context.globalCompositeOperation = c2;
    
    if (cache != null) {
      cache.render(this);
    } else {
      displayObject.render(this);
    }
        
    // restore context
    if (mask != null || shadow != null) {
      _context.restore();
    }

    _depth = d1;
  }

}




