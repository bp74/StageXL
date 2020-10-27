library stagexl.filters.tint;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/environment.dart' as env;
import '../internal/tools.dart';

class TintFilter extends BitmapFilter {
  num factorR;
  num factorG;
  num factorB;
  num factorA;

  TintFilter(this.factorR, this.factorG, this.factorB, this.factorA);

  TintFilter.fromColor(int color)
      : factorR = colorGetR(color) / 255.0,
        factorG = colorGetG(color) / 255.0,
        factorB = colorGetB(color) / 255.0,
        factorA = colorGetA(color) / 255.0;

  @override
  BitmapFilter clone() => TintFilter(factorR, factorG, factorB, factorA);

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    var isLittleEndianSystem = env.isLittleEndianSystem;

    var d0 = ((isLittleEndianSystem ? factorR : factorA) * 65536).round();
    var d1 = ((isLittleEndianSystem ? factorG : factorB) * 65536).round();
    var d2 = ((isLittleEndianSystem ? factorB : factorG) * 65536).round();
    var d3 = ((isLittleEndianSystem ? factorA : factorR) * 65536).round();

    var renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    var imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for (var index = 0; index <= data.length - 4; index += 4) {
      var c0 = data[index + 0];
      var c1 = data[index + 1];
      var c2 = data[index + 2];
      var c3 = data[index + 3];
      data[index + 0] = ((d0 * c0) | 0) >> 16;
      data[index + 1] = ((d1 * c1) | 0) >> 16;
      data[index + 2] = ((d2 * c2) | 0) >> 16;
      data[index + 3] = ((d3 * c3) | 0) >> 16;
    }

    renderTextureQuad.putImageData(imageData);
  }

  //---------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad? renderTextureQuad, int pass) {
    var renderContext = renderState.renderContext as RenderContextWebGL;
    var renderProgram = renderContext.renderProgramTinted;

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTextureQuad!.renderTexture);
    renderProgram.renderTextureQuad(
        renderState, renderTextureQuad, factorR.toDouble(), factorG.toDouble(), factorB, factorA);
  }
}
