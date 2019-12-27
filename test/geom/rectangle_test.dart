@TestOn('browser')
library rectangle_test;

import 'package:test/test.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  test('new rectangle', () {
    var rect = rect1234;

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
  });

  test('new from rectangle', () {
    var rect = rect1234;
    var rect2 = Rectangle.from(rect);

    rect2.left = 5;

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
    testRectangle(rect2, x: 5, y: 2, width: 3, height: 4);
  });

  test('#clone', () {
    var rect = rect1234;
    var rect2 = rect.clone();

    rect2.left = 5;

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
    testRectangle(rect2, x: 5, y: 2, width: 3, height: 4);
  });

  test('#left', () {
    var rect = rect1234;

    expect(rect.left, equals(1));
  });

  test('#left=', () {
    var rect = Rectangle(0, 0, 0, 0);
    rect.left = 10;

    expect(rect.left, 10);
  });

  test('#right', () {
    var rect = rect1234;

    expect(rect.right, equals(4));
  });

  test('#right=', () {
    var rect = rect1234;
    rect.right = 10;

    expect(rect.width, 9);
  });

  test('#top', () {
    var rect = rect1234;

    expect(rect.top, equals(2));
  });

  test('#top=', () {
    var rect = rect1234;
    rect.top = 10;

    expect(rect.top, equals(10));
  });

  test('#bottom', () {
    var rect = rect1234;

    expect(rect.bottom, equals(6));
  });

  test('#bottom=', () {
    var rect = rect1234;
    rect.bottom = 10;

    expect(rect.height, equals(8));
  });

  test('#topLeft', () {
    var point = rect1234.topLeft;

    testPoint(point, 1, 2);
  });

  test('#topLeft=', () {
    var rect = Rectangle(10, 20, 30, 40);

    rect.topLeft = Point(1, 2);

    testRectangle(rect, x: 1, y: 2, width: 39, height: 58);
  });

  test('#bottomRight', () {
    var point = rect1234.bottomRight;

    testPoint(point, 4, 6);
  });

  test('#bottomRight=', () {
    var rect = rect1234;

    rect.bottomRight = Point(10, 10);

    testRectangle(rect, x: 1, y: 2, width: 9, height: 8);
  });

  test('#center', () {
    var point = rect1234.center;

    testPoint(point, 2.5, 4);
  });

  test('#size', () {
    var point = rect1234.size;

    testPoint(point, 3, 4);
  });

  test('#size=', () {
    var rect = rect1234;

    rect.size = Point(10, 10);

    testRectangle(rect, x: 1, y: 2, width: 10, height: 10);
  });

  test('#contains', () {
    var rect = Rectangle(1, 1, 2, 2);
    expect(rect.contains(0, 0), false);
    expect(rect.contains(1, 0), false);
    expect(rect.contains(2, 0), false);
    expect(rect.contains(3, 0), false);
    expect(rect.contains(0, 1), false);
    expect(rect.contains(1, 1), true);
    expect(rect.contains(2, 1), true);
    expect(rect.contains(3, 1), false);
    expect(rect.contains(0, 2), false);
    expect(rect.contains(1, 2), true);
    expect(rect.contains(2, 2), true);
    expect(rect.contains(3, 2), false);
    expect(rect.contains(0, 3), false);
    expect(rect.contains(1, 3), false);
    expect(rect.contains(2, 3), false);
    expect(rect.contains(3, 3), false);
  });

  test('#containsPoint', () {
    var rect = Rectangle(1, 1, 2, 2);
    expect(rect.containsPoint(Point(0, 0)), false);
    expect(rect.containsPoint(Point(1, 0)), false);
    expect(rect.containsPoint(Point(2, 0)), false);
    expect(rect.containsPoint(Point(3, 0)), false);
    expect(rect.containsPoint(Point(0, 1)), false);
    expect(rect.containsPoint(Point(1, 1)), true);
    expect(rect.containsPoint(Point(2, 1)), true);
    expect(rect.containsPoint(Point(3, 1)), false);
    expect(rect.containsPoint(Point(0, 2)), false);
    expect(rect.containsPoint(Point(1, 2)), true);
    expect(rect.containsPoint(Point(2, 2)), true);
    expect(rect.containsPoint(Point(3, 2)), false);
    expect(rect.containsPoint(Point(0, 3)), false);
    expect(rect.containsPoint(Point(1, 3)), false);
    expect(rect.containsPoint(Point(2, 3)), false);
    expect(rect.containsPoint(Point(3, 3)), false);
  });

  test('#containsRect', () {
    var rect = Rectangle(1, 1, 2, 2);

    expect(rect.containsRectangle(Rectangle(0, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(1, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(2, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(0, 1, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(1, 1, 2, 2)), isTrue);
    expect(rect.containsRectangle(Rectangle(2, 1, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(0, 2, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(1, 2, 2, 2)), isFalse);
    expect(rect.containsRectangle(Rectangle(2, 2, 2, 2)), isFalse);
  });

  test('#equals', () {
    var rect = rect1234;

    expect(rect == rect1234, isTrue);
    expect(rect == rect0000, isFalse);
  });

  group('#intersects', () {
    test('is false when there is no intersection', () {
      testRectangleIntersection(
          x1: 0, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 1, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 2, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 0, y1: 1, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 2, y1: 1, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 0, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 1, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(
          x1: 2, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
    });

    test('is true when two rectangles are colliding', () {
      testRectangleIntersection(x1: 0, y1: 0);
      testRectangleIntersection(x1: 0, y1: 1);
      testRectangleIntersection(x1: 0, y1: 2);
      testRectangleIntersection(x1: 1, y1: 0);
      testRectangleIntersection(x1: 1, y1: 1);
      testRectangleIntersection(x1: 1, y1: 2);
      testRectangleIntersection(x1: 2, y1: 0);
      testRectangleIntersection(x1: 2, y1: 1);
      testRectangleIntersection(x1: 2, y1: 2);
    });
  });

  test('#isEmpty', () {
    expect(Rectangle(0, 0, 0, 0).isEmpty, isTrue);
    expect(Rectangle(0, 0, 1, 0).isEmpty, isTrue);
    expect(Rectangle(0, 0, 0, 1).isEmpty, isTrue);
    expect(Rectangle(0, 0, -1, 5).isEmpty, isTrue);
    expect(Rectangle(0, 0, 5, -1).isEmpty, isTrue);
    expect(Rectangle(0, 0, 1, 1).isEmpty, isFalse);
  });

  test('#copyFrom', () {
    var rect = rect1234;
    var rect2 = Rectangle(3, 3, 2, 1);

    rect.copyFrom(rect2);

    testRectangle(rect, x: 3, y: 3, width: 2, height: 1);
  });

  test('#inflate', () {
    var rect = rect1234;
    rect.inflate(1, 2);

    testRectangle(rect, x: 1, y: 2, width: 4, height: 6);
  });

  test('#inflatePoint', () {
    var rect = rect1234;
    rect.inflatePoint(Point(1, 2));

    testRectangle(rect, x: 1, y: 2, width: 4, height: 6);
  });

  test('#offset', () {
    var rect = rect1234;
    rect.offset(1, 2);

    testRectangle(rect, x: 2, y: 4, width: 3, height: 4);
  });

  test('#offsetPoint', () {
    var rect = rect1234;
    rect.offsetPoint(Point(1, 2));

    testRectangle(rect, x: 2, y: 4, width: 3, height: 4);
  });

  test('#setTo', () {
    var rect = rect1234;
    rect.setTo(4, 3, 2, 1);

    testRectangle(rect, x: 4, y: 3, width: 2, height: 1);
  });

  group('#intersection', () {
    test(
        'return rectangle with negative width/height if there is no intersection',
        () {
      var r1 = Rectangle(0, 0, 2, 2);
      var r2 = Rectangle(3, 3, 2, 2);
      var rect = r1.intersection(r2);

      testRectangle(rect, x: 3, y: 3, width: -1, height: -1);
    });

    test('with rectangles intersecting', () {
      var r1 = Rectangle(0, 0, 2, 2);
      var r2 = Rectangle(1, 1, 2, 2);
      var rect = r1.intersection(r2);

      testRectangle(rect, x: 1, y: 1, width: 1, height: 1);
    });
  });

  test('#boundingBox', () {
    var r1 = Rectangle(0, 0, 2, 2);
    var r2 = Rectangle(1, 1, 2, 2);
    var rect = r1.boundingBox(r2);

    testRectangle(rect, x: 0, y: 0, width: 3, height: 3);
  });

  test('#align', () {
    var rect = Rectangle(0.8, 0.7, 2.5, 2.7);

    testRectangle(rect.align(), x: 0, y: 0, width: 4, height: 4);
  });
}

Rectangle get rect1234 => Rectangle(1, 2, 3, 4);
Rectangle get rect0000 => Rectangle(0, 0, 0, 0);

void testRectangle(Rectangle rect, {num x, num y, num width, num height}) {
  if (x != null) expect(rect.left, equals(x));
  if (y != null) expect(rect.top, equals(y));
  if (width != null) expect(rect.width, equals(width));
  if (height != null) expect(rect.height, equals(height));
}

void testPoint(Point point, num x, num y) {
  expect(point.x, equals(x));
  expect(point.y, equals(y));
}

void testRectangleIntersection(
    {num x1 = 0,
    num y1 = 0,
    num x2 = 1,
    num y2 = 1,
    num sideSize = 2,
    Matcher matcher = isTrue}) {
  var r1 = Rectangle(x1, y1, sideSize, sideSize);
  var r2 = Rectangle(x2, y2, sideSize, sideSize);

  expect(r1.intersects(r2), matcher);
}
