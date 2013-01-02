part of dartflash;

class RenderState
{
  CanvasRenderingContext2D _context;

  List<Matrix> _matrices;
  List<double> _alphas;

  int _depth;

  RenderState.fromCanvasRenderingContext2D(CanvasRenderingContext2D context, [Matrix matrix])
  {
    _context = context;
    _matrices = new List<Matrix>(100);
    _alphas = new List<double>(100);

    for(int i = 0; i < 100; i++) {
      _matrices[i] = new Matrix.fromIdentity();
      _alphas[i] = 1.0;
    }

    _depth = 1;
    
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

  //-------------------------------------------------------------------------------------------------

  void reset()
  {
    _depth = 1;
    
    var m = _matrices[0];
    var a = _alphas[0];
    
    _context.setTransform(m.a, m.b, m.c, m.d, m.tx, m.ty);
    _context.globalAlpha = a;
    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
  }

  //-------------------------------------------------------------------------------------------------

  void renderDisplayObject(DisplayObject displayObject)
  {
    var d1 = _depth;
    var d2 = _depth + 1;
    var m1 = _matrices[d1];
    var m2 = _matrices[d2];
    var a1 = _alphas[d1];
    var a2 = _alphas[d2] = displayObject._alpha * a1;

    m2.copyFromAndConcat(displayObject._transformationMatrix, m1);

    _context.setTransform(m2.a, m2.b, m2.c, m2.d, m2.tx, m2.ty);
    _context.globalAlpha = a2;

    _depth = d2;

    if (displayObject.mask == null) {
      displayObject.render(this);
    } else {
      _context.save();
      displayObject.mask.render(this);
      displayObject.render(this);
      _context.restore();
    }

    _depth = d1;
  }

}




