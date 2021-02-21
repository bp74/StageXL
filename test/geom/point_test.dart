@TestOn('browser')
library point_test;

import 'package:test/test.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  test('new point', () {
    final p = point12();
    testPoint(p, x: 1, y: 2);
  });

  test('new from point', () {
    final source = point12();
    final p = Point.from(source);

    p.x = 3;

    testPoint(source, x: 1, y: 2);
    testPoint(p, x: 3, y: 2);
  });

  test('#clone', () {
    final source = point12();
    final p = source.clone();

    p.x = 3;

    testPoint(source, x: 1, y: 2);
    testPoint(p, x: 3, y: 2);
  });

  test('#toString', () {
    final p = point12();

    expect(p.toString(), equals('Point<num> [x=1, y=2]'));
  });

  final distanceTestTable = [
    [0, 0, 0, 2, 2],
    [0, 0, 2, 0, 2],
    [0, 0, 2, 2, 2.828]
  ];

  test('.distance', () {
    for (var r in distanceTestTable) {
      final p1 = Point(r[0], r[1]);
      final p2 = Point(r[2], r[3]);

      expect(Point.distance(p1, p2), closeTo(r[4], 0.001));
    }
  });

  test('#distanceTo', () {
    for (var r in distanceTestTable) {
      final p1 = Point(r[0], r[1]);
      final p2 = Point(r[2], r[3]);

      expect(p1.distanceTo(p2), closeTo(r[4], 0.001));
    }
  });

  test('.interpolate', () {
    testPoint(Point.interpolate(point12(), Point(3, 4), 3), x: -3, y: -2);
  });

  test('.polar', () {
    testPoint(Point.polar(10, 1), x: 5.403, y: 8.414);
  });

  test('#magnitude', () {
    expect(point12().magnitude, closeTo(2.236, 0.001));
  });

  test('#add', () {
    testPoint(point12() + point12(), x: 2, y: 4);
  });

  test('#subtract', () {
    testPoint(point12() - point12(), x: 0, y: 0);
  });

  test('#multiply', () {
    testPoint(point12() * 5, x: 5, y: 10);
  });

  test('#copyFrom', () {
    final source = point12();
    final p = point00();
    p.copyFrom(source);

    p.x = 3;

    testPoint(source, x: 1, y: 2);
    testPoint(p, x: 3, y: 2);
  });

  test('#setTo', () {
    final p = point00();
    p.setTo(1, 2);

    testPoint(p, x: 1, y: 2);
  });

  test('#equals', () {
    expect(point12() == point12(), isTrue);
    expect(point12() == point00(), isFalse);
  });

  test('#offset', () {
    final p = point12();
    p.offset(2, 3);

    testPoint(p, x: 3, y: 5);
  });
}

Point point12() => Point<num>(1, 2);
Point point00() => Point<num>(0, 0);

void testPoint(Point point, {num? x, num? y}) {
  if (x != null) expect(point.x, closeTo(x, 0.001));
  if (y != null) expect(point.y, closeTo(y, 0.001));
}
