part of stagexl.engine;


class RenderProgramRadialGradient extends RenderProgram {

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

    uniform vec2 uvA;
    uniform vec3 uvB;
    uniform vec3 uvC;

    varying vec2 vTextCoord;
    varying float vAlpha;

    void main() {
      float a = uvA.x;
      float b = dot(uvB,vec3(vTextCoord,1));
      float c = dot(vTextCoord,vTextCoord) + dot(uvC,vec3(vTextCoord,1));
      float sign = uvA.y;

      float t = (-b + sign*sqrt(b*b-4.0*a*c))/(2.0*a);
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
    var scaleR = math.sqrt(ma*ma + mc*mc);// we are simplifying here, assuming uniform scale
    var gradientStartX = mx + ma * gradient.startX + mc * gradient.startY;
    var gradientStartY = my + mb * gradient.startX + md * gradient.startY;
    var gradientVectorX = (mx + ma * gradient.endX + mc * gradient.endY) - gradientStartX;
    var gradientVectorY = (my + mb * gradient.endX + md * gradient.endY) - gradientStartY;
    var gradientStartRadius = gradient.startRadius*scaleR;
    var gradientRadiusOffset = (gradient.endRadius - gradient.startRadius)*scaleR;
    if (gradientVectorX==0 && gradientVectorY==0 && gradientRadiusOffset==0) gradientRadiusOffset = 1;// protect against equal start-end circles (radial gradient not defined for this case)
    var a = gradientVectorX*gradientVectorX + gradientVectorY*gradientVectorY - gradientRadiusOffset*gradientRadiusOffset;
    var b0 = -2*gradientVectorX;
    var b1 = -2*gradientVectorY;
    var b2 = 2*gradientStartX*gradientVectorX + 2*gradientStartY*gradientVectorY - 2*gradientStartRadius*gradientRadiusOffset;
    var c0 = -2*gradientStartX;
    var c1 = -2*gradientStartY;
    var c2 = gradientStartX*gradientStartX + gradientStartY*gradientStartY - gradientStartRadius*gradientStartRadius;
    var sign = gradientRadiusOffset >= 0 ? -1 : 1;
    renderingContext.uniform2f(uniforms["uvA"], a, sign);
    renderingContext.uniform3f(uniforms["uvB"], b0, b1, b2);
    renderingContext.uniform3f(uniforms["uvC"], c0, c1, c2);

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
