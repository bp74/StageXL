part of stagexl.drawing.base;

class GraphicsPattern {

  final RenderTextureQuad renderTextureQuad;
  final Matrix matrix;
  final String kind;

  GraphicsPattern.repeat(this.renderTextureQuad, [this.matrix])
      : this.kind = "repeat";

  GraphicsPattern.repeatX(this.renderTextureQuad, [this.matrix])
      : this.kind = "repeat-x";

  GraphicsPattern.repeatY(this.renderTextureQuad, [this.matrix])
      : this.kind = "repeat-y";

  GraphicsPattern.noRepeat(this.renderTextureQuad, [this.matrix])
      : this.kind = "no-repeat";
}
