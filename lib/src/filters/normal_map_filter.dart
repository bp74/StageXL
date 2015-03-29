library stagexl.filters.normal_map;

import 'dart:math' as math;
import 'dart:web_gl' as gl;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../ui/color.dart';
import '../internal/tools.dart';

class NormalMapFilter extends BitmapFilter {

  final BitmapData bitmapData;

  int ambientColor = Color.White;
  int lightColor = Color.White;

  num lightX = 0.0;
  num lightY = 0.0;
  num lightZ = 50.0;
  num lightRadius = 100;

  NormalMapFilter(this.bitmapData);

  BitmapFilter clone() => new NormalMapFilter(bitmapData);

  //-----------------------------------------------------------------------------------------------

  void apply(BitmapData bitmapData, [Rectangle<int> rectangle]) {
    // TODO: implement NormalMapFilter for BitmapDatas.
  }

  //-----------------------------------------------------------------------------------------------

  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    NormalMapFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$NormalMapFilterProgram", () => new NormalMapFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.renderNormalMapQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class NormalMapFilterProgram extends RenderProgram {

  RenderBufferIndex _renderBufferIndex;
  RenderBufferVertex _renderBufferVertex;
  int _quadCount = 0;

  //---------------------------------------------------------------------------
  // aVertexPosition:      Float32(x), Float32(y)
  // aVertexTexCoord:      Float32(u), Float32(v)
  // aVertexMapCoord:      Float32(v), Float32(v)
  // aVertexAmbientColor:  Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightColor:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightCoord:    Float32(x), Float32(y), Float32(z), Float32(r)
  // aVertexAlpha:         Float32(a)
  //---------------------------------------------------------------------------

  String get vertexShaderSource => """

    uniform mat4 uProjectionMatrix;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTexCoord;
    attribute vec2 aVertexMapCoord;
    attribute vec4 aVertexAmbientColor;
    attribute vec4 aVertexLightColor;
    attribute vec4 aVertexLightCoord;
    attribute float aVertexAlpha;

    varying vec2 vTexCoord;
    varying vec2 vMapCoord;
    varying vec4 vAmbientColor;
    varying vec4 vLightColor;
    varying vec4 vLightCoord;
    varying float vAlpha;

    void main() {
      vTexCoord = aVertexTexCoord;
      vMapCoord = aVertexMapCoord;
      vAmbientColor = aVertexAmbientColor;
      vLightColor = aVertexLightColor;
      vLightCoord = aVertexLightCoord;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  String get fragmentShaderSource => """

    precision mediump float;
    uniform sampler2D uTexSampler;
    uniform sampler2D uMapSampler;

    varying vec2 vTexCoord;
    varying vec2 vMapCoord;
    varying vec4 vAmbientColor;
    varying vec4 vLightColor;
    varying vec4 vLightCoord;
    varying float vAlpha;

