library render_texture_quad_test;

import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

//-----------------------------------------------------------------------------

Matcher equalsFloats(List<num> values) {
  values = values.map((v) => v.toDouble()).toList();
  return equals(new Float32List.fromList(values));
}

void main() {

  var rt = new RenderTexture(50, 100, 0xFFFF00FF);

  test('CreateRenderTextureQuadRotaion0', () {
    var src = new Rectangle<int>(5, 10, 30, 70);
    var ofs = new Rectangle<int>(0, 0, 35, 85);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    expect(rtq.abList, equals([5, 10, 35, 10, 35, 80, 5, 80, 30, 70]));
    expect(rtq.xyList, equalsFloats([0, 0, 30, 0, 30, 70, 0, 70, 30, 70]));
    expect(rtq.uvList, equalsFloats([5/50, 10/100, 35/50, 10/100, 35/50, 80/100, 5/50, 80/100, 30/50, 70/100]));
  });

  test('CreateRenderTextureQuadRotation1', () {
    var src = new Rectangle<int>(5, 10, 30, 70);
    var ofs = new Rectangle<int>(0, 0, 85, 35);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    expect(rtq.abList, equals([35, 10, 35, 80, 5, 80, 5, 10, 30, 70]));
    expect(rtq.xyList, equalsFloats([0, 0, 70, 0, 70, 30, 0, 30, 70, 30]));
    expect(rtq.uvList, equalsFloats([35/50, 10/100, 35/50, 80/100, 5/50, 80/100, 5/50, 10/100, 30/50, 70/100]));
  });

  test('CreateRenderTextureQuadRotation2', () {
    var src = new Rectangle<int>(5, 10, 30, 70);
    var ofs = new Rectangle<int>(0, 0, 35, 85);
    var rtq = new RenderTextureQuad(rt, src, ofs, 2, 1.0);
    expect(rtq.abList, equals([35, 80, 5, 80, 5, 10, 35, 10, 30, 70]));
    expect(rtq.xyList, equalsFloats([0, 0, 30, 0, 30, 70, 0, 70, 30, 70]));
    expect(rtq.uvList, equalsFloats([35/50, 80/100, 5/50, 80/100, 5/50, 10/100, 35/50, 10/100, 30/50, 70/100]));
  });

  test('CreateRenderTextureQuadRotation3', () {
    var src = new Rectangle<int>(5, 10, 30, 70);
    var ofs = new Rectangle<int>(0, 0, 35, 85);
    var rtq = new RenderTextureQuad(rt, src, ofs, 3, 1.0);
    expect(rtq.abList, equals([5, 80, 5, 10, 35, 10, 35, 80, 30, 70]));
    expect(rtq.xyList, equalsFloats([0, 0, 70, 0, 70, 30, 0, 30, 70, 30]));
    expect(rtq.uvList, equalsFloats([5/50, 80/100, 5/50, 10/100, 35/50, 10/100, 35/50, 80/100, 30/50, 70/100]));
  });

  //---------------------------------------------------------------------------

  test('SimpleClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([10, 20, 43, 20, 43, 47, 10, 47, 33, 27]));
    expect(quad.xyList, equals([10, 20, 43, 20, 43, 47, 10, 47, 33, 27]));
  });

  test('SimpleClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([30, 10, 30, 43, 3, 43, 3, 10, 27, 33]));
    expect(quad.xyList, equals([10, 20, 43, 20, 43, 47, 10, 47, 33, 27]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([20, 10, 50, 10, 50, 37, 20, 37, 30, 27]));
    expect(quad.xyList, equals([20, 10, 50, 10, 50, 37, 20, 37, 30, 27]));
  });

  test('RightOverlapClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([40, 20, 40, 100, 13, 100, 13, 20, 27, 80]));
    expect(quad.xyList, equals([20, 10, 100, 10, 100, 37, 20, 37, 80, 27]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(-20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 10, 33, 10, 33, 37, 0, 37, 33, 27]));
    expect(quad.xyList, equals([0, 10, 33, 10, 33, 37, 0, 37, 33, 27]));
  });

  test('LeftOverlapClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(-20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([40, 0, 40, 73, 13, 73, 13, 0, 27, 73]));
    expect(quad.xyList, equals([0, 10, 73, 10, 73, 37, 0, 37, 73, 27]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([10, 0, 27, 0, 27, 49, 10, 49, 17, 49]));
    expect(quad.xyList, equals([10, 0, 27, 0, 27, 49, 10, 49, 17, 49]));
  });

  test('TopOverlapClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 10, 50, 27, 1, 27, 1, 10, 49, 17]));
    expect(quad.xyList, equals([10, 0, 27, 0, 27, 49, 10, 49, 17, 49]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, 53, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([10, 53, 27, 53, 27, 100, 10, 100, 17, 47]));
    expect(quad.xyList, equals([10, 53, 27, 53, 27, 100, 10, 100, 17, 47]));
  });

  test('BottomOverlapClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, 13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([37, 10, 37, 27, 0, 27, 0, 10, 37, 17]));
    expect(quad.xyList, equals([10, 13, 27, 13, 27, 50, 10, 50, 17, 37]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = new Rectangle(5, 7, 43, 67);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(quad1.abList, equals([5, 7, 48, 7, 48, 74, 5, 74, 43, 67]));
    expect(quad1.xyList, equals([5, 7, 48, 7, 48, 74, 5, 74, 43, 67]));
    expect(quad2.abList, equals([5, 9, 48, 9, 48, 46, 5, 46, 43, 37]));
    expect(quad2.xyList, equals([5, 9, 48, 9, 48, 46, 5, 46, 43, 37]));
  });

  test('ComplicatedClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = new Rectangle(5, 7, 85, 30);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(quad1.abList, equals([43, 5, 43, 90, 13, 90, 13, 5, 30, 85]));
    expect(quad1.xyList, equals([5, 7, 90, 7, 90, 37, 5, 37, 85, 30]));
    expect(quad2.abList, equals([41, 5, 41, 55, 13, 55, 13, 5, 28, 50]));
    expect(quad2.xyList, equals([5, 9, 55, 9, 55, 37, 5, 37, 50, 28]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('OutsideLeftRightClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 20, 50, 20, 50, 47, 0, 47, 50, 27]));
    expect(quad.xyList, equals([0, 20, 50, 20, 50, 47, 0, 47, 50, 27]));
  });

  test('OutsideLeftRightClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([30, 0, 30, 100, 3, 100, 3, 0, 27, 100]));
    expect(quad.xyList, equals([0, 20, 100, 20, 100, 47, 0, 47, 100, 27]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopBottomClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([20, 0, 43, 0, 43, 100, 20, 100, 23, 100]));
    expect(quad.xyList, equals([20, 0, 43, 0, 43, 100, 20, 100, 23, 100]));
  });

  test('OutsideTopBottomClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 20, 50, 43, 0, 43, 0, 20, 50, 23]));
    expect(quad.xyList, equals([20, 0, 43, 0, 43, 50, 20, 50, 23, 50]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopLeftClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
    expect(quad.xyList, equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
  });

  test('OutsideTopLeftClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 0, 50, 0, 50, 0, 50, 0, 0, 0]));
    expect(quad.xyList, equals([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
  });

  //---------------------------------------------------------------------------

  test('OutsideBottomRightClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(60, 110, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 100, 50, 100, 50, 100, 50, 100, 0, 0]));
    expect(quad.xyList, equals([50, 100, 50, 100, 50, 100, 50, 100, 0, 0]));
  });

  test('OutsideBottomRightClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(110, 60, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 100, 0, 100, 0, 100, 0, 100, 0, 0]));
    expect(quad.xyList, equals([100, 50, 100, 50, 100, 50, 100, 50, 0, 0]));
  });

  //---------------------------------------------------------------------------

  test('OutsideLeftClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 20, 0, 20, 0, 47, 0, 47, 0, 27]));
    expect(quad.xyList, equals([0, 20, 0, 20, 0, 47, 0, 47, 0, 27]));
  });

  test('OutsideLeftClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([30, 0, 30, 0, 3, 0, 3, 0, 27, 0]));
    expect(quad.xyList, equals([0, 20, 0, 20, 0, 47, 0, 47, 0, 27]));
  });

  //---------------------------------------------------------------------------

  test('OutsideRightClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(60, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 20, 50, 20, 50, 47, 50, 47, 0, 27]));
    expect(quad.xyList, equals([50, 20, 50, 20, 50, 47, 50, 47, 0, 27]));
  });

  test('OutsideRightClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(110, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([30, 100, 30, 100, 3, 100, 3, 100, 27, 0]));
    expect(quad.xyList, equals([100, 20, 100, 20, 100, 47, 100, 47, 0, 27]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([10, 0, 37, 0, 37, 0, 10, 0, 27, 0]));
    expect(quad.xyList, equals([10, 0, 37, 0, 37, 0, 10, 0, 27, 0]));
  });

  test('OutsideTopClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([50, 10, 50, 37, 50, 37, 50, 10, 0, 27]));
    expect(quad.xyList, equals([10, 0, 37, 0, 37, 0, 10, 0, 27, 0]));
  });

  //---------------------------------------------------------------------------

  test('OutsideBottomClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([10, 100, 37, 100, 37, 100, 10, 100, 27, 0]));
    expect(quad.xyList, equals([10, 100, 37, 100, 37, 100, 10, 100, 27, 0]));
  });

  test('OutsideBottomClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.abList, equals([0, 10, 0, 37, 0, 37, 0, 10, 0, 27]));
    expect(quad.xyList, equals([10, 50, 37, 50, 37, 50, 10, 50, 27, 0]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('SimpleCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([10, 20, 43, 20, 43, 47, 10, 47, 33, 27]));
    expect(quad.xyList, equals([0, 0, 33, 0, 33, 27, 0, 27, 33, 27]));
  });

  test('SimpleCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([30, 10, 30, 43, 3, 43, 3, 10, 27, 33]));
    expect(quad.xyList, equals([0, 0, 33, 0, 33, 27, 0, 27, 33, 27]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([20, 10, 50, 10, 50, 37, 20, 37, 30, 27]));
    expect(quad.xyList, equals([0, 0, 30, 0, 30, 27, 0, 27, 30, 27]));
  });

  test('RightOverlapCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([40, 20, 40, 100, 13, 100, 13, 20, 27, 80]));
    expect(quad.xyList, equals([0, 0, 80, 0, 80, 27, 0, 27, 80, 27]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(-20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([0, 10, 33, 10, 33, 37, 0, 37, 33, 27]));
    expect(quad.xyList, equals([20, 0, 53, 0, 53, 27, 20, 27, 33, 27]));
  });

  test('LeftOverlapCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(-20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([40, 0, 40, 73, 13, 73, 13, 0, 27, 73]));
    expect(quad.xyList, equals([20, 0, 93, 0, 93, 27, 20, 27, 73, 27]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([10, 0, 27, 0, 27, 49, 10, 49, 17, 49]));
    expect(quad.xyList, equals([0, 13, 17, 13, 17, 62, 0, 62, 17, 49]));
  });

  test('TopOverlapCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([50, 10, 50, 27, 1, 27, 1, 10, 49, 17]));
    expect(quad.xyList, equals([0, 13, 17, 13, 17, 62, 0, 62, 17, 49]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = new Rectangle(10, 53, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([10, 53, 27, 53, 27, 100, 10, 100, 17, 47]));
    expect(quad.xyList, equals([0, 0, 17, 0, 17, 47, 0, 47, 17, 47]));
  });

  test('BottomOverlapCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = new Rectangle(10, 13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.abList, equals([37, 10, 37, 27, 0, 27, 0, 10, 37, 17]));
    expect(quad.xyList, equals([0, 0, 17, 0, 17, 37, 0, 37, 17, 37]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedCut', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = new Rectangle(5, 7, 43, 67);
    var quad1 = rtq.cut(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad1.abList, equals([5, 7, 48, 7, 48, 74, 5, 74, 43, 67]));
    expect(quad1.xyList, equals([0, 0, 43, 0, 43, 67, 0, 67, 43, 67]));
    expect(quad2.abList, equals([7, 16, 48, 16, 48, 53, 7, 53, 41, 37]));
    expect(quad2.xyList, equals([0, 0, 41, 0, 41, 37, 0, 37, 41, 37]));
  });

  test('ComplicatedCutRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = new Rectangle(5, 7, 85, 30);
    var quad1 = rtq.cut(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad1.abList, equals([43, 5, 43, 90, 13, 90, 13, 5, 30, 85]));
    expect(quad1.xyList, equals([0, 0, 85, 0, 85, 30, 0, 30, 85, 30]));
    expect(quad2.abList, equals([34, 7, 34, 60, 13, 60, 13, 7, 21, 53]));
    expect(quad2.xyList, equals([0, 0, 53, 0, 53, 21, 0, 21, 53, 21]));
  });

  //---------------------------------------------------------------------------


  test('ComplicatedClipCutClip', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 50, 100);
    var rtq = new RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = new Rectangle(5, 7, 43, 67);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad1.abList, equals([5, 7, 48, 7, 48, 74, 5, 74, 43, 67]));
    expect(quad1.xyList, equals([5, 7, 48, 7, 48, 74, 5, 74, 43, 67]));
    expect(quad2.abList, equals([5, 9, 48, 9, 48, 46, 5, 46, 43, 37]));
    expect(quad2.xyList, equals([3, 0, 46, 0, 46, 37, 3, 37, 43, 37]));
  });

  test('ComplicatedClipCutClipRotated', () {
    var src = new Rectangle<int>(0, 0, 50, 100);
    var ofs = new Rectangle<int>(0, 0, 100, 50);
    var rtq = new RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = new Rectangle(5, 7, 85, 30);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad1.abList, equals([43, 5, 43, 90, 13, 90, 13, 5, 30, 85]));
    expect(quad1.xyList, equals([5, 7, 90, 7, 90, 37, 5, 37, 85, 30]));
    expect(quad2.abList, equals([41, 5, 41, 55, 13, 55, 13, 5, 28, 50]));
    expect(quad2.xyList, equals([3, 0, 53, 0, 53, 28, 3, 28, 50, 28]));
  });

}


