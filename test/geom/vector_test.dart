library vector_test;

import 'dart:math';

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {

  test('VectorIsZero', () {
    var vector = new Vector(0, 0);
    expect(vector.x, equals(0));
    expect(vector.y, equals(0));
    expect(vector.isZero, isTrue);
  });

  test('VectorOperators', () {
    var v1 = new Vector(10, 20);
    var v2 = new Vector(30, 40);
    var vAdd = v1 + v2;
    var vSub = v1 - v2;
    var vMul = v1 * v2;
    var vDiv = v1 / v2;

    expect(vAdd.x, equals(10 + 30));
    expect(vAdd.y, equals(20 + 40));
    expect(vSub.x, equals(10 - 30));
    expect(vSub.y, equals(20 - 40));
    expect(vMul.x, equals(10 * 30));
    expect(vMul.y, equals(20 * 40));
    expect(vDiv.x, equals(10 / 30));
    expect(vDiv.y, equals(20 / 40));

    expect(v1 == new Vector(10, 20), isTrue);
  });

  test('VectorScale', () {
    var v1 = new Vector(10, 20);
    var v2 = v1.normalize();

    expect(v1.isNormalized, isFalse);
    expect(v2.isNormalized, isTrue);
    expect(v1.scale(2).length, equals(44.721359549995796));
    expect(v1.scaleLength(10).length, equals(10));
  });

  test('VectorDistance', () {
    var v1 = new Vector(10, 20);
    var v2 = new Vector(30, 40);
    var v3 = new Vector(20, 20);

    expect(v1.length, equals(22.360679774997898));
    expect(v1.lengthSqr, equals(10 * 10 + 20 * 20));

    expect((v2 - v3).isNear(v1), isTrue);
    expect((v2 - v3).isNearXY(10, 20), isTrue);
    expect((v2 - v2).isNear(v1), isFalse);
    expect((v2 - v2).isNearXY(0, 0.1), isFalse);

    expect(v1.distance(v2), equals(28.284271247461902));
    expect(v1.distanceSqr(v2), equals(800.0));
    expect(v1.distanceXY(50, 40), equals(44.721359549995796));
    expect(v1.distanceXYSqr(50, 40), equals(2000.0));
  });

  test('VectorRotate', () {
    expect(new Vector(1, 0).normalLeft().isNearXY(0, -1), isTrue);
    expect(new Vector(1, 0).normalRight().isNearXY(0, 1), isTrue);
    expect(new Vector(-13, 3).negate().isNearXY(13, -3), isTrue);
    expect(new Vector(1, 0).rotate(PI * 0.5).isNearXY(0, 1), isTrue);
    expect(new Vector(1, 1).rads, closeTo(PI / 4, Vector.Epsilon));
    expect(new Vector(1, 1).degrees, closeTo(45, Vector.Epsilon));
  });

  test('VectorDot', () {
    expect(new Vector(1, 0).dotXY(1, 0), equals(1.0));
    expect(new Vector(1, 0).dotXY(-1, 0), equals(-1.0));
    expect(new Vector(1, 0).dotXY(0, 1), equals(0.0));
    expect(new Vector(1, 1).normalize().dot(new Vector(1, -1)), equals(0.0));
  });

  test('VectorCross', () {
    expect(new Vector(1, 0).crossDetXY(1, 0), equals(0.0));
    expect(new Vector(1, 0).crossDetXY(0, -1), equals(-1.0));
    expect(new Vector(1, 0).crossDetXY(0, 1), equals(1.0));
    expect(new Vector(1, 0).crossDet(new Vector(1, 0)), equals(0.0));
    expect(new Vector(1, 0).crossDet(new Vector(0, -1)), equals(-1.0));
    expect(new Vector(1, 0).crossDet(new Vector(0, 1)), equals(1.0));
  });

  test('VectorLerp', () {
    expect(new Vector(1, 0).lerp(new Vector(0, -1), 0.5).isWithinXY(0.5, -0.5,
        0.01), isTrue);
    expect(new Vector(1, 0).lerp(new Vector(-1, 0), 0.5).isWithinXY(0, 0, 0.01),
        isTrue);
  });

  test('VectorSlerp', () {
    expect(new Vector(1, 0).slerp(new Vector(0, -1), 0.5).isWithinXY(0.7, -0.7,
        0.1), isTrue);
  });

}
