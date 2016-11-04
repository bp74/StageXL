library stagexl.filters.tint;

import 'dart:html' show ImageData;

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

  TintFilter.fromColor(int color) :
    this.factorR = colorGetR(color) / 255.0,
    this.factorG = colorGetG(color) / 255.0,
    this.factorB = colorGetB(color) / 255.0,
    this.factorA = colorGetA(color) / 255.0;

  @override
  BitmapFilter clone() => new TintFilter(factorR, factorG, factorB, factorA);

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num> rectangle]) {

    bool isLittleEndianSystem = env.isLittleEndianSystem;

    int d0 = ((isLittleEndianSystem ? this.factorR : this.factorA) * 65536).round();
    int d1 = ((isLittleEndianSystem ? this.factorG : this.factorB) * 65536).round();
    int d2 = ((isLittleEndianSystem ? this.factorB : this.factorG) * 65536).round();
    int d3 = ((isLittleEndianSystem ? this.factorA : this.factorR) * 65536).round();

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    ImageData imageData = renderTextureQuad.getImageData();
    List<int> data = imageData.data;

    for(int index = 0 ; index <= data.length - 4; index += 4) {
      int c0 = data[index + 0];
      int c1 = data[index + 1];
      int c2 = data[index + 2];
      int c3 = data[index + 3];
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
      RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    var renderContext = renderState.renderContext as RenderContextWebGL;
    RenderProgramTinted renderProgram = renderContext.renderProgramTinted;

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTextureQuad.renderTexture);
    renderProgram.renderTextureQuad(renderState, renderTextureQuad,
        this.factorR, this.factorG, this.factorB, this.factorA);
  }

}
