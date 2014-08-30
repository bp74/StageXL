part of stagexl.filters;

class DisplacementMapFilter extends BitmapFilter {

  final BitmapData bitmapData;
  final Matrix matrix;
  final num scaleX;
  final num scaleY;

  DisplacementMapFilter(BitmapData bitmapData, [
                        Matrix matrix = null,
                        num scaleX = 16.0,
                        num scaleY = 16.0]) :

    bitmapData = bitmapData,
    matrix = (matrix != null) ? matrix : new Matrix.fromIdentity(),
    scaleX = scaleX,
    scaleY = scaleY;

  //-----------------------------------------------------------------------------------------------

  BitmapFilter clone() => new DisplacementMapFilter(bitmapData, matrix.clone(), scaleX, scaleY);

  Rectangle<int> get overlap {
    int x = (0.5 * scaleX).abs().ceil();
    int y = (0.5 * scaleY).abs().ceil();
    return new Rectangle<int>(-x, -y, x + x, y + y);
  }

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData mapImageData = this.bitmapData.renderTextureQuad.getImageData();
    ImageData srcImageData = renderTextureQuad.getImageData();
    ImageData dstImageData = renderTextureQuad.createImageData();
    int mapWidth = ensureInt(mapImageData.width);
    int mapHeight = ensureInt(mapImageData.height);
    int srcWidth = ensureInt(srcImageData.width);
    int srcHeight = ensureInt(srcImageData.height);
    int dstWidth = ensureInt(dstImageData.width);
    int dstHeight = ensureInt(dstImageData.height);

    var mapData = mapImageData.data;
    var srcData = srcImageData.data;
    var dstData = dstImageData.data;

    num pixelRatio = renderTextureQuad.renderTexture.storePixelRatio;
    num scaleX = pixelRatio * this.scaleX;
    num scaleY = pixelRatio * this.scaleX;
    int channelX = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.RED);
    int channelY = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.GREEN);

    // dstPixel[x, y] = srcPixel[
    //     x + ((colorR(x, y) - 128) * scaleX) / 256,
    //     y + ((colorG(x, y) - 128) * scaleY) / 256)];

    Matrix matrix = this.matrix.cloneInvert();
    matrix.prependTranslation(renderTextureQuad.offsetX, renderTextureQuad.offsetY);

    for(int dstY = 0; dstY < dstHeight; dstY++) {
      num mx = dstY * matrix.c + matrix.tx;
      num my = dstY * matrix.d + matrix.ty;
      for(int dstX = 0; dstX < dstWidth; dstX++, mx += matrix.a, my += matrix.b) {
        int mapX = mx.round();
        int mapY = my.round();
        if (mapX < 0) mapX = 0;
        if (mapY < 0) mapY = 0;
        if (mapX >= mapWidth) mapX = mapWidth - 1;
        if (mapY >= mapHeight) mapY = mapHeight - 1;
        int mapOffset = (mapX + mapY * mapWidth) << 2;
        int srcX = dstX + ((mapData[mapOffset + channelX] - 127) * scaleX) ~/ 256;
        int srcY = dstY + ((mapData[mapOffset + channelY] - 127) * scaleY) ~/ 256;
        if (srcX >= 0 && srcY >= 0 && srcX < srcWidth && srcY < srcHeight) {
          int srcOffset = (srcX + srcY * srcWidth) << 2;
          int dstOffset = (dstX + dstY * dstWidth) << 2;
          if (srcOffset > srcData.length - 4) continue;
          if (dstOffset > dstData.length - 4) continue;
          dstData[dstOffset + 0] = srcData[srcOffset + 0];
          dstData[dstOffset + 1] = srcData[srcOffset + 1];
          dstData[dstOffset + 2] = srcData[srcOffset + 2];
          dstData[dstOffset + 3] = srcData[srcOffset + 3];
        }
      }
    }

    renderTextureQuad.putImageData(dstImageData);
  }

  //-------------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;
    _DisplacementMapProgram displacementMapProgram = _DisplacementMapProgram.instance;

    renderContext.activateRenderProgram(displacementMapProgram);
    renderContext.activateRenderTexture(renderTexture);
    bitmapData.renderTexture.activate(renderContext, gl.TEXTURE1);
    displacementMapProgram.configure(this, renderTextureQuad);
    displacementMapProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _DisplacementMapProgram extends _BitmapFilterProgram {

  static final _DisplacementMapProgram instance = new _DisplacementMapProgram();

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uSampler;
      uniform sampler2D uMapSampler;
      uniform mat3 uMapMatrix;
      uniform vec2 uMapScale;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec3 mapCoord = vec3(vTextCoord.xy, 1) * uMapMatrix;
        vec4 mapColor = texture2D(uMapSampler, mapCoord.xy);
        vec2 displacement = uMapScale * (mapColor.rg - 0.5);
        gl_FragColor = texture2D(uSampler, vTextCoord + displacement) * vAlpha;
      }
      """;

  void configure(DisplacementMapFilter displacementMapFilter, RenderTextureQuad renderTextureQuad) {

    //var matrix = renderTextureQuad.samplerMatrix.cloneInvert();
    //matrix.concat(displacementMapFilter.matrix.cloneInvert());
    //matrix.concat(displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var matrix = new Matrix.fromIdentity();
    matrix.copyFromAndConcat(displacementMapFilter.matrix, renderTextureQuad.samplerMatrix);
    matrix.invertAndConcat(displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var uMapMatrix = new Float32List.fromList([
        matrix.a, matrix.c, matrix.tx,
        matrix.b, matrix.d, matrix.ty,
        0.0, 0.0, 1.0]);

    var uMapScaleX = displacementMapFilter.scaleX / renderTextureQuad.textureWidth;
    var uMapScaleY = displacementMapFilter.scaleY / renderTextureQuad.textureHeight;

    _renderingContext.uniformMatrix3fv(_uniformLocations["uMapMatrix"], false, uMapMatrix);
    _renderingContext.uniform1i(_uniformLocations["uMapSampler"], 1);
    _renderingContext.uniform2f(_uniformLocations["uMapScale"], uMapScaleX, uMapScaleY);
  }
}
