part of stagexl.display;

/// The BitmapFilterProgram is a base class for filter render programs.
///
/// Most filter render programs share the same requirements. This
/// abstract base class can be extended and the filter render program
/// only needs to change the fragment shader source code.

abstract class BitmapFilterProgram extends RenderProgram {

  RenderBufferVertex _renderBufferVertex;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)
  //---------------------------------------------------------------------------

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
      vec4 color = texture2D(uSampler, vTextCoord);
      gl_FragColor = color * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uSampler"], 0);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 20, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTextCoord"], 2, 20, 8);
    _renderBufferVertex.bindAttribute(attributes["aVertexAlpha"], 1, 20, 16);
  }

  //---------------------------------------------------------------------------

  void renderQuad(RenderState renderState, RenderTextureQuad renderTextureQuad) {

    Float32List xyList = renderTextureQuad.xyList;
    Float32List uvList = renderTextureQuad.uvList;
    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num ma = matrix.a;
    num mb = matrix.b;
    num mc = matrix.c;
    num md = matrix.d;
    num ox = matrix.tx + xyList[0] * ma + xyList[1] * mc;
    num oy = matrix.ty + xyList[0] * mb + xyList[1] * md;
    num ax = xyList[8] * ma;
    num bx = xyList[8] * mb;
    num cy = xyList[9] * mc;
    num dy = xyList[9] * md;

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < 20) return;

    // vertex 1
    vxData[00] = ox;
    vxData[01] = oy;
    vxData[02] = uvList[0];
    vxData[03] = uvList[1];
    vxData[04] = alpha;

    // vertex 2
    vxData[05] = ox + ax;
    vxData[06] = oy + bx;
    vxData[07] = uvList[2];
    vxData[08] = uvList[3];
    vxData[09] = alpha;

    // vertex 3
    vxData[10] = ox + ax + cy;
    vxData[11] = oy + bx + dy;
    vxData[12] = uvList[4];
    vxData[13] = uvList[5];
    vxData[14] = alpha;

    // vertex 4
    vxData[15] = ox + cy;
    vxData[16] = oy + dy;
    vxData[17] = uvList[6];
    vxData[18] = uvList[7];
    vxData[19] = alpha;

    _renderBufferVertex.update(0, 20);

    this.renderingContext.drawArrays(gl.TRIANGLE_FAN, 0, 4);
  }
}
