part of stagexl;

/**
 *
 *
 * dstPixel[x, y] = srcPixel[
 *     x + ((componentX(x, y) - 128) * scaleX) / 256,
 *     y + ((componentY(x, y) - 128) * scaleY) / 256)];
 *
 */

class DisplacementMapFilter extends BitmapFilter {

  final BitmapData bitmapData;
  final Matrix matrix;
  final num scaleX;
  final num scaleY;
  final int componentX;
  final int componentY;
  final int componentAlpha;

  DisplacementMapFilter(BitmapData bitmapData, [
                        Matrix matrix = null,
                        num scaleX = 1.0,
                        num scaleY = 1.0,
                        int componentX = BitmapDataChannel.RED,
                        int componentY = BitmapDataChannel.GREEN,
                        int componentAlpha = BitmapDataChannel.ALPHA]) :

    bitmapData = bitmapData,
    matrix = (matrix != null) ? matrix : new Matrix.fromIdentity(),
    scaleX = scaleX,
    scaleY = scaleY,
    componentX = componentX,
    componentY = componentY,
    componentAlpha = componentAlpha;

  //-----------------------------------------------------------------------------------------------

  BitmapFilter clone() => new DisplacementMapFilter(bitmapData, matrix.clone(),
      scaleX, scaleY, componentX, componentY, componentAlpha);

  Rectangle get overlap => new Rectangle.zero();

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle rectangle]) {
    // TODO: implement DisplacementMapFilter for Canvas2D
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    renderContext.activateRenderProgram(_alphaMaskProgram);
    renderContext.activateRenderTexture(renderTexture);
    bitmapData.renderTexture.activate(renderContext, gl.TEXTURE1);
    _alphaMaskProgram.configure(this, renderTextureQuad);
    _alphaMaskProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

final _displacementMapProgram = new _DisplacementMapProgram();

class _DisplacementMapProgram extends _BitmapFilterProgram {

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

  void configure(DisplacementMapFilter displacementMapFilter, RenderTextureQuad renderTextureQuad) {

    //var matrix = renderTextureQuad.samplerMatrix.cloneInvert();
    //matrix.concat(displacementMapFilter.matrix.cloneInvert());
    //matrix.concat(displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var matrix = new Matrix.fromIdentity();
    matrix.copyFromAndConcat(displacementMapFilter.matrix, renderTextureQuad.samplerMatrix);
    matrix.invertAndConcat(displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var uMaskMatrix = new Float32List.fromList([
        matrix.a, matrix.c, matrix.tx,
        matrix.b, matrix.d, matrix.ty,
        0.0, 0.0, 1.0]);

    _renderingContext.uniformMatrix3fv(_uniformLocations["uMaskMatrix"], false, uMaskMatrix);
    _renderingContext.uniform1i(_uniformLocations["uMaskSampler"], 1);
  }
}
