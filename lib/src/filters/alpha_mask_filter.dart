library stagexl.filters.alpha_mask;

import 'dart:html' show CanvasElement, CanvasRenderingContext2D;
import 'dart:typed_data';
import 'dart:web_gl' as gl;

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

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  int _quadCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:  Float32(x), Float32(y)
  // aVertexTxtCoord:  Float32(u), Float32(v)
  // aVertexMskCoord:  Float32(u), Float32(v)
  // aVertexMskLimit:  Float32(u1), Float32(v1), Float32(u2), Float32(v2)
  // aVertexAlpha:     Float32(a)
  //---------------------------------------------------------------------------

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
    super.renderingContext.uniform1i(uniforms["uTexSampler"], 0);
    super.renderingContext.uniform1i(uniforms["uMskSampler"], 1);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 44,  0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTexCoord"], 2, 44,  8);
    _renderBufferVertex.bindAttribute(attributes["aVertexMskCoord"], 2, 44, 16);
    _renderBufferVertex.bindAttribute(attributes["aVertexMskLimit"], 4, 44, 24);
    _renderBufferVertex.bindAttribute(attributes["aVertexAlpha"],    1, 44, 40);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      _renderBufferVertex.update(0, _quadCount * 4 * 11);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderAlphaMaskFilterQuad(RenderState renderState,
                                 RenderTextureQuad renderTextureQuad,
                                 AlphaMaskFilter alphaMaskFilter) {

    RenderTextureQuad mskQuad = alphaMaskFilter.bitmapData.renderTextureQuad;
    Matrix texMatrix = renderTextureQuad.samplerMatrix;
    Matrix posMatrix = renderState.globalMatrix;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    num alpha = renderState.globalAlpha;

    // Calculate mask bounds and transformation matrix

    Float32List mskBounds = mskQuad.uvList;
    num mskBoundsX1 = mskBounds[0] < mskBounds[4] ? mskBounds[0] : mskBounds[4];
    num mskBoundsX2 = mskBounds[0] > mskBounds[4] ? mskBounds[0] : mskBounds[4];
    num mskBoundsY1 = mskBounds[1] < mskBounds[5] ? mskBounds[1] : mskBounds[5];
    num mskBoundsY2 = mskBounds[1] > mskBounds[5] ? mskBounds[1] : mskBounds[5];

    Matrix mskMatrix = mskQuad.samplerMatrix;
    mskMatrix.invertAndConcat(alphaMaskFilter.matrix);
    mskMatrix.invert();

    // Check if the index and vertex buffer are valid and if
    // we need to flush the render program to free the buffers.

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _quadCount * 6 + 6) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _quadCount * 44 + 44) flush();

    // Calculate the 4 vertices of the RenderTextureQuad

    for(int vertex = 0, index = _quadCount * 44; vertex < 4; vertex++, index += 11) {

      num x = offsetX + (vertex == 1 || vertex == 2 ? width  : 0);
      num y = offsetY + (vertex == 2 || vertex == 3 ? height : 0);

      if (index > vxData.length - 11) return; // dart2js_hint

      vxData[index + 00] = posMatrix.tx + x * posMatrix.a + y * posMatrix.c;
      vxData[index + 01] = posMatrix.ty + x * posMatrix.b + y * posMatrix.d;
      vxData[index + 02] = texMatrix.tx + x * texMatrix.a + y * texMatrix.c;
      vxData[index + 03] = texMatrix.ty + x * texMatrix.b + y * texMatrix.d;
      vxData[index + 04] = mskMatrix.tx + x * mskMatrix.a + y * mskMatrix.c;
      vxData[index + 05] = mskMatrix.ty + x * mskMatrix.b + y * mskMatrix.d;
      vxData[index + 06] = mskBoundsX1;
      vxData[index + 07] = mskBoundsY1;
      vxData[index + 08] = mskBoundsX2;
      vxData[index + 09] = mskBoundsY2;
      vxData[index + 10] = alpha;
    }

    _quadCount += 1;
  }
}
