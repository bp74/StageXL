library stagexl.filters.tint;

import 'dart:html' show ImageData;
import 'dart:typed_data';
import 'dart:web_gl' as gl;

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

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

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

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  int _quadCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexColor:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

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

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;
    varying vec2 vTextCoord;
    varying vec4 vColor;

    void main() {
      gl_FragColor = texture2D(uSampler, vTextCoord)* vColor;
    }
    """;

  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"],  2, 32,  0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 32,  8);
    _renderBufferVertex.bindAttribute(attributes["aVertexColor"],     2, 32, 16);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      _renderBufferVertex.update(0, _quadCount * 4 * 8);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderTintFilterQuad(
    RenderState renderState, RenderTextureQuad renderTextureQuad, TintFilter tintFilter) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

    num colorR = tintFilter.factorR.toDouble();
    num colorG = tintFilter.factorG.toDouble();
    num colorB = tintFilter.factorB.toDouble();
    num colorA = tintFilter.factorA.toDouble() * alpha;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num ox = matrix.tx + offsetX * ma + offsetY * mc;
    num oy = matrix.ty + offsetX * mb + offsetY * md;
    num ax = ma * width;
    num bx = mb * width;
    num cy = mc * height;
    num dy = md * height;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _quadCount * 6 + 6) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _quadCount * 32 + 32) flush();

    var index = _quadCount * 32;
    if (index > vxData.length - 32) return;

    // vertex 1
    vxData[index + 00] = ox;
    vxData[index + 01] = oy;
    vxData[index + 02] = uvList[0];
    vxData[index + 03] = uvList[1];
    vxData[index + 04] = colorR;
    vxData[index + 05] = colorG;
    vxData[index + 06] = colorB;
    vxData[index + 07] = colorA;

    // vertex 2
    vxData[index + 08] = ox + ax;
    vxData[index + 09] = oy + bx;
    vxData[index + 10] = uvList[2];
    vxData[index + 11] = uvList[3];
    vxData[index + 12] = colorR;
    vxData[index + 13] = colorG;
    vxData[index + 14] = colorB;
    vxData[index + 15] = colorA;

    // vertex 3
    vxData[index + 16] = ox + ax + cy;
    vxData[index + 17] = oy + bx + dy;
    vxData[index + 18] = uvList[4];
    vxData[index + 19] = uvList[5];
    vxData[index + 20] = colorR;
    vxData[index + 21] = colorG;
    vxData[index + 22] = colorB;
    vxData[index + 23] = colorA;

    // vertex 4
    vxData[index + 24] = ox + cy;
    vxData[index + 25] = oy + dy;
    vxData[index + 26] = uvList[6];
    vxData[index + 27] = uvList[7];
    vxData[index + 28] = colorR;
    vxData[index + 29] = colorG;
    vxData[index + 30] = colorB;
    vxData[index + 31] = colorA;

    _quadCount += 1;
  }
}
