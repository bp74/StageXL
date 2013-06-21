part of stagexl;

class Shadow {

  int color;
  num offsetX;
  num offsetY;
  num blur;
  DisplayObject targetSpace;

  CanvasRenderingContext2D _context;

  Shadow(this.color, this.offsetX , this.offsetY, this.blur);

  beginRenderShadow(RenderState renderState, Matrix matrix) {

    _context = renderState.context;
    _context.save();
    _context.shadowColor = _color2rgba(color);
    _context.shadowBlur = sqrt(matrix.det) * blur;;
    _context.shadowOffsetX = offsetX * matrix.a + offsetY * matrix.c;
    _context.shadowOffsetY = offsetX * matrix.b + offsetY * matrix.d;
  }

  endRenderShadow() {

    _context.restore();
  }
}
