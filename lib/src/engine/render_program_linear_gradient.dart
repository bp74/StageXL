part of stagexl.engine;

class RenderProgramLinearGradient extends RenderProgram {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexAlpha:      Float32(alpha)

  @override
  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;
    attribute vec2 aVertexPosition;
    attribute float aVertexAlpha;
    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      vTextCoord = aVertexPosition;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uSampler;
    uniform vec2 uvGradientStart;
    uniform vec2 uvGradientVector;
    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      vec2 pixelVector = vTextCoord - uvGradientStart;
      float t = dot(pixelVector,uvGradientVector)/dot(uvGradientVector,uvGradientVector);
      gl_FragColor = texture2D(uSampler, vec2(0.5,t)) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);

    renderingContext.uniform1i(uniforms["uSampler"], 0);

    renderBufferVertex.bindAttribute(attributes["aVertexPosition"], 2, 12, 0);
    renderBufferVertex.bindAttribute(attributes["aVertexAlpha"], 1, 12, 8);
  }

  //---------------------------------------------------------------------------

  void renderMesh(
      RenderState renderState,
      Int16List ixList, Float32List vxList, GraphicsGradient gradient) {

    var alpha = renderState.globalAlpha;
    var matrix = renderState.globalMatrix;
    var ixListCount = ixList.length;
    var vxListCount = vxList.length >> 1;

    // check buffer sizes and flush if necessary

    var ixData = renderBufferIndex.data;
    var ixPosition = renderBufferIndex.position;
    if (ixPosition + ixListCount >= ixData.length) flush();

    var vxData = renderBufferVertex.data;
    var vxPosition = renderBufferVertex.position;
    if (vxPosition + vxListCount * 5 >= vxData.length) flush();

    // set uniform shader data
    var ma = matrix.a;
    var mb = matrix.b;
    var mc = matrix.c;
    var md = matrix.d;
    var mx = matrix.tx;
    var my = matrix.ty;
    var gradientStartX = mx + ma * gradient.startX + mc * gradient.startY;
    var gradientStartY = my + mb * gradient.startX + md * gradient.startY;
    var gradientVectorX = (mx + ma * gradient.endX + mc * gradient.endY) - gradientStartX;
    var gradientVectorY = (my + mb * gradient.endX + md * gradient.endY) - gradientStartY;
    if (gradientVectorX==0 && gradientVectorY==0) gradientVectorY = 1;// protect against zero length vector (linear gradient not defined for this case)
    renderingContext.uniform2f(uniforms["uvGradientStart"], gradientStartX, gradientStartY);
    renderingContext.uniform2f(uniforms["uvGradientVector"], gradientVectorX, gradientVectorY);

    // copy index list

    var ixIndex = renderBufferIndex.position;
    var vxIndex = renderBufferVertex.position;
    var vxCount = renderBufferVertex.count;

    for (var i = 0; i < ixListCount; i++) {
      ixData[ixIndex + i] = vxCount + ixList[i];
    }

    renderBufferIndex.position += ixListCount;
    renderBufferIndex.count += ixListCount;

    // copy vertex list

    for (var i = 0, o = 0; i < vxListCount; i++, o += 2) {
      num x = vxList[o + 0];
      num y = vxList[o + 1];
      vxData[vxIndex + 0] = mx + ma * x + mc * y;
      vxData[vxIndex + 1] = my + mb * x + md * y;
      vxData[vxIndex + 2] = alpha;
      vxIndex += 3;
    }

    renderBufferVertex.position += vxListCount * 3;
    renderBufferVertex.count += vxListCount;
  }

}
