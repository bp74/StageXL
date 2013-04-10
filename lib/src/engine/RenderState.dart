part of stagexl;

class RenderState {
  
  final CanvasRenderingContext2D _context;
  final List<Matrix> _matrices = new List<Matrix>(100);
  final List<double> _alphas = new List<double>(100);

  int _depth = 0;
  num _currentTime = 0.0;
  num _deltaTime = 0.0;

  RenderState.fromCanvasRenderingContext2D(CanvasRenderingContext2D context, [Matrix matrix]) :
    _context = context {

    for(int i = 0; i < 100; i++) {
      _matrices[i] = new Matrix.fromIdentity();
      _alphas[i] = 1.0;
    }
   
    if (matrix != null)
      _matrices[0].copyFrom(matrix);
    
    var m = _matrices[0];
    var a = _alphas[0];
    
    _context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
    _context.globalAlpha = a;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  CanvasRenderingContext2D get context => _context;
  num get currentTime => _currentTime;
  num get deltaTime => _deltaTime;
  
  //-------------------------------------------------------------------------------------------------

  void reset([Matrix matrix, num currentTime, num deltaTime]) {
    
    if (matrix != null)
      _matrices[0].copyFrom(matrix);
    
    _depth = 0;
    _currentTime = ?currentTime ? currentTime : 0.0;
    _deltaTime = ?deltaTime ? deltaTime : 0.0;
    
    var m = _matrices[0];
    var a = _alphas[0];
    
    _context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
    _context.globalAlpha = a;
    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
  }

  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject) {
    
    var d1 = _depth;
    var d2 = _depth + 1;
    var m1 = _matrices[d1];
    var m2 = _matrices[d2];
    var a1 = _alphas[d1];
    var a2 = _alphas[d2] = displayObject._alpha * a1;
    var mm = m1;
    var mask = displayObject._mask;
    var cache = displayObject._cache;
    
    _depth = d2;    
    m2.copyFromAndConcat(displayObject._transformationMatrix, m1);
    
    // prepare Mask
    if (mask != null) {
      if (mask.targetSpace == null) {
        mm = m2;
      } else if (identical(mask.targetSpace, displayObject)) {
        mm = m2;
      } else if (identical(mask.targetSpace, displayObject.parent)) {
        mm = m1;
      } else {
        mm = mask.targetSpace.transformationMatrixTo(displayObject);
        if (mm == null) mm = _identityMatrix; else mm.concat(m2);
      }
      
      _context.save();
      _context.setTransform(mm.a, mm.b, mm.c, mm.d, mm.tx, mm.ty);
      mask.render(this);
    }

    // render DisplayObject
    _context.setTransform(m2.a, m2.b, m2.c, m2.d, m2.tx, m2.ty);
    _context.globalAlpha = a2;
    
    if (cache != null) {
      cache.render(this);
    } else {
      displayObject.render(this);
    }
        
    // restore Mask
    if (mask != null) {
      _context.restore();
    }

    _depth = d1;
  }

}




