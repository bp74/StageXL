part of stagexl.filters;

class AlphaMaskFilter extends BitmapFilter {

  final BitmapData bitmapData;
  final Matrix matrix;

  AlphaMaskFilter(BitmapData bitmapData, [
                  Matrix matrix = null]) :

    bitmapData = bitmapData,
    matrix = (matrix != null) ? matrix : new Matrix.fromIdentity();

  //-----------------------------------------------------------------------------------------------

  BitmapFilter clone() => new AlphaMaskFilter(bitmapData, matrix.clone());

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

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
    RenderState renderState = new RenderState(renderContext, matrix);
    CanvasRenderingContext2D context = renderContext.rawContext;

    context.save();
    context.globalCompositeOperation = "destination-in";
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.rect(offsetX, offsetY, width, height);
    context.clip();
    renderState.globalMatrix.prepend(this.matrix);
    renderState.renderQuad(this.bitmapData.renderTextureQuad);
    context.restore();
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _AlphaMaskProgram alphaMaskProgram = _AlphaMaskProgram.instance;

    renderContext.activateRenderProgram(alphaMaskProgram);
    renderContext.activateRenderTexture(renderTexture);
    bitmapData.renderTexture.activate(renderContext, gl.TEXTURE1);
    alphaMaskProgram.configure(this, renderTextureQuad);
    alphaMaskProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _AlphaMaskProgram extends _BitmapFilterProgram {

  static final _AlphaMaskProgram instance = new _AlphaMaskProgram();

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
