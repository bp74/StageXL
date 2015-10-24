library stagexl.filters.alpha_mask;

import 'dart:html' show CanvasElement, CanvasRenderingContext2D;
import 'dart:typed_data';

import '../display.dart';
import '../engine.dart';
import '../geom.dart';

class AlphaMaskFilter extends BitmapFilter {

  final BitmapData bitmapData;
  final Matrix matrix;

  AlphaMaskFilter(this.bitmapData, [Matrix matrix = null]):
    matrix = matrix != null ? matrix : new Matrix.fromIdentity();

  BitmapFilter clone() => new AlphaMaskFilter(bitmapData, matrix.clone());

  //---------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {

    RenderTextureQuad renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    Matrix matrix = renderTextureQuad.drawMatrix;
    Float32List vxList = renderTextureQuad.vxList;
    CanvasElement canvas = renderTextureQuad.renderTexture.canvas;
    RenderContextCanvas renderContext = new RenderContextCanvas(canvas);
    RenderState renderState = new RenderState(renderContext, matrix);
    CanvasRenderingContext2D context = renderContext.rawContext;

    context.save();
    context.globalCompositeOperation = "destination-in";
    context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.rect(vxList[0], vxList[1], vxList[8] - vxList[0], vxList[9] - vxList[1]);
    context.clip();
    renderState.globalMatrix.prepend(this.matrix);
    renderState.renderTextureQuad(this.bitmapData.renderTextureQuad);
    context.restore();
  }

  //---------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    AlphaMaskFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$AlphaMaskFilterProgram", () => new AlphaMaskFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.renderAlphaMaskFilterQuad(renderState, renderTextureQuad, this);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class AlphaMaskFilterProgram extends RenderProgram {

  // aVertexPosition:  Float32(x), Float32(y)
  // aVertexTxtCoord:  Float32(u), Float32(v)
  // aVertexMskCoord:  Float32(u), Float32(v)
  // aVertexMskLimit:  Float32(u1), Float32(v1), Float32(u2), Float32(v2)
  // aVertexAlpha:     Float32(a)

  @override
  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTexCoord;
    attribute vec2 aVertexMskCoord;
    attribute vec4 aVertexMskLimit;
    attribute float aVertexAlpha;

    varying vec2 vTexCoord;
    varying vec2 vMskCoord;
    varying vec4 vMskLimit;
    varying float vAlpha;

    void main() {
      vTexCoord = aVertexTexCoord;
      vMskCoord = aVertexMskCoord;
      vMskLimit = aVertexMskLimit;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uTexSampler;
    uniform sampler2D uMskSampler;
    
    varying vec2 vTexCoord;
    varying vec2 vMskCoord;
    varying vec4 vMskLimit;
    varying float vAlpha;   

    void main() {
      float mskX = clamp(vMskCoord.x, vMskLimit[0], vMskLimit[2]);
      float mskY = clamp(vMskCoord.y, vMskLimit[1], vMskLimit[3]);
      vec4 texColor = texture2D(uTexSampler, vTexCoord.xy);
      vec4 mskColor = texture2D(uMskSampler, vec2(mskX, mskY).xy);
      gl_FragColor = texColor * vAlpha * mskColor.a;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uTexSampler"], 0);
    renderingContext.uniform1i(uniforms["uMskSampler"], 1);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 44,  0);
    renderBufferVertex.bindAttribute(attributes["aVertexTexCoord"], 2, 44,  8);
    renderBufferVertex.bindAttribute(attributes["aVertexMskCoord"], 2, 44, 16);
    renderBufferVertex.bindAttribute(attributes["aVertexMskLimit"], 4, 44, 24);
    renderBufferVertex.bindAttribute(attributes["aVertexAlpha"],    1, 44, 40);
  }

  //---------------------------------------------------------------------------

  void renderAlphaMaskFilterQuad(
      RenderState renderState,
      RenderTextureQuad renderTextureQuad,
      AlphaMaskFilter alphaMaskFilter) {

    var alpha = renderState.globalAlpha;
    var ixList = renderTextureQuad.ixList;
    var vxList = renderTextureQuad.vxList;
    var indexCount = ixList.length;
    var vertexCount = vxList.length >> 2;

    var mskQuad = alphaMaskFilter.bitmapData.renderTextureQuad;
    var texMatrix = renderTextureQuad.samplerMatrix;
    var posMatrix = renderState.globalMatrix;

    // Calculate mask bounds and transformation matrix

    var bounds = mskQuad.vxList;
    num mskBoundsX1 = bounds[2] < bounds[10] ? bounds[2] : bounds[10];
    num mskBoundsX2 = bounds[2] > bounds[10] ? bounds[2] : bounds[10];
    num mskBoundsY1 = bounds[3] < bounds[11] ? bounds[3] : bounds[11];
    num mskBoundsY2 = bounds[3] > bounds[11] ? bounds[3] : bounds[11];

    Matrix mskMatrix = mskQuad.samplerMatrix;
    mskMatrix.invertAndConcat(alphaMaskFilter.matrix);
    mskMatrix.invert();

    // Check if the index and vertex buffer are valid and if
    // we need to flush the render program to free the buffers.

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixData == null) return;
    if (ixData.length < ixPosition + indexCount) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxData == null) return;
    if (vxData.length < vxPosition + vertexCount * 11) flush();

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

      if (vxIndex > vxData.length - 11) break;
      vxData[vxIndex + 00] = posMatrix.tx + x * posMatrix.a + y * posMatrix.c;
      vxData[vxIndex + 01] = posMatrix.ty + x * posMatrix.b + y * posMatrix.d;
      vxData[vxIndex + 02] = texMatrix.tx + x * texMatrix.a + y * texMatrix.c;
      vxData[vxIndex + 03] = texMatrix.ty + x * texMatrix.b + y * texMatrix.d;
      vxData[vxIndex + 04] = mskMatrix.tx + x * mskMatrix.a + y * mskMatrix.c;
      vxData[vxIndex + 05] = mskMatrix.ty + x * mskMatrix.b + y * mskMatrix.d;
      vxData[vxIndex + 06] = mskBoundsX1;
      vxData[vxIndex + 07] = mskBoundsY1;
      vxData[vxIndex + 08] = mskBoundsX2;
      vxData[vxIndex + 09] = mskBoundsY2;
      vxData[vxIndex + 10] = alpha;
      vxIndex += 11;
    }

    renderBufferVertex.position += vertexCount * 11;
    renderBufferVertex.count += vertexCount;
  }

}
