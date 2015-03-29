part of stagexl.engine;

class RenderProgramTriangle extends RenderProgram {

  RenderBufferVertex _renderBufferVertex = null;
  int _triangleCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(r), Float32(g), Float32(b), Float32(a)
  //---------------------------------------------------------------------------

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute vec4 aVertexColor;
    varying vec4 vColor;

    void main() {
      vColor = aVertexColor;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    varying vec4 vColor;

    void main() {
      gl_FragColor = vColor; 
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 24, 0);
    _renderBufferVertex.bindAttribute(attributes["aVertexColor"], 4, 24, 8);
  }

  @override
  void flush() {
    if (_triangleCount > 0) {
      _renderBufferVertex.update(0, _triangleCount * 18);
      _renderingContext.drawArrays(gl.TRIANGLES, 0, _triangleCount * 3);
      _triangleCount = 0;
    }
  }

  //---------------------------------------------------------------------------

  void renderTriangle(RenderState renderState,
                      num x1, num y1, num x2, num y2, num x3, num y3, int color) {

    Matrix matrix = renderState.globalMatrix;
    num alpha = renderState.globalAlpha;

    num colorA = colorGetA(color) / 255.0 * alpha;
    num colorR = colorGetR(color) / 255.0;
    num colorG = colorGetG(color) / 255.0;
    num colorB = colorGetB(color) / 255.0;

    num a = matrix.a;
    num b = matrix.b;
    num c = matrix.c;
    num d = matrix.d;
    num tx = matrix.tx;
    num ty = matrix.ty;

    // The following code contains dart2js_hints to keep
    // the generated JavaScript code clean and fast!

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _triangleCount * 18 + 18) flush();

    var index = _triangleCount * 18;
    if (index > vxData.length - 18) return;

    // vertex 1
    vxData[index + 00] = x1 * a + y1 * c + tx;
    vxData[index + 01] = x1 * b + y1 * d + ty;
    vxData[index + 02] = colorR;
    vxData[index + 03] = colorG;
    vxData[index + 04] = colorB;
    vxData[index + 05] = colorA;

    // vertex 2
    vxData[index + 06] = x2 * a + y2 * c + tx;
    vxData[index + 07] = x2 * b + y2 * d + ty;
    vxData[index + 08] = colorR;
    vxData[index + 09] = colorG;
    vxData[index + 10] = colorB;
    vxData[index + 11] = colorA;

    // vertex 3
    vxData[index + 12] = x3 * a + y3 * c + tx;
    vxData[index + 13] = x3 * b + y3 * d + ty;
    vxData[index + 14] = colorR;
    vxData[index + 15] = colorG;
    vxData[index + 16] = colorB;
    vxData[index + 17] = colorA;

    _triangleCount += 1;
  }

}
