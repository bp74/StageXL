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

  //-----------------------------------------------------------------------------------------------

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

  //-----------------------------------------------------------------------------------------------

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

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class AlphaMaskFilterProgram extends RenderProgram {

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
  // aVertexPosition:  Float32(x), Float32(y)
  // aVertexTxtCoord:  Float32(u), Float32(v)
  // aVertexMskCoord:  Float32(u), Float32(v)
  // aVertexMskLimit:  Float32(u1), Float32(v1), Float32(u2), Float32(v2)
  // aVertexAlpha:     Float32(a)
  //---------------------------------------------------------------------------

  Int16List _indexList;
  Float32List _vertexList;

  gl.Buffer _vertexBuffer;
  gl.Buffer _indexBuffer;
  gl.UniformLocation _uProjectionMatrix;
  gl.UniformLocation _uTexSampler;
  gl.UniformLocation _uMskSampler;

  int _aVertexPosition = 0;
  int _aVertexTexCoord = 0;
  int _aVertexMskCoord = 0;
  int _aVertexMskLimit = 0;
  int _aVertexAlpha = 0;
  int _quadCount = 0;

  //-----------------------------------------------------------------------------------------------

  @override
  void set projectionMatrix(Matrix3D matrix) {
    renderingContext.uniformMatrix4fv(_uProjectionMatrix, false, matrix.data);
  }

  @override
  void activate(RenderContextWebGL renderContext) {

    if (this.contextIdentifier != renderContext.contextIdentifier) {

      super.activate(renderContext);

      _indexList = renderContext.staticIndexList;
      _vertexList = renderContext.dynamicVertexList;
      _indexBuffer = renderingContext.createBuffer();
      _vertexBuffer = renderingContext.createBuffer();

      _uProjectionMatrix = uniformLocations["uProjectionMatrix"];
      _uTexSampler       = uniformLocations["uTexSampler"];
      _uMskSampler       = uniformLocations["uMskSampler"];
      _aVertexPosition   = attributeLocations["aVertexPosition"];
      _aVertexTexCoord   = attributeLocations["aVertexTexCoord"];
      _aVertexMskCoord   = attributeLocations["aVertexMskCoord"];
      _aVertexMskLimit   = attributeLocations["aVertexMskLimit"];
      _aVertexAlpha      = attributeLocations["aVertexAlpha"];

      renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
      renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
      renderingContext.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, _indexList, gl.STATIC_DRAW);
      renderingContext.bufferDataTyped(gl.ARRAY_BUFFER, _vertexList, gl.DYNAMIC_DRAW);
    }

    renderingContext.useProgram(program);
    renderingContext.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    renderingContext.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    renderingContext.uniform1i(_uTexSampler, 0);
    renderingContext.uniform1i(_uMskSampler, 1);

    renderingContext.vertexAttribPointer(_aVertexPosition, 2, gl.FLOAT, false, 44,  0);
    renderingContext.vertexAttribPointer(_aVertexTexCoord, 2, gl.FLOAT, false, 44,  8);
    renderingContext.vertexAttribPointer(_aVertexMskCoord, 2, gl.FLOAT, false, 44, 16);
    renderingContext.vertexAttribPointer(_aVertexMskLimit, 4, gl.FLOAT, false, 44, 24);
    renderingContext.vertexAttribPointer(_aVertexAlpha,    1, gl.FLOAT, false, 44, 40);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      var vertexUpdate = new Float32List.view(_vertexList.buffer, 0, _quadCount * 4 * 11);
      renderingContext.bufferSubDataTyped(gl.ARRAY_BUFFER, 0, vertexUpdate);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

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

    var ixList = _indexList;
    if (ixList == null) return;
    if (ixList.length < _quadCount * 6 + 6) flush();

    var vxList = _vertexList;
    if (vxList == null) return;
    if (vxList.length < _quadCount * 44 + 44) flush();

    // Calculate the 4 vertices of the RenderTextureQuad

    for(int vertex = 0, index = _quadCount * 44; vertex < 4; vertex++, index += 11) {

      num x = offsetX + (vertex == 1 || vertex == 2 ? width  : 0);
      num y = offsetY + (vertex == 2 || vertex == 3 ? height : 0);

      if (index > vxList.length - 11) return; // dart2js_hint

      vxList[index + 00] = posMatrix.tx + x * posMatrix.a + y * posMatrix.c;
      vxList[index + 01] = posMatrix.ty + x * posMatrix.b + y * posMatrix.d;
      vxList[index + 02] = texMatrix.tx + x * texMatrix.a + y * texMatrix.c;
      vxList[index + 03] = texMatrix.ty + x * texMatrix.b + y * texMatrix.d;
      vxList[index + 04] = mskMatrix.tx + x * mskMatrix.a + y * mskMatrix.c;
      vxList[index + 05] = mskMatrix.ty + x * mskMatrix.b + y * mskMatrix.d;
      vxList[index + 06] = mskBoundsX1;
      vxList[index + 07] = mskBoundsY1;
      vxList[index + 08] = mskBoundsX2;
      vxList[index + 09] = mskBoundsY2;
      vxList[index + 10] = alpha;
    }

    _quadCount += 1;
  }
}
