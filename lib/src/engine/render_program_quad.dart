part of stagexl.engine;

class RenderProgramQuad extends RenderProgram {

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //---------------------------------------------------------------------------

  int _quadCount = 0;

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;
    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      vTextCoord = aVertexTextCoord;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;

    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      gl_FragColor = texture2D(uSampler, vTextCoord) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 20, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 20, 8);
    _renderBufferVertex.bindAttribute(attributes["aVertexAlpha"], 1, 20, 16);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      _renderBufferVertex.update(0, _quadCount * 20);
      _renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    Float32List uvList = renderTextureQuad.uvList;

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
    if (vxData.length < _quadCount * 20 + 20) flush();

    var index = _quadCount * 20;
    if (index > vxData.length - 20) return;

    // vertex 1
    vxData[index + 00] = ox;
    vxData[index + 01] = oy;
    vxData[index + 02] = uvList[0];
    vxData[index + 03] = uvList[1];
    vxData[index + 04] = alpha;

    // vertex 2
    vxData[index + 05] = ox + ax;
    vxData[index + 06] = oy + bx;
    vxData[index + 07] = uvList[2];
    vxData[index + 08] = uvList[3];
    vxData[index + 09] = alpha;

    // vertex 3
    vxData[index + 10] = ox + ax + cy;
    vxData[index + 11] = oy + bx + dy;
    vxData[index + 12] = uvList[4];
    vxData[index + 13] = uvList[5];
    vxData[index + 14] = alpha;

    // vertex 4
    vxData[index + 15] = ox + cy;
    vxData[index + 16] = oy + dy;
    vxData[index + 17] = uvList[6];
    vxData[index + 18] = uvList[7];
    vxData[index + 19] = alpha;

    _quadCount += 1;
  }

}