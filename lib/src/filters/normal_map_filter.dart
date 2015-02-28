library stagexl.filters.normal_map;

import 'dart:math' as math;
import 'dart:typed_data';

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
    renderProgram.configure(this, renderTextureQuad);
    renderProgram.renderQuad(renderState, renderTextureQuad);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class NormalMapFilterProgram extends BitmapFilterProgram {

  // attenuation calculation
  // http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
  // https://www.desmos.com/calculator/nmnaud1hrw
  // https://www.desmos.com/calculator/kp89d5khyb

  String get fragmentShaderSource => """
      precision mediump float;
      uniform sampler2D uTexSampler;
      uniform sampler2D uMapSampler;
      uniform mat3 uMapMatrix;
      uniform vec4 uAmbientColor;
      uniform vec4 uLightColor;
      uniform vec4 uLightPosition;
      varying vec2 vTextCoord;
      varying float vAlpha;

      void main() {

        // Coordinates and color of texture
        vec3 texCoord = vec3(vTextCoord.xy, 1.0);
        vec4 texColor = texture2D(uTexSampler, vTextCoord.xy);

        // Coordinates and color of normal map
        vec3 mapCoord = texCoord * uMapMatrix;
        vec3 mapColor = texture2D(uMapSampler, mapCoord.xy).rgb;
        vec3 mapVector = vec3(mapColor.r, 1.0 - mapColor.g, mapColor.b);
        vec3 mapNormal = normalize(mapVector * 2.0 - 1.0);

        // Position of light relative to texture coordinates
        vec3 lightDelta = vec3(uLightPosition.xy - texCoord.xy, uLightPosition.z);
        vec3 lightNormal = normalize(lightDelta);
        
        // Calculate diffuse and ambient color
        float diffuse = max(dot(mapNormal, lightNormal), 0.0);
        vec3 diffuseColor = uLightColor.rgb * uLightColor.a * diffuse;
        vec3 ambientColor = uAmbientColor.rgb * uAmbientColor.a;
      
        // Calculate attenuation
        float distance = length(lightDelta.xy);
        float radius = uLightPosition.w;
        float attenuation = clamp(1.0 - (distance * distance) / (radius * radius), 0.0, 1.0); 
        attenuation = attenuation * attenuation;

        // Get the final color
        vec3 color = texColor.rgb * (ambientColor + diffuseColor * attenuation);
        gl_FragColor = vec4(color.rgb, texColor.a) * vAlpha;
        //gl_FragColor = vec4(diffuse, diffuse, diffuse, 1.0);
      }
      """;

  void configure(NormalMapFilter normalMapFilter, RenderTextureQuad renderTextureQuad) {

    var texMatrix = renderTextureQuad.samplerMatrix;

    var lightPosition = new Point<num>(normalMapFilter.lightX, normalMapFilter.lightY);
    texMatrix.transformPoint(lightPosition, lightPosition);

    var mapMatrix = texMatrix.cloneInvert();
    mapMatrix.concat(normalMapFilter.bitmapData.renderTextureQuad.samplerMatrix);

    var uMapMatrix = new Float32List.fromList([
        mapMatrix.a, mapMatrix.c, mapMatrix.tx,
        mapMatrix.b, mapMatrix.d, mapMatrix.ty,
        0.0, 0.0, 1.0]);

    num ambientR = colorGetA(normalMapFilter.ambientColor) / 255.0;
    num ambientG = colorGetR(normalMapFilter.ambientColor) / 255.0;
    num ambientB = colorGetG(normalMapFilter.ambientColor) / 255.0;
    num ambientA = colorGetB(normalMapFilter.ambientColor) / 255.0;

    num lightR = colorGetA(normalMapFilter.lightColor) / 255.0;
    num lightG = colorGetR(normalMapFilter.lightColor) / 255.0;
    num lightB = colorGetG(normalMapFilter.lightColor) / 255.0;
    num lightA = colorGetB(normalMapFilter.lightColor) / 255.0;

    num lightX = lightPosition.x;
    num lightY = lightPosition.y;
    num lightZ =  math.sqrt(texMatrix.det) * normalMapFilter.lightZ;
    var lightRadius = math.sqrt(texMatrix.det) * normalMapFilter.lightRadius;

    var uTexSamplerLocation = uniformLocations["uTexSampler"];
    var uMapSamplerLocation = uniformLocations["uMapSampler"];
    var uMapMatrixLocation = uniformLocations["uMapMatrix"];
    var uAmbientColorLocation = uniformLocations["uAmbientColor"];
    var uLightColorLocation = uniformLocations["uLightColor"];
    var uLightPositionLocation = uniformLocations["uLightPosition"];

    renderingContext.uniform1i(uTexSamplerLocation, 0);
    renderingContext.uniform1i(uMapSamplerLocation, 1);
    renderingContext.uniformMatrix3fv(uMapMatrixLocation, false, uMapMatrix);
    renderingContext.uniform4f(uAmbientColorLocation, ambientR, ambientG, ambientB, ambientA);
    renderingContext.uniform4f(uLightColorLocation, lightR, lightG, lightB, lightA);
    renderingContext.uniform4f(uLightPositionLocation, lightX, lightY, lightZ, lightRadius);
  }
}
