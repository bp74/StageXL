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

  BitmapFilter clone() => new TintFilter(factorR, factorG, factorB, factorA);

  //-----------------------------------------------------------------------------------------------

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

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    TintFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$TintFilterProgram", () => new TintFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.renderTintFilterQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class TintFilterProgram extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexColor:      Float32(r), Float32(g), Float32(b), Float32(a)

  @override
  String get vertexShaderSource => """
    
    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute vec4 aVertexColor;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      vTextCoord = aVertexTextCoord;
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      vec4 color = texture2D(uSampler, vTextCoord);
      color = vec4(color.rgb / color.a, color.a);
      color = color * vColor;
      gl_FragColor = vec4(color.rgb * color.a, color.a);
    }
    """;

  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"],  2, 32,  0);
    renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32,  8);
    renderBufferVertex.bindAttribute(attributes["aVertexColor"],     4, 32, 16);
  }

  //-----------------------------------------------------------------------------------------------

  void renderTintFilterQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad,
      TintFilter tintFilter) {

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var ixList = renderTextureQuad.ixList;
    var vxList = renderTextureQuad.vxList;
    var indexCount = ixList.length;
    var vertexCount = vxList.length >> 2;

    var colorR = tintFilter.factorR.toDouble();
    var colorG = tintFilter.factorG.toDouble();
    var colorB = tintFilter.factorB.toDouble();
    var colorA = tintFilter.factorA.toDouble() * alpha;

    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 8) flush();

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxCount = renderBufferVertex.count;

    for(var i = 0; i < indexCount; i++) {
      if (ixIndex > ixData.length - 1) break;
      ixData[ixIndex] = vxCount + ixList[i];
      ixIndex += 1;
    }

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // copy vertex list

    var vxIndex = renderBufferVertex.position;

    for(var i = 0, o = 0; i < vertexCount; i++, o += 4) {

      if (o > vxList.length - 4) break;
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      num u = vxList[o + 2];
      num v = vxList[o + 3];

      if (vxIndex > vxData.length - 8) break;
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = u;
      vxData[vxIndex + 3] = v;
      vxData[vxIndex + 4] = colorR;
      vxData[vxIndex + 5] = colorG;
      vxData[vxIndex + 6] = colorB;
      vxData[vxIndex + 7] = colorA;
      vxIndex += 8;
    }

    renderBufferVertex.position += vertexCount * 8;
    renderBufferVertex.count += vertexCount;
  }
}