    void main() {

      // Texture color and map color/vector/normal 
      vec4 texColor = texture2D(uTexSampler, vTexCoord.xy);
      vec4 mapColor = texture2D(uMapSampler, vMapCoord.xy);
      vec3 mapVector = vec3(mapColor.r, 1.0 - mapColor.g, mapColor.b);
      vec3 mapNormal = normalize(mapVector * 2.0 - 1.0);

      // Position of light relative to texture coordinates
      vec3 lightDelta = vec3(vLightCoord.xy - vTexCoord.xy, vLightCoord.z);
      vec3 lightNormal = normalize(lightDelta);
      
      // Calculate diffuse and ambient color
      float diffuse = max(dot(mapNormal, lightNormal), 0.0);
      vec3 diffuseColor = vLightColor.rgb * vLightColor.a * diffuse;
      vec3 ambientColor = vAmbientColor.rgb * vAmbientColor.a;
    
      // Calculate attenuation
      float distance = length(lightDelta.xy);
      float radius = vLightCoord.w;
      float temp = clamp(1.0 - (distance * distance) / (radius * radius), 0.0, 1.0); 
      float attenuation = temp * temp;

      // Get the final color
      vec3 color = texColor.rgb * (ambientColor + diffuseColor * attenuation);
      gl_FragColor = vec4(color.rgb, texColor.a) * vAlpha;
    }
    """;


  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {

    super.activate(renderContext);
    super.renderingContext.uniform1i(uniforms["uTexSampler"], 0);
    super.renderingContext.uniform1i(uniforms["uMapSampler"], 1);

    _renderBufferIndex = renderContext.renderBufferIndexQuads;
    _renderBufferIndex.activate(renderContext);

    _renderBufferVertex = renderContext.renderBufferVertex;
    _renderBufferVertex.activate(renderContext);
    _renderBufferVertex.bindAttribute(attributes["aVertexPosition"],     2, 76,  0);
    _renderBufferVertex.bindAttribute(attributes["aVertexTexCoord"],     2, 76,  8);
    _renderBufferVertex.bindAttribute(attributes["aVertexMapCoord"],     2, 76, 16);
    _renderBufferVertex.bindAttribute(attributes["aVertexAmbientColor"], 4, 76, 24);
    _renderBufferVertex.bindAttribute(attributes["aVertexLightColor"],   4, 76, 40);
    _renderBufferVertex.bindAttribute(attributes["aVertexLightCoord"],   4, 76, 56);
    _renderBufferVertex.bindAttribute(attributes["aVertexAlpha"],        1, 76, 72);
  }

  @override
  void flush() {
    if (_quadCount > 0) {
      _renderBufferVertex.update(0, _quadCount * 4 * 19);
      renderingContext.drawElements(gl.TRIANGLES, _quadCount * 6, gl.UNSIGNED_SHORT, 0);
      _quadCount = 0;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void renderNormalMapQuad(RenderState renderState,
                           RenderTextureQuad renderTextureQuad,
                           NormalMapFilter normalMapFilter) {

    Matrix mapMatrix = normalMapFilter.bitmapData.renderTextureQuad.samplerMatrix;
    Matrix texMatrix = renderTextureQuad.samplerMatrix;
    Matrix posMatrix = renderState.globalMatrix;

    int width = renderTextureQuad.textureWidth;
    int height = renderTextureQuad.textureHeight;
    int offsetX = renderTextureQuad.offsetX;
    int offsetY = renderTextureQuad.offsetY;
    num alpha = renderState.globalAlpha;

    // Ambient color, light color, light position

    num ambientColor = normalMapFilter.ambientColor;
    num ambientR = colorGetA(ambientColor) / 255.0;
    num ambientG = colorGetR(ambientColor) / 255.0;
    num ambientB = colorGetG(ambientColor) / 255.0;
    num ambientA = colorGetB(ambientColor) / 255.0;

    num lightColor = normalMapFilter.lightColor;
    num lightR = colorGetA(lightColor) / 255.0;
    num lightG = colorGetR(lightColor) / 255.0;
    num lightB = colorGetG(lightColor) / 255.0;
    num lightA = colorGetB(lightColor) / 255.0;

    num lx = normalMapFilter.lightX;
    num ly = normalMapFilter.lightY;
    num lightX = texMatrix.tx + lx * texMatrix.a + ly * texMatrix.c;
    num lightY = texMatrix.ty + lx * texMatrix.b + ly * texMatrix.d;
    num lightZ =  math.sqrt(texMatrix.det) * normalMapFilter.lightZ;
    num lightRadius = math.sqrt(texMatrix.det) * normalMapFilter.lightRadius;

    // Check if the index and vertex buffer are valid and if
    // we need to flush the render program to free the buffers.

    var ixData = _renderBufferIndex.data;
    if (ixData == null) return;
    if (ixData.length < _quadCount * 6 + 6) flush();

    var vxData = _renderBufferVertex.data;
    if (vxData == null) return;
    if (vxData.length < _quadCount * 76 + 76) flush();

    // Calculate the 4 vertices of the RenderTextureQuad

    for(int vertex = 0, index = _quadCount * 76; vertex < 4; vertex++, index += 19) {

      num x = offsetX + (vertex == 1 || vertex == 2 ? width  : 0);
      num y = offsetY + (vertex == 2 || vertex == 3 ? height : 0);

      if (index > vxData.length - 19) return; // dart2js_hint

      vxData[index + 00] = posMatrix.tx + x * posMatrix.a + y * posMatrix.c;
      vxData[index + 01] = posMatrix.ty + x * posMatrix.b + y * posMatrix.d;
      vxData[index + 02] = texMatrix.tx + x * texMatrix.a + y * texMatrix.c;
      vxData[index + 03] = texMatrix.ty + x * texMatrix.b + y * texMatrix.d;
      vxData[index + 04] = mapMatrix.tx + x * mapMatrix.a + y * mapMatrix.c;
      vxData[index + 05] = mapMatrix.ty + x * mapMatrix.b + y * mapMatrix.d;
      vxData[index + 06] = ambientR;
      vxData[index + 07] = ambientG;
      vxData[index + 08] = ambientB;
      vxData[index + 09] = ambientA;
      vxData[index + 10] = lightR;
      vxData[index + 11] = lightG;
      vxData[index + 12] = lightB;
      vxData[index + 13] = lightA;
      vxData[index + 14] = lightX;
      vxData[index + 15] = lightY;
      vxData[index + 16] = lightZ;
      vxData[index + 17] = lightRadius;
      vxData[index + 18] = alpha;
    }

    _quadCount += 1;
  }
}
