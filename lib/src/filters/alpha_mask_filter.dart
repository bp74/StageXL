import '../display.dart';
import '../engine.dart';
import '../geom.dart';

class AlphaMaskFilter extends BitmapFilter {
  final BitmapData bitmapData;
  final Matrix matrix;

  AlphaMaskFilter(this.bitmapData, [Matrix? matrix])
      : matrix = matrix ?? Matrix.fromIdentity();

  @override
  BitmapFilter clone() => AlphaMaskFilter(bitmapData, matrix.clone());

  //---------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {
    final renderTextureQuad = rectangle == null
        ? bitmapData.renderTextureQuad
        : bitmapData.renderTextureQuad.cut(rectangle);

    final matrix = renderTextureQuad.drawMatrix;
    final vxList = renderTextureQuad.vxList;
    final canvas = renderTextureQuad.renderTexture.canvas;
    final renderContext = RenderContextCanvas(canvas);
    final renderState = RenderState(renderContext, matrix);
    final context = renderContext.rawContext;

    context.save();
    context.globalCompositeOperation = 'destination-in';
    context.setTransform(
        matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    context.rect(
        vxList[0], vxList[1], vxList[8] - vxList[0], vxList[9] - vxList[1]);
    context.clip();
    renderState.globalMatrix.prepend(this.matrix);
    renderState.renderTextureQuad(this.bitmapData.renderTextureQuad);
    context.restore();
  }

  //---------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    final renderContext = renderState.renderContext as RenderContextWebGL;
    final renderTexture = renderTextureQuad.renderTexture;

    final renderProgram = renderContext.getRenderProgram(
        r'$AlphaMaskFilterProgram', AlphaMaskFilterProgram.new);

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.renderAlphaMaskFilterQuad(
        renderState, renderTextureQuad, this);
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
  String get vertexShaderSource => '''

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
    ''';

  @override
  String get fragmentShaderSource => '''

    precision mediump float;
    uniform sampler2D uTexSampler;
    uniform sampler2D uMskSampler;

    varying vec2 vTexCoord;
    varying vec2 vMskCoord;
    varying vec4 vMskLimit;
    varying float vAlpha;

    void main() {
      vec4 texColor = texture2D(uTexSampler, vTexCoord.xy);
      vec4 mskColor = texture2D(uMskSampler, vMskCoord.xy);
      vec2 s1 = step(vMskLimit.xy, vMskCoord.xy);
      vec2 s2 = step(vMskCoord.xy, vMskLimit.zw);
      float sAlpha = s1.x * s1.y * s2.x * s2.y;
      gl_FragColor = texColor * (mskColor.a * vAlpha * sAlpha);
    }
    ''';

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {
    super.activate(renderContext);

    renderingContext.uniform1i(uniforms['uTexSampler'], 0);
    renderingContext.uniform1i(uniforms['uMskSampler'], 1);

    renderBufferVertex.bindAttribute(attributes['aVertexPosition'], 2, 44, 0);
    renderBufferVertex.bindAttribute(attributes['aVertexTexCoord'], 2, 44, 8);
    renderBufferVertex.bindAttribute(attributes['aVertexMskCoord'], 2, 44, 16);
    renderBufferVertex.bindAttribute(attributes['aVertexMskLimit'], 4, 44, 24);
    renderBufferVertex.bindAttribute(attributes['aVertexAlpha'], 1, 44, 40);
  }

  //---------------------------------------------------------------------------

  void renderAlphaMaskFilterQuad(RenderState renderState,
      RenderTextureQuad renderTextureQuad, AlphaMaskFilter alphaMaskFilter) {
    final alpha = renderState.globalAlpha;
    final ixList = renderTextureQuad.ixList;
    final vxList = renderTextureQuad.vxList;
    final indexCount = ixList.length;
    final vertexCount = vxList.length >> 2;

    final mskQuad = alphaMaskFilter.bitmapData.renderTextureQuad;
    final texMatrix = renderTextureQuad.samplerMatrix;
    final posMatrix = renderState.globalMatrix;

    // Calculate mask bounds and transformation matrix

    final bounds = mskQuad.vxList;
    final mskBoundsX1 = bounds[2] < bounds[10] ? bounds[2] : bounds[10];
    final mskBoundsX2 = bounds[2] > bounds[10] ? bounds[2] : bounds[10];
    final mskBoundsY1 = bounds[3] < bounds[11] ? bounds[3] : bounds[11];
    final mskBoundsY2 = bounds[3] > bounds[11] ? bounds[3] : bounds[11];

    final mskMatrix = mskQuad.samplerMatrix;
    mskMatrix.invertAndConcat(alphaMaskFilter.matrix);
    mskMatrix.invert();

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + indexCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vertexCount * 11 >= vxData.length) flush();

    final ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    final vxCount = renderBufferVertex.count;

    // copy index list

    for (var i = 0; i < indexCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += indexCount;
    renderBufferIndex.count += indexCount;

    // copy vertex list

    for (var i = 0, o = 0; i < vertexCount; i++, o += 4) {
      final x = vxList[o + 0];
      final y = vxList[o + 1];
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
