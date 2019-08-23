@TestOn("browser")
library render_texture_quad_test;

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:stagexl/stagexl.dart';

//-----------------------------------------------------------------------------

Matcher equalsFloats(List<num> values) {
  var doubles = values.map((v) => v.toDouble()).toList();
  return equals(Float32List.fromList(doubles));
}

void main() {
  var rt = RenderTexture(50, 100, 0xFFFF00FF);

  test('CreateRenderTextureQuadRotation0', () {
    var src = Rectangle<int>(5, 10, 30, 70);
    var ofs = Rectangle<int>(0, 0, 35, 85);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    expect(
        rtq.vxList,
        equalsFloats([
          0,
          0,
          5 / 50,
          10 / 100,
          30,
          0,
          35 / 50,
          10 / 100,
          30,
          70,
          35 / 50,
          80 / 100,
          0,
          70,
          5 / 50,
          80 / 100
        ]));
  });

  test('CreateRenderTextureQuadRotation1', () {
    var src = Rectangle<int>(5, 10, 30, 70);
    var ofs = Rectangle<int>(0, 0, 85, 35);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    expect(
        rtq.vxList,
        equalsFloats([
          0,
          0,
          35 / 50,
          10 / 100,
          70,
          0,
          35 / 50,
          80 / 100,
          70,
          30,
          5 / 50,
          80 / 100,
          0,
          30,
          5 / 50,
          10 / 100,
        ]));
  });

  test('CreateRenderTextureQuadRotation2', () {
    var src = Rectangle<int>(5, 10, 30, 70);
    var ofs = Rectangle<int>(0, 0, 35, 85);
    var rtq = RenderTextureQuad(rt, src, ofs, 2, 1.0);
    expect(
        rtq.vxList,
        equalsFloats([
          0,
          0,
          35 / 50,
          80 / 100,
          30,
          0,
          5 / 50,
          80 / 100,
          30,
          70,
          5 / 50,
          10 / 100,
          0,
          70,
          35 / 50,
          10 / 100,
        ]));
  });

  test('CreateRenderTextureQuadRotation3', () {
    var src = Rectangle<int>(5, 10, 30, 70);
    var ofs = Rectangle<int>(0, 0, 35, 85);
    var rtq = RenderTextureQuad(rt, src, ofs, 3, 1.0);
    expect(
        rtq.vxList,
        equalsFloats([
          0,
          0,
          5 / 50,
          80 / 100,
          70,
          0,
          5 / 50,
          10 / 100,
          70,
          30,
          35 / 50,
          10 / 100,
          0,
          30,
          35 / 50,
          80 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('SimpleClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          20,
          10 / 50,
          20 / 100,
          43,
          20,
          43 / 50,
          20 / 100,
          43,
          47,
          43 / 50,
          47 / 100,
          10,
          47,
          10 / 50,
          47 / 100,
        ]));
  });

  test('SimpleClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, 20, 33, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          20,
          30 / 50,
          10 / 100,
          43,
          20,
          30 / 50,
          43 / 100,
          43,
          47,
          3 / 50,
          43 / 100,
          10,
          47,
          3 / 50,
          10 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          10,
          20 / 50,
          10 / 100,
          50,
          10,
          50 / 50,
          10 / 100,
          50,
          37,
          50 / 50,
          37 / 100,
          20,
          37,
          20 / 50,
          37 / 100,
        ]));
  });

  test('RightOverlapClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          10,
          40 / 50,
          20 / 100,
          100,
          10,
          40 / 50,
          100 / 100,
          100,
          37,
          13 / 50,
          100 / 100,
          20,
          37,
          13 / 50,
          20 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(-20, 10, 53, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          10,
          0 / 50,
          10 / 100,
          33,
          10,
          33 / 50,
          10 / 100,
          33,
          37,
          33 / 50,
          37 / 100,
          0,
          37,
          0 / 50,
          37 / 100,
        ]));
  });

  test('LeftOverlapClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(-20, 10, 93, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          10,
          40 / 50,
          0 / 100,
          73,
          10,
          40 / 50,
          73 / 100,
          73,
          37,
          13 / 50,
          73 / 100,
          0,
          37,
          13 / 50,
          0 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          0,
          10 / 50,
          0 / 100,
          27,
          0,
          27 / 50,
          0 / 100,
          27,
          49,
          27 / 50,
          49 / 100,
          10,
          49,
          10 / 50,
          49 / 100,
        ]));
  });

  test('TopOverlapClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, -13, 17, 62);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          0,
          50 / 50,
          10 / 100,
          27,
          0,
          50 / 50,
          27 / 100,
          27,
          49,
          1 / 50,
          27 / 100,
          10,
          49,
          1 / 50,
          10 / 100
        ]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, 53, 17, 62);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          53,
          10 / 50,
          53 / 100,
          27,
          53,
          27 / 50,
          53 / 100,
          27,
          100,
          27 / 50,
          100 / 100,
          10,
          100,
          10 / 50,
          100 / 100,
        ]));
  });

  test('BottomOverlapClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, 13, 17, 62);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          13,
          37 / 50,
          10 / 100,
          27,
          13,
          37 / 50,
          27 / 100,
          27,
          50,
          0 / 50,
          27 / 100,
          10,
          50,
          0 / 50,
          10 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = Rectangle(5, 7, 43, 67);
    var quad1 = rtq.clip(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          5,
          7,
          5 / 50,
          7 / 100,
          48,
          7,
          48 / 50,
          7 / 100,
          48,
          74,
          48 / 50,
          74 / 100,
          5,
          74,
          5 / 50,
          74 / 100,
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          5,
          9,
          5 / 50,
          9 / 100,
          48,
          9,
          48 / 50,
          9 / 100,
          48,
          46,
          48 / 50,
          46 / 100,
          5,
          46,
          5 / 50,
          46 / 100,
        ]));
  });

  test('ComplicatedClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = Rectangle(5, 7, 85, 30);
    var quad1 = rtq.clip(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.clip(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          5,
          7,
          43 / 50,
          5 / 100,
          90,
          7,
          43 / 50,
          90 / 100,
          90,
          37,
          13 / 50,
          90 / 100,
          5,
          37,
          13 / 50,
          5 / 100
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          5,
          9,
          41 / 50,
          5 / 100,
          55,
          9,
          41 / 50,
          55 / 100,
          55,
          37,
          13 / 50,
          55 / 100,
          5,
          37,
          13 / 50,
          5 / 100,
        ]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('OutsideLeftRightClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          20,
          0 / 50,
          20 / 100,
          50,
          20,
          50 / 50,
          20 / 100,
          50,
          47,
          50 / 50,
          47 / 100,
          0,
          47,
          0 / 50,
          47 / 100
        ]));
  });

  test('OutsideLeftRightClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(-10, 20, 180, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          20,
          30 / 50,
          0 / 100,
          100,
          20,
          30 / 50,
          100 / 100,
          100,
          47,
          3 / 50,
          100 / 100,
          0,
          47,
          3 / 50,
          0 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopBottomClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          0,
          20 / 50,
          0 / 100,
          43,
          0,
          43 / 50,
          0 / 100,
          43,
          100,
          43 / 50,
          100 / 100,
          20,
          100,
          20 / 50,
          100 / 100,
        ]));
  });

  test('OutsideTopBottomClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(20, -10, 23, 170);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          0,
          50 / 50,
          20 / 100,
          43,
          0,
          50 / 50,
          43 / 100,
          43,
          50,
          0 / 50,
          43 / 100,
          20,
          50,
          0 / 50,
          20 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopLeftClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          0 / 50,
          0 / 100,
          0,
          0,
          0 / 50,
          0 / 100,
          0,
          0,
          0 / 50,
          0 / 100,
          0,
          0,
          0 / 50,
          0 / 100,
        ]));
  });

  test('OutsideTopLeftClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(-10, -20, 3, 7);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          50 / 50,
          0 / 100,
          0,
          0,
          50 / 50,
          0 / 100,
          0,
          0,
          50 / 50,
          0 / 100,
          0,
          0,
          50 / 50,
          0 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideBottomRightClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(60, 110, 3, 7);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          50,
          100,
          50 / 50,
          100 / 100,
          50,
          100,
          50 / 50,
          100 / 100,
          50,
          100,
          50 / 50,
          100 / 100,
          50,
          100,
          50 / 50,
          100 / 100
        ]));
  });

  test('OutsideBottomRightClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(110, 60, 3, 7);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          100,
          50,
          0 / 50,
          100 / 100,
          100,
          50,
          0 / 50,
          100 / 100,
          100,
          50,
          0 / 50,
          100 / 100,
          100,
          50,
          0 / 50,
          100 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideLeftClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          20,
          0 / 50,
          20 / 100,
          0,
          20,
          0 / 50,
          20 / 100,
          0,
          47,
          0 / 50,
          47 / 100,
          0,
          47,
          0 / 50,
          47 / 100
        ]));
  });

  test('OutsideLeftClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(-10, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          20,
          30 / 50,
          0 / 100,
          0,
          20,
          30 / 50,
          0 / 100,
          0,
          47,
          3 / 50,
          0 / 100,
          0,
          47,
          3 / 50,
          0 / 100
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideRightClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(60, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          50,
          20,
          50 / 50,
          20 / 100,
          50,
          20,
          50 / 50,
          20 / 100,
          50,
          47,
          50 / 50,
          47 / 100,
          50,
          47,
          50 / 50,
          47 / 100
        ]));
  });

  test('OutsideRightClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(110, 20, 5, 27);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          100,
          20,
          30 / 50,
          100 / 100,
          100,
          20,
          30 / 50,
          100 / 100,
          100,
          47,
          3 / 50,
          100 / 100,
          100,
          47,
          3 / 50,
          100 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideTopClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          0,
          10 / 50,
          0 / 100,
          37,
          0,
          37 / 50,
          0 / 100,
          37,
          0,
          37 / 50,
          0 / 100,
          10,
          0,
          10 / 50,
          0 / 100,
        ]));
  });

  test('OutsideTopClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, -20, 27, 5);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          0,
          50 / 50,
          10 / 100,
          37,
          0,
          50 / 50,
          37 / 100,
          37,
          0,
          50 / 50,
          37 / 100,
          10,
          0,
          50 / 50,
          10 / 100
        ]));
  });

  //---------------------------------------------------------------------------

  test('OutsideBottomClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          100,
          10 / 50,
          100 / 100,
          37,
          100,
          37 / 50,
          100 / 100,
          37,
          100,
          37 / 50,
          100 / 100,
          10,
          100,
          10 / 50,
          100 / 100,
        ]));
  });

  test('OutsideBottomClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, 120, 27, 5);
    var quad = rtq.clip(rect);
    expect(
        quad.vxList,
        equalsFloats([
          10,
          50,
          0 / 50,
          10 / 100,
          37,
          50,
          0 / 50,
          37 / 100,
          37,
          50,
          0 / 50,
          37 / 100,
          10,
          50,
          0 / 50,
          10 / 100,
        ]));
  });

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  test('SimpleCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          10 / 50,
          20 / 100,
          33,
          0,
          43 / 50,
          20 / 100,
          33,
          27,
          43 / 50,
          47 / 100,
          0,
          27,
          10 / 50,
          47 / 100,
        ]));
  });

  test('SimpleCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, 20, 33, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          30 / 50,
          10 / 100,
          33,
          0,
          30 / 50,
          43 / 100,
          33,
          27,
          3 / 50,
          43 / 100,
          0,
          27,
          3 / 50,
          10 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('RightOverlapCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          20 / 50,
          10 / 100,
          30,
          0,
          50 / 50,
          10 / 100,
          30,
          27,
          50 / 50,
          37 / 100,
          0,
          27,
          20 / 50,
          37 / 100,
        ]));
  });

  test('RightOverlapCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          40 / 50,
          20 / 100,
          80,
          0,
          40 / 50,
          100 / 100,
          80,
          27,
          13 / 50,
          100 / 100,
          0,
          27,
          13 / 50,
          20 / 100
        ]));
  });

  //---------------------------------------------------------------------------

  test('LeftOverlapCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(-20, 10, 53, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          0,
          0 / 50,
          10 / 100,
          53,
          0,
          33 / 50,
          10 / 100,
          53,
          27,
          33 / 50,
          37 / 100,
          20,
          27,
          0 / 50,
          37 / 100,
        ]));
  });

  test('LeftOverlapCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(-20, 10, 93, 27);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          20,
          0,
          40 / 50,
          0 / 100,
          93,
          0,
          40 / 50,
          73 / 100,
          93,
          27,
          13 / 50,
          73 / 100,
          20,
          27,
          13 / 50,
          0 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('TopOverlapCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          13,
          10 / 50,
          0 / 100,
          17,
          13,
          27 / 50,
          0 / 100,
          17,
          62,
          27 / 50,
          49 / 100,
          0,
          62,
          10 / 50,
          49 / 100
        ]));
  });

  test('TopOverlapCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, -13, 17, 62);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          13,
          50 / 50,
          10 / 100,
          17,
          13,
          50 / 50,
          27 / 100,
          17,
          62,
          1 / 50,
          27 / 100,
          0,
          62,
          1 / 50,
          10 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('BottomOverlapCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect = Rectangle(10, 53, 17, 62);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          10 / 50,
          53 / 100,
          17,
          0,
          27 / 50,
          53 / 100,
          17,
          47,
          27 / 50,
          100 / 100,
          0,
          47,
          10 / 50,
          100 / 100,
        ]));
  });

  test('BottomOverlapCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect = Rectangle(10, 13, 17, 62);
    var quad = rtq.cut(rect);
    expect(
        quad.vxList,
        equalsFloats([
          0,
          0,
          37 / 50,
          10 / 100,
          17,
          0,
          37 / 50,
          27 / 100,
          17,
          37,
          0 / 50,
          27 / 100,
          0,
          37,
          0 / 50,
          10 / 100
        ]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedCut', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = Rectangle(5, 7, 43, 67);
    var quad1 = rtq.cut(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          0,
          0,
          5 / 50,
          7 / 100,
          43,
          0,
          48 / 50,
          7 / 100,
          43,
          67,
          48 / 50,
          74 / 100,
          0,
          67,
          5 / 50,
          74 / 100,
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          0,
          0,
          7 / 50,
          16 / 100,
          41,
          0,
          48 / 50,
          16 / 100,
          41,
          37,
          48 / 50,
          53 / 100,
          0,
          37,
          7 / 50,
          53 / 100,
        ]));
  });

  test('ComplicatedCutRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = Rectangle(5, 7, 85, 30);
    var quad1 = rtq.cut(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          0,
          0,
          43 / 50,
          5 / 100,
          85,
          0,
          43 / 50,
          90 / 100,
          85,
          30,
          13 / 50,
          90 / 100,
          0,
          30,
          13 / 50,
          5 / 100,
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          0,
          0,
          34 / 50,
          7 / 100,
          53,
          0,
          34 / 50,
          60 / 100,
          53,
          21,
          13 / 50,
          60 / 100,
          0,
          21,
          13 / 50,
          7 / 100,
        ]));
  });

  //---------------------------------------------------------------------------

  test('ComplicatedClipCutClip', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 50, 100);
    var rtq = RenderTextureQuad(rt, src, ofs, 0, 1.0);
    var rect1 = Rectangle(5, 7, 43, 67);
    var quad1 = rtq.clip(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          5,
          7,
          5 / 50,
          7 / 100,
          48,
          7,
          48 / 50,
          7 / 100,
          48,
          74,
          48 / 50,
          74 / 100,
          5,
          74,
          5 / 50,
          74 / 100,
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          3,
          0,
          5 / 50,
          9 / 100,
          46,
          0,
          48 / 50,
          9 / 100,
          46,
          37,
          48 / 50,
          46 / 100,
          3,
          37,
          5 / 50,
          46 / 100,
        ]));
  });

  test('ComplicatedClipCutClipRotated', () {
    var src = Rectangle<int>(0, 0, 50, 100);
    var ofs = Rectangle<int>(0, 0, 100, 50);
    var rtq = RenderTextureQuad(rt, src, ofs, 1, 1.0);
    var rect1 = Rectangle(5, 7, 85, 30);
    var quad1 = rtq.clip(rect1);
    var rect2 = Rectangle(2, 9, 53, 37);
    var quad2 = quad1.cut(rect2);
    expect(
        quad1.vxList,
        equalsFloats([
          5,
          7,
          43 / 50,
          5 / 100,
          90,
          7,
          43 / 50,
          90 / 100,
          90,
          37,
          13 / 50,
          90 / 100,
          5,
          37,
          13 / 50,
          5 / 100,
        ]));
    expect(
        quad2.vxList,
        equalsFloats([
          3,
          0,
          41 / 50,
          5 / 100,
          53,
          0,
          41 / 50,
          55 / 100,
          53,
          28,
          13 / 50,
          55 / 100,
          3,
          28,
          13 / 50,
          5 / 100,
        ]));
  });
}
