class RenderState
{
  html.CanvasRenderingContext2D _context;

  List<Matrix> _matrices;
  List<double> _alphas;

  int _depth;

  RenderState.fromCanvasRenderingContext2D(html.CanvasRenderingContext2D context)
  {
    _context = context;

    _matrices = new List<Matrix>();
    _alphas = new List<double>();
    _depth = 0;

    for(int i = 0; i < 100; i++) {
      _matrices.add(new Matrix.identity());
      _alphas.add(1.0);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  html.CanvasRenderingContext2D get context() => _context;

  //-------------------------------------------------------------------------------------------------

  void reset()
  {
    _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _context.globalAlpha = 1;

    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
    _depth = 0;
  }

  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject)
  {
    _depth++;

    Matrix matrix = _matrices[_depth];
    matrix.copyFromAndConcat(displayObject._transformationMatrix, _matrices[_depth - 1]);
    
    _context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    _context.globalAlpha = _alphas[_depth] = _alphas[_depth - 1] * displayObject._alpha;

    if (displayObject.mask == null) 
    {
      displayObject.render(this);
    } 
    else 
    {
      _context.save();
      displayObject.mask.render(this);
      displayObject.render(this);
      _context.restore();
    }

    _depth--;
  }

  
  



}




