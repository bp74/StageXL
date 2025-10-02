import 'dart:js_interop';

import 'dart:typed_data';

import '../display.dart';
import '../engine.dart';
import '../geom.dart';

class DisplacementMapFilter extends BitmapFilter {
  final BitmapData bitmapData;
  final Matrix matrix;
  final num scaleX;
  final num scaleY;

  DisplacementMapFilter(this.bitmapData,
      [Matrix? matrix, this.scaleX = 16.0, this.scaleY = 16.0])
      : matrix = (matrix != null) ? matrix : Matrix.fromIdentity();

  //-----------------------------------------------------------------------------------------------

  @override
  BitmapFilter clone() =>
      DisplacementMapFilter(bitmapData, matrix.clone(), scaleX, scaleY);

  @override
  Rectangle<int> get overlap {
    final x = (0.5 * scaleX).abs().ceil();
    final y = (0.5 * scaleY).abs().ceil();
    return Rectangle<int>(-x, -y, x + x, y + y);
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    final renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    final mapImageData = this.bitmapData.renderTextureQuad.getImageData();
    final srcImageData = renderTextureQuad.getImageData();
    final dstImageData = renderTextureQuad.createImageData();
    final mapWidth = mapImageData.width;
    final mapHeight = mapImageData.height;
    final srcWidth = srcImageData.width;
    final srcHeight = srcImageData.height;
    final dstWidth = dstImageData.width;
    final dstHeight = dstImageData.height;

    final mapData = mapImageData.data.toDart;
    final srcData = srcImageData.data.toDart;
    final dstData = dstImageData.data.toDart;

    final vxList = renderTextureQuad.vxListQuad;
    final pixelRatio = renderTextureQuad.pixelRatio;
    final scaleX = pixelRatio * this.scaleX;
    final scaleY = pixelRatio * this.scaleX;
    final channelX = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.RED);
    final channelY = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.GREEN);

    // dstPixel[x, y] = srcPixel[
    //     x + ((colorR(x, y) - 128) * scaleX) / 256,
    //     y + ((colorG(x, y) - 128) * scaleY) / 256)];

    final matrix = this.matrix.cloneInvert();
    matrix.prependTranslation(vxList[0], vxList[1]);

    for (var dstY = 0; dstY < dstHeight; dstY++) {
      var mx = dstY * matrix.c + matrix.tx;
      var my = dstY * matrix.d + matrix.ty;
      for (var dstX = 0;
      dstX < dstWidth;
      dstX++, mx += matrix.a, my += matrix.b) {
        var mapX = mx.round();
        var mapY = my.round();
        if (mapX < 0) mapX = 0;
        if (mapY < 0) mapY = 0;
        if (mapX >= mapWidth) mapX = mapWidth - 1;
        if (mapY >= mapHeight) mapY = mapHeight - 1;
        final mapOffset = (mapX + mapY * mapWidth) << 2;
        final srcX =
            dstX + ((mapData[mapOffset + channelX] - 127) * scaleX) ~/ 256;
        final srcY =
            dstY + ((mapData[mapOffset + channelY] - 127) * scaleY) ~/ 256;
        if (srcX >= 0 && srcY >= 0 && srcX < srcWidth && srcY < srcHeight) {
          final srcOffset = (srcX + srcY * srcWidth) << 2;
          final dstOffset = (dstX + dstY * dstWidth) << 2;
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

  //-----------------------------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    final renderContext = renderState.renderContext as RenderContextWebGL;
    final renderTexture = renderTextureQuad.renderTexture;

    final renderProgram = renderContext.getRenderProgram(
        r'$DisplacementMapFilterProgram', DisplacementMapFilterProgram.new);

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.configure(this, renderTextureQuad);
    renderProgram.renderTextureQuad(renderState, renderTextureQuad);
    renderProgram.flush();
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class DisplacementMapFilterProgram extends RenderProgramSimple {
  @override
  String get fragmentShaderSource => '''
      precision mediump float;
      uniform sampler2D uTexSampler;
      uniform sampler2D uMapSampler;
      uniform mat3 uMapMatrix;
      uniform mat3 uDisMatrix;
      varying vec2 vTextCoord;
      varying float vAlpha;
      void main() {
        vec3 mapCoord = vec3(vTextCoord.xy, 1) * uMapMatrix;
        vec4 mapColor = texture2D(uMapSampler, mapCoord.xy);
        vec3 displacement = vec3(mapColor.rg - 0.5, 1) * uDisMatrix;
        gl_FragColor = texture2D(uTexSampler, vTextCoord + displacement.xy) * vAlpha;
      }
      ''';

  void configure(DisplacementMapFilter displacementMapFilter,
      RenderTextureQuad renderTextureQuad) {
    final mapMatrix = Matrix.fromIdentity();
    mapMatrix.copyFromAndConcat(
        displacementMapFilter.matrix, renderTextureQuad.samplerMatrix);
    mapMatrix.invertAndConcat(
        displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    final disMatrix = Matrix.fromIdentity();
    disMatrix.copyFrom(renderTextureQuad.samplerMatrix);
    disMatrix.scale(displacementMapFilter.scaleX, displacementMapFilter.scaleY);

    final uMapMatrix = Float32List.fromList([
      mapMatrix.a,
      mapMatrix.c,
      mapMatrix.tx,
      mapMatrix.b,
      mapMatrix.d,
      mapMatrix.ty,
      0.0,
      0.0,
      1.0
    ]);

    final uDisMatrix = Float32List.fromList([
      disMatrix.a,
      disMatrix.c,
      0.0,
      disMatrix.b,
      disMatrix.d,
      0.0,
      0.0,
      0.0,
      1.0
    ]);

    renderingContext.uniform1i(uniforms['uTexSampler'], 0);
    renderingContext.uniform1i(uniforms['uMapSampler'], 1);
    renderingContext.uniformMatrix3fv(
        uniforms['uMapMatrix'], false, uMapMatrix.toJS);
    renderingContext.uniformMatrix3fv(
        uniforms['uDisMatrix'], false, uDisMatrix.toJS);
  }
}
