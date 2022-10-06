library stagexl.filters.normal_map;

import 'dart:math' as math;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';
import '../internal/tools.dart';
import '../ui/color.dart';

class NormalMapFilter extends BitmapFilter {
  final BitmapData bitmapData;

  int ambientColor = Color.White;
  int lightColor = Color.White;

  num lightX = 0.0;
  num lightY = 0.0;
  num lightZ = 50.0;
  num lightRadius = 100;

  NormalMapFilter(this.bitmapData);

  @override
  BitmapFilter clone() => NormalMapFilter(bitmapData);

  //-----------------------------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num>? rectangle]) {}

  //-----------------------------------------------------------------------------------------------

  @override
  void renderFilter(
      RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {
    final renderContext = renderState.renderContext as RenderContextWebGL;
    final renderTexture = renderTextureQuad.renderTexture;

    final renderProgram = renderContext.getRenderProgram(
        r'$NormalMapFilterProgram', NormalMapFilterProgram.new);

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTextureAt(renderTexture, 0);
    renderContext.activateRenderTextureAt(bitmapData.renderTexture, 1);
    renderProgram.renderNormalMapQuad(renderState, renderTextureQuad, this);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class NormalMapFilterProgram extends RenderProgram {
  // aVertexPosition:      Float32(x), Float32(y)
  // aVertexTexCoord:      Float32(u), Float32(v)
  // aVertexMapCoord:      Float32(v), Float32(v)
  // aVertexAmbientColor:  Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightColor:    Float32(r), Float32(g), Float32(b), Float32(a)
  // aVertexLightCoord:    Float32(x), Float32(y), Float32(z), Float32(r)
  // aVertexAlpha:         Float32(a)

  @override
  String get vertexShaderSource => '''

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
    ''';

  @override
  String get fragmentShaderSource => '''

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
    ''';

  //-----------------------------------------------------------------------------------------------

  @override
  void activate(RenderContextWebGL renderContext) {
    super.activate(renderContext);

    renderingContext.uniform1i(uniforms['uTexSampler'], 0);
    renderingContext.uniform1i(uniforms['uMapSampler'], 1);

    renderBufferVertex.bindAttribute(attributes['aVertexPosition'], 2, 76, 0);
    renderBufferVertex.bindAttribute(attributes['aVertexTexCoord'], 2, 76, 8);
    renderBufferVertex.bindAttribute(attributes['aVertexMapCoord'], 2, 76, 16);
    renderBufferVertex.bindAttribute(
        attributes['aVertexAmbientColor'], 4, 76, 24);
    renderBufferVertex.bindAttribute(
        attributes['aVertexLightColor'], 4, 76, 40);
    renderBufferVertex.bindAttribute(
        attributes['aVertexLightCoord'], 4, 76, 56);
    renderBufferVertex.bindAttribute(attributes['aVertexAlpha'], 1, 76, 72);
  }

  //-----------------------------------------------------------------------------------------------

  void renderNormalMapQuad(RenderState renderState,
      RenderTextureQuad renderTextureQuad, NormalMapFilter normalMapFilter) {
    final alpha = renderState.globalAlpha;
    final mapMatrix =
        normalMapFilter.bitmapData.renderTextureQuad.samplerMatrix;
    final texMatrix = renderTextureQuad.samplerMatrix;
    final posMatrix = renderState.globalMatrix;
    final ixList = renderTextureQuad.ixList;
    final vxList = renderTextureQuad.vxList;
    final indexCount = ixList.length;
    final vertexCount = vxList.length >> 2;

    // Ambient color, light color, light position

    final ambientColor = normalMapFilter.ambientColor;
    final ambientR = colorGetA(ambientColor) / 255.0;
    final ambientG = colorGetR(ambientColor) / 255.0;
    final ambientB = colorGetG(ambientColor) / 255.0;
    final ambientA = colorGetB(ambientColor) / 255.0;

    final lightColor = normalMapFilter.lightColor;
    final lightR = colorGetA(lightColor) / 255.0;
    final lightG = colorGetR(lightColor) / 255.0;
    final lightB = colorGetG(lightColor) / 255.0;
    final lightA = colorGetB(lightColor) / 255.0;

    final lx = normalMapFilter.lightX;
    final ly = normalMapFilter.lightY;
    final lightX = texMatrix.tx + lx * texMatrix.a + ly * texMatrix.c;
    final lightY = texMatrix.ty + lx * texMatrix.b + ly * texMatrix.d;
    final lightZ = math.sqrt(texMatrix.det) * normalMapFilter.lightZ;
    final lightRadius = math.sqrt(texMatrix.det) * normalMapFilter.lightRadius;

    // check buffer sizes and flush if necessary

    final ixData = renderBufferIndex.data;
    final ixPosition = renderBufferIndex.position;
    if (ixPosition + indexCount >= ixData.length) flush();

    final vxData = renderBufferVertex.data;
    final vxPosition = renderBufferVertex.position;
    if (vxPosition + vertexCount * 19 >= vxData.length) flush();

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
      final num x = vxList[o + 0];
      final num y = vxList[o + 1];
      vxData[vxIndex + 00] = posMatrix.tx + x * posMatrix.a + y * posMatrix.c;
      vxData[vxIndex + 01] = posMatrix.ty + x * posMatrix.b + y * posMatrix.d;
      vxData[vxIndex + 02] = texMatrix.tx + x * texMatrix.a + y * texMatrix.c;
      vxData[vxIndex + 03] = texMatrix.ty + x * texMatrix.b + y * texMatrix.d;
      vxData[vxIndex + 04] = mapMatrix.tx + x * mapMatrix.a + y * mapMatrix.c;
      vxData[vxIndex + 05] = mapMatrix.ty + x * mapMatrix.b + y * mapMatrix.d;
      vxData[vxIndex + 06] = ambientR;
      vxData[vxIndex + 07] = ambientG;
      vxData[vxIndex + 08] = ambientB;
      vxData[vxIndex + 09] = ambientA;
      vxData[vxIndex + 10] = lightR;
      vxData[vxIndex + 11] = lightG;
      vxData[vxIndex + 12] = lightB;
      vxData[vxIndex + 13] = lightA;
      vxData[vxIndex + 14] = lightX;
      vxData[vxIndex + 15] = lightY;
      vxData[vxIndex + 16] = lightZ;
      vxData[vxIndex + 17] = lightRadius;
      vxData[vxIndex + 18] = alpha;
      vxIndex += 19;
    }

    renderBufferVertex.position += vertexCount * 19;
    renderBufferVertex.count += vertexCount;
  }
}
