library stagexl.filters.displacement_map;

import 'dart:typed_data';

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/tools.dart';

class DisplacementMapFilter extends BitmapFilter {
  final BitmapData bitmapData;
  final Matrix matrix;
  final num scaleX;
  final num scaleY;

  DisplacementMapFilter(BitmapData bitmapData,
      [Matrix? matrix, num scaleX = 16.0, num scaleY = 16.0])
      : bitmapData = bitmapData,
        matrix = (matrix != null) ? matrix : Matrix.fromIdentity(),
        scaleX = scaleX,
        scaleY = scaleY;

  //-----------------------------------------------------------------------------------------------

  @override
  BitmapFilter clone() {
    return DisplacementMapFilter(bitmapData, matrix.clone(), scaleX, scaleY);
  }

  @override
  Rectangle<int> get overlap {
    var x = (0.5 * scaleX).abs().ceil();
    var y = (0.5 * scaleY).abs().ceil();
    return Rectangle<int>(-x, -y, x + x, y + y);
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    var renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    var mapImageData = this.bitmapData.renderTextureQuad.getImageData();
    var srcImageData = renderTextureQuad.getImageData();
    var dstImageData = renderTextureQuad.createImageData();
    var mapWidth = ensureInt(mapImageData.width);
    var mapHeight = ensureInt(mapImageData.height);
    var srcWidth = ensureInt(srcImageData.width);
    var srcHeight = ensureInt(srcImageData.height);
    var dstWidth = ensureInt(dstImageData.width);
    var dstHeight = ensureInt(dstImageData.height);

    var mapData = mapImageData.data;
    var srcData = srcImageData.data;
    var dstData = dstImageData.data;

    var vxList = renderTextureQuad.vxListQuad;
    var pixelRatio = renderTextureQuad.pixelRatio!;
    var scaleX = pixelRatio * this.scaleX;
    var scaleY = pixelRatio * this.scaleX;
    var channelX = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.RED);
    var channelY = BitmapDataChannel.getCanvasIndex(BitmapDataChannel.GREEN);

    // dstPixel[x, y] = srcPixel[
    //     x + ((colorR(x, y) - 128) * scaleX) / 256,
    //     y + ((colorG(x, y) - 128) * scaleY) / 256)];

    var matrix = this.matrix.cloneInvert();
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
        var mapOffset = (mapX + mapY * mapWidth) << 2;
        var srcX =
            dstX + ((mapData[mapOffset + channelX] - 127) * scaleX) ~/ 256;
        var srcY =
            dstY + ((mapData[mapOffset + channelY] - 127) * scaleY) ~/ 256;
        if (srcX >= 0 && srcY >= 0 && srcX < srcWidth && srcY < srcHeight) {
          var srcOffset = (srcX + srcY * srcWidth) << 2;
          var dstOffset = (dstX + dstY * dstWidth) << 2;
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
      RenderState renderState, RenderTextureQuad? renderTextureQuad, int pass) {
    var renderContext = renderState.renderContext as RenderContextWebGL;
    var renderTexture = renderTextureQuad!.renderTexture;

    var renderProgram = renderContext.getRenderProgram(
        r'$DisplacementMapFilterProgram', () => DisplacementMapFilterProgram());

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
    var mapMatrix = Matrix.fromIdentity();
    mapMatrix.copyFromAndConcat(
        displacementMapFilter.matrix, renderTextureQuad.samplerMatrix);
    mapMatrix.invertAndConcat(
        displacementMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var disMatrix = Matrix.fromIdentity();
    disMatrix.copyFrom(renderTextureQuad.samplerMatrix);
    disMatrix.scale(displacementMapFilter.scaleX, displacementMapFilter.scaleY);

    var uMapMatrix = Float32List.fromList(<double>[
      mapMatrix.a as double,
      mapMatrix.c as double,
      mapMatrix.tx as double,
      mapMatrix.b as double,
      mapMatrix.d as double,
      mapMatrix.ty as double,
      0.0,
      0.0,
      1.0
    ]);

    var uDisMatrix = Float32List.fromList(<double>[
      disMatrix.a as double,
      disMatrix.c as double,
      0.0,
      disMatrix.b as double,
      disMatrix.d as double,
      0.0,
      0.0,
      0.0,
      1.0
    ]);

    renderingContext!.uniform1i(uniforms['uTexSampler'], 0);
    renderingContext!.uniform1i(uniforms['uMapSampler'], 1);
    renderingContext!.uniformMatrix3fv(
        uniforms['uMapMatrix'], false, uMapMatrix);
    renderingContext!.uniformMatrix3fv(
        uniforms['uDisMatrix'], false, uDisMatrix);
  }
}
