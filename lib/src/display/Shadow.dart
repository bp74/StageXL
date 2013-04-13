part of stagexl;

class Shadow {

  int color;  
  num offsetX;
  num offsetY;
  num blur;
  DisplayObject targetSpace;
  
  Shadow(this.color, this.offsetX , this.offsetY, this.blur);
  
  void render(RenderState renderState, matrix) {

    var context = renderState.context;
    context.shadowColor = _color2rgba(color);
    context.shadowBlur = sqrt(matrix.det) * blur;;
    context.shadowOffsetX = offsetX * matrix.a + offsetY * matrix.c;
    context.shadowOffsetY = offsetX * matrix.b + offsetY * matrix.d;
  }
}
