part of stagexl;

class AlphaMaskFilter extends BitmapFilter {

  final BitmapData _bitmapData;
  final Matrix _matrix;

  AlphaMaskFilter(BitmapData bitmapData, [Matrix matrix]) :
    _bitmapData = bitmapData,
    _matrix = (matrix != null) ? matrix : new Matrix.fromIdentity();

  Matrix get matrix => _matrix;
  BitmapData get bitmapData => _bitmapData;

  BitmapFilter clone() => new AlphaMaskFilter(_bitmapData, _matrix.clone());
  Rectangle get overlap => new Rectangle.zero();

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    Matrix matrix = renderTextureQuad.drawMatrix;
    CanvasElement canvas = renderTextureQuad.renderTexture.canvas;
    RenderContextCanvas renderContext = new RenderContextCanvas(canvas);
    RenderState renderState = new RenderState(renderContext, matrix, 1.0, CompositeOperation.DESTINATION_IN);
    CanvasRenderingContext2D context = renderContext.rawContext;

    context.save();
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.rect(offsetX, offsetY, width, height);
    context.clip();
    renderState.globalMatrix.prepend(this.matrix);
    renderState.renderQuad(_bitmapData.renderTextureQuad);
    context.restore();
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    renderContext.activateRenderProgram(_alphaMaskProgram);
    renderContext.activateRenderTexture(renderTexture);
    _bitmapData.renderTexture.activate(renderContext, gl.TEXTURE1);
    _alphaMaskProgram.configure(this, renderTextureQuad);
    _alphaMaskProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

final _alphaMaskProgram = new _AlphaMaskProgram();

class _AlphaMaskProgram extends _BitmapFilterProgram {

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform sampler2D uMaskSampler;
      uniform mat3 uMaskMatrix;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec4 color = texture2D(uSampler, vTextCoord);
        vec3 maskCoord = vec3(vTextCoord.xy, 1) * uMaskMatrix;
        vec4 maskColor = texture2D(uMaskSampler, maskCoord.xy);
        gl_FragColor = color * vAlpha * maskColor.a;
      }
      """;

  void configure(AlphaMaskFilter alphaMaskFilter, RenderTextureQuad renderTextureQuad) {

    //var matrix = renderTextureQuad.samplerMatrix.cloneInvert();
    //matrix.concat(alphaMaskFilter.matrix.cloneInvert());
    //matrix.concat(alphaMaskFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var matrix = new Matrix.fromIdentity();
    matrix.copyFromAndConcat(alphaMaskFilter.matrix, renderTextureQuad.samplerMatrix);
    matrix.invertAndConcat(alphaMaskFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var uMaskMatrix = new Float32List.fromList([
        matrix.a, matrix.c, matrix.tx,
        matrix.b, matrix.d, matrix.ty,
        0.0, 0.0, 1.0]);

    _renderingContext.uniformMatrix3fv(_uniformLocations["uMaskMatrix"], false, uMaskMatrix);
    _renderingContext.uniform1i(_uniformLocations["uMaskSampler"], 1);
  }
}
