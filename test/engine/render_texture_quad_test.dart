library render_texture_quad_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {

  var rt = new RenderTexture(50, 100, true, 0xFFFF00FF, 1.0);

  test('CreateRenderTextureQuad', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    expect(rtq.textureX, equals(0));
    expect(rtq.textureY, equals(0));
    expect(rtq.textureWidth, equals(50));
    expect(rtq.textureHeight, equals(100));
    expect(rtq.offsetX, equals(0));
    expect(rtq.offsetY, equals(0));
    expect(rtq.xyList, equals([0, 0, 50, 0, 50, 100, 0, 100]));
  });

  test('CreateRenderTextureQuadRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    expect(rtq.textureX, equals(50));
    expect(rtq.textureY, equals(0));
    expect(rtq.textureWidth, equals(100));
    expect(rtq.textureHeight, equals(50));
    expect(rtq.offsetX, equals(0));
    expect(rtq.offsetY, equals(0));
    expect(rtq.xyList, equals([50, 0, 50, 100, 0, 100, 0, 0]));
  });

  //---------------------------------------------------------------------------

  test('SimpleClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([10, 20, 43, 20, 43, 47, 10, 47]));
  });

  test('SimpleClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(30));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([30, 10, 30, 43, 3, 43, 3, 10]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(20));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(30));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(10));
    expect(quad.xyList, equals([20, 10, 50, 10, 50, 37, 20, 37]));
  });

  test('RightOverlapClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(40));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(80));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(10));
    expect(quad.xyList, equals([40, 20, 40, 100, 13, 100, 13, 20]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(-20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(10));
    expect(quad.xyList, equals([0, 10, 33, 10, 33, 37, 0, 37]));
  });

  test('LeftOverlapClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(-20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(40));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(73));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(10));
    expect(quad.xyList, equals([40, 0, 40, 73, 13, 73, 13, 0]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(49));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([10, 0, 27, 0, 27, 49, 10, 49]));
  });

  test('TopOverlapClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(49));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([50, 10, 50, 27, 1, 27, 1, 10]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, 53, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(53));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(47));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(53));
    expect(quad.xyList, equals([10, 53, 27, 53, 27, 100, 10, 100]));
  });

  test('BottomOverlapClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, 13, 17, 62);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(37));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(37));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(13));
    expect(quad.xyList, equals([37, 10, 37, 27, 0, 27, 0, 10]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect1 = new Rectangle(5, 7, 43, 67);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(quad1.textureX, equals(5));
    expect(quad1.textureY, equals(7));
    expect(quad1.textureWidth, equals(43));
    expect(quad1.textureHeight, equals(67));
    expect(quad1.offsetX, equals(5));
    expect(quad1.offsetY, equals(7));
    expect(quad1.xyList, equals([5, 7, 48, 7, 48, 74, 5, 74]));
    expect(quad2.textureX, equals(5));
    expect(quad2.textureY, equals(9));
    expect(quad2.textureWidth, equals(43));
    expect(quad2.textureHeight, equals(37));
    expect(quad2.offsetX, equals(5));
    expect(quad2.offsetY, equals(9));
    expect(quad2.xyList, equals([5, 9, 48, 9, 48, 46, 5, 46]));
  });

  test('ComplicatedClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect1 = new Rectangle(5, 7, 85, 30);
    var quad1 = rtq.clip(rect1);
    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(quad1.textureX, equals(43));
    expect(quad1.textureY, equals(5));
    expect(quad1.textureWidth, equals(85));
    expect(quad1.textureHeight, equals(30));
    expect(quad1.offsetX, equals(5));
    expect(quad1.offsetY, equals(7));
    expect(quad1.xyList, equals([43, 5, 43, 90, 13, 90, 13, 5]));
    expect(quad2.textureX, equals(41));
    expect(quad2.textureY, equals(5));
    expect(quad2.textureWidth, equals(50));
    expect(quad2.textureHeight, equals(28));
    expect(quad2.offsetX, equals(5));
    expect(quad2.offsetY, equals(9));
    expect(quad2.xyList, equals([41, 5, 41, 55, 13, 55, 13, 5]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('OutsideLeftRightClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(50));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([0, 20, 50, 20, 50, 47, 0, 47]));
  });

  test('OutsideLeftRightClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(30));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(100));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([30, 0, 30, 100, 3, 100, 3, 0]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopBottomClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(20));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(23));
    expect(quad.textureHeight, equals(100));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([20, 0, 43, 0, 43, 100, 20, 100]));
  });

  test('OutsideTopBottomClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(23));
    expect(quad.textureHeight, equals(50));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([50, 20, 50, 43, 0, 43, 0, 20]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopLeftClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([0, 0, 0, 0, 0, 0, 0, 0]));
  });

  test('OutsideTopLeftClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([50, 0, 50, 0, 50, 0, 50, 0]));
  });


  //---------------------------------------------------------------------------

  test('OutsideBottomRightClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(60, 110, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(100));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(50));
    expect(quad.offsetY, equals(100));
    expect(quad.xyList, equals([50, 100, 50, 100, 50, 100, 50, 100]));
  });

  test('OutsideBottomRightClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(110, 60, 3, 7);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(100));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(100));
    expect(quad.offsetY, equals(50));
    expect(quad.xyList, equals([0, 100, 0, 100, 0, 100, 0, 100]));
  });

  //---------------------------------------------------------------------------

  test('OutsideLeftClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([0, 20, 0, 20, 0, 47, 0, 47]));
  });

  test('OutsideLeftClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(30));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([30, 0, 30, 0, 3, 0, 3, 0]));
  });

  //---------------------------------------------------------------------------

  test('OutsideRightClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(60, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(50));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([50, 20, 50, 20, 50, 47, 50, 47]));
  });

  test('OutsideRightClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(110, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(30));
    expect(quad.textureY, equals(100));
    expect(quad.textureWidth, equals(0));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(100));
    expect(quad.offsetY, equals(20));
    expect(quad.xyList, equals([30, 100, 30, 100, 3, 100, 3, 100]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(27));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([10, 0, 37, 0, 37, 0, 10, 0]));
  });

  test('OutsideTopClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(27));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([50, 10, 50, 37, 50, 37, 50, 10]));
  });

  //---------------------------------------------------------------------------

  test('OutsideBottomClip', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(100));
    expect(quad.textureWidth, equals(27));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(100));
    expect(quad.xyList, equals([10, 100, 37, 100, 37, 100, 10, 100]));
  });

  test('OutsideBottomClipRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(27));
    expect(quad.textureHeight, equals(0));
    expect(quad.offsetX, equals(10));
    expect(quad.offsetY, equals(50));
    expect(quad.xyList, equals([0, 10, 0, 37, 0, 37, 0, 10]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('SimpleCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([10, 20, 43, 20, 43, 47, 10, 47]));
  });

  test('SimpleCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(30));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([30, 10, 30, 43, 3, 43, 3, 10]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(20));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(30));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([20, 10, 50, 10, 50, 37, 20, 37]));
  });

  test('RightOverlapCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(40));
    expect(quad.textureY, equals(20));
    expect(quad.textureWidth, equals(80));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([40, 20, 40, 100, 13, 100, 13, 20]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(-20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(0));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(33));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([0, 10, 33, 10, 33, 37, 0, 37]));
  });

  test('LeftOverlapCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(-20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(40));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(73));
    expect(quad.textureHeight, equals(27));
    expect(quad.offsetX, equals(20));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([40, 0, 40, 73, 13, 73, 13, 0]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(0));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(49));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(13));
    expect(quad.xyList, equals([10, 0, 27, 0, 27, 49, 10, 49]));
  });

  test('TopOverlapCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(50));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(49));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(13));
    expect(quad.xyList, equals([50, 10, 50, 27, 1, 27, 1, 10]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect = new Rectangle(10, 53, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(10));
    expect(quad.textureY, equals(53));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(47));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([10, 53, 27, 53, 27, 100, 10, 100]));
  });

  test('BottomOverlapCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect = new Rectangle(10, 13, 17, 62);
    var quad = rtq.cut(rect);
    expect(quad.textureX, equals(37));
    expect(quad.textureY, equals(10));
    expect(quad.textureWidth, equals(17));
    expect(quad.textureHeight, equals(37));
    expect(quad.offsetX, equals(0));
    expect(quad.offsetY, equals(0));
    expect(quad.xyList, equals([37, 10, 37, 27, 0, 27, 0, 10]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedCut', () {
    var rtq = new RenderTextureQuad(rt, 0, 0, 0, 0, 0, 50, 100);
    var rect1 = new Rectangle(5, 7, 43, 67);
    var quad1 = rtq.cut(rect1);
    expect(quad1.textureX, equals(5));
    expect(quad1.textureY, equals(7));
    expect(quad1.textureWidth, equals(43));
    expect(quad1.textureHeight, equals(67));
    expect(quad1.offsetX, equals(0));
    expect(quad1.offsetY, equals(0));
    expect(quad1.xyList, equals([5, 7, 48, 7, 48, 74, 5, 74]));

    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad2.textureX, equals(7));
    expect(quad2.textureY, equals(16));
    expect(quad2.textureWidth, equals(41));
    expect(quad2.textureHeight, equals(37));
    expect(quad2.offsetX, equals(0));
    expect(quad2.offsetY, equals(0));
    expect(quad2.xyList, equals([7, 16, 48, 16, 48, 53, 7, 53]));
  });

  test('ComplicatedCutRotated', () {
    var rtq = new RenderTextureQuad(rt, 1, 0, 0, 50, 0, 100, 50);
    var rect1 = new Rectangle(5, 7, 85, 30);
    var quad1 = rtq.cut(rect1);
    expect(quad1.textureX, equals(43));
    expect(quad1.textureY, equals(5));
    expect(quad1.textureWidth, equals(85));
    expect(quad1.textureHeight, equals(30));
    expect(quad1.offsetX, equals(0));
    expect(quad1.offsetY, equals(0));
    expect(quad1.xyList, equals([43, 5, 43, 90, 13, 90, 13, 5]));

    var rect2 = new Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(quad2.textureX, equals(34));
    expect(quad2.textureY, equals(7));
    expect(quad2.textureWidth, equals(53));
    expect(quad2.textureHeight, equals(21));
    expect(quad2.offsetX, equals(0));
    expect(quad2.offsetY, equals(0));
    expect(quad2.xyList, equals([34, 7, 34, 60, 13, 60, 13, 7]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

}
