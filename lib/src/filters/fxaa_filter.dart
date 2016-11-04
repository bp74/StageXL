library stagexl.filters.fxaa;

import '../display.dart';
import '../engine.dart';
import '../geom.dart';

//==============================================================================
//==============================================================================
// Based on the work of some geniuses:
// http://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/
// https://github.com/mattdesl/glsl-fxaa
// https://github.com/mitsuhiko/webgl-meincraft
//==============================================================================
//==============================================================================

/// A FXAA (fast approximate anti-alias) filter for shapes and other display objects.
///
/// Please be aware that this is a post processing filter, which does not work
/// with transparent textures. The anti-aliasing only works for areas without
/// transparency.

class FxaaFilter extends BitmapFilter {

  @override
  BitmapFilter clone() => new FxaaFilter();

  //----------------------------------------------------------------------------

  @override
  void apply(BitmapData bitmapData, [Rectangle<num> rectangle]) {
    // not supported with BitmapDatas
  }

  //----------------------------------------------------------------------------

  @override
  void renderFilter(RenderState renderState, RenderTextureQuad renderTextureQuad, int pass) {

    RenderContextWebGL renderContext = renderState.renderContext;
    RenderTexture renderTexture = renderTextureQuad.renderTexture;

    FxaaFilterProgram renderProgram = renderContext.getRenderProgram(
        r"$FxaaFilterProgram", () => new FxaaFilterProgram());

    renderContext.activateRenderProgram(renderProgram);
    renderContext.activateRenderTexture(renderTexture);
    renderProgram.configure(renderTexture.width, renderTexture.height);
    renderProgram.renderTextureQuad(renderState, renderTextureQuad);
    renderProgram.flush();
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class FxaaFilterProgram extends RenderProgramSimple {

  // aVertexPosition:   Float32(x), Float32(y)
  // aVertexTextCoord:  Float32(u), Float32(v)
  // aVertexAlpha:      Float32(alpha)

  @override
  String get vertexShaderSource => """

    precision mediump float;

    uniform mat4 uProjectionMatrix;
    uniform vec2 uTexel;

    attribute vec2 aVertexPosition;
    attribute vec2 aVertexTextCoord;
    attribute float aVertexAlpha;

    varying vec2 vTextCoordXY;
    varying vec2 vTextCoordTL;
    varying vec2 vTextCoordTR;
    varying vec2 vTextCoordBL;
    varying vec2 vTextCoordBR;
    varying float vAlpha;

    void main() {
      vTextCoordXY = aVertexTextCoord;
      vTextCoordTL = aVertexTextCoord + vec2(-1.0, -1.0) * uTexel;
      vTextCoordTR = aVertexTextCoord + vec2( 1.0, -1.0) * uTexel;
      vTextCoordBL = aVertexTextCoord + vec2(-1.0,  1.0) * uTexel;
      vTextCoordBR = aVertexTextCoord + vec2( 1.0,  1.0) * uTexel;
      vAlpha = aVertexAlpha;
      gl_Position = vec4(aVertexPosition, 0.0, 1.0) * uProjectionMatrix;
    }
    """;

  @override
  String get fragmentShaderSource => """

    precision mediump float;

    uniform sampler2D uSampler;
    uniform vec2 uTexel;

    varying vec2 vTextCoordXY;
    varying vec2 vTextCoordTL;
    varying vec2 vTextCoordTR;
    varying vec2 vTextCoordBL;
    varying vec2 vTextCoordBR;
    varying float vAlpha;

    const float FXAA_REDUCE_MIN = 1.0 / 128.0;
    const float FXAA_REDUCE_MUL = 1.0 / 8.0;
    const float FXAA_SPAN_MAX = 8.0;

    void main() {

      vec4 color = texture2D(uSampler, vTextCoordXY);
      vec3 rgbTL = texture2D(uSampler, vTextCoordTL).xyz;
      vec3 rgbTR = texture2D(uSampler, vTextCoordTR).xyz;
      vec3 rgbBL = texture2D(uSampler, vTextCoordBL).xyz;
      vec3 rgbBR = texture2D(uSampler, vTextCoordBR).xyz;
      vec3 rgbXY = color.xyz;
      vec3 luma = vec3(0.299, 0.587, 0.114);

      float lumaTL = dot(rgbTL, luma);
      float lumaTR = dot(rgbTR, luma);
      float lumaBL = dot(rgbBL, luma);
      float lumaBR = dot(rgbBR, luma);
      float lumaXY = dot(rgbXY, luma);
      float lumaMin = min(lumaXY, min(min(lumaTL, lumaTR), min(lumaBL, lumaBR)));
      float lumaMax = max(lumaXY, max(max(lumaTL, lumaTR), max(lumaBL, lumaBR)));

      vec2 dir = vec2(lumaBL + lumaBR - lumaTL - lumaTR, lumaTL + lumaBL - lumaTR - lumaBR);
      float dirReduce = max((lumaTL + lumaTR + lumaBL + lumaBR) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
      float dirMin = min(abs(dir.x), abs(dir.y)) + dirReduce;
      dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir / dirMin)) * uTexel;
      vec3 rgbA = 0.50 * (texture2D(uSampler, vTextCoordXY - dir * 0.16666).xyz + texture2D(uSampler, vTextCoordXY + dir * 0.16666).xyz);
      vec3 rgbB = 0.25 * (texture2D(uSampler, vTextCoordXY - dir * 0.50000).xyz + texture2D(uSampler, vTextCoordXY + dir * 0.50000).xyz) + rgbA * 0.5;

      float lumaB = dot(rgbB, luma);
      float conditionLT = max(sign(lumaMin - lumaB), 0.0);     // (lumaB < lumaMin)
      float conditionGT = max(sign(lumaB - lumaMax), 0.0);     // (lumaB > lumaMax)
      float conditionOR = min(conditionLT + conditionGT, 1.0); // OR
      gl_FragColor = vec4((rgbA - rgbB) * conditionOR + rgbB, color.a) * vAlpha;
    }
    """;

  //---------------------------------------------------------------------------

  void configure(num textureWidth, num textureHeight) {
    double texelX = 1.0 / textureWidth;
    double texelY = 1.0 / textureHeight;
    renderingContext.uniform2f(uniforms["uTexel"], texelX, texelY);
  }
}
