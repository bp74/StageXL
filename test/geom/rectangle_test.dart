library rectangle_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  test('new rectangle', () {
    Rectangle rect = rect1234();

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
  });

  test('new from rectangle', () {
    Rectangle rect = rect1234();
    Rectangle rect2 = new Rectangle.from(rect);

    rect2.left = 5;

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
    testRectangle(rect2, x: 5, y: 2, width: 3, height: 4);
  });

  test('#clone', () {
    Rectangle rect = rect1234();
    Rectangle rect2 = rect.clone();

    rect2.left = 5;

    testRectangle(rect, x: 1, y: 2, width: 3, height: 4);
    testRectangle(rect2, x: 5, y: 2, width: 3, height: 4);
  });

  test('#left', () {
    Rectangle rect = rect1234();

    expect(rect.left, equals(1));
  });

  test('#left=', () {
    Rectangle rect = new Rectangle(0, 0, 0, 0);
    rect.left = 10;

    expect(rect.left, 10);
  });

  test('#right', () {
    Rectangle rect = rect1234();

    expect(rect.right, equals(4));
  });

  test('#right=', () {
    Rectangle rect = rect1234();
    rect.right = 10;

    expect(rect.width, 9);
  });

  test('#top', () {
    Rectangle rect = rect1234();

    expect(rect.top, equals(2));
  });

  test('#top=', () {
    Rectangle rect = rect1234();
    rect.top = 10;

    expect(rect.top, equals(10));
  });

  test('#bottom', () {
    Rectangle rect = rect1234();

    expect(rect.bottom, equals(6));
  });

  test('#bottom=', () {
    Rectangle rect = rect1234();
    rect.bottom = 10;

    expect(rect.height, equals(8));
  });

  test('#topLeft', () {
    Point point = rect1234().topLeft;

    testPoint(point, 1, 2);
  });

  test('#topLeft=', () {
    Rectangle rect = new Rectangle(10, 20, 30, 40);

    rect.topLeft = new Point(1, 2);

    testRectangle(rect, x: 1, y: 2, width: 39, height: 58);
  });

  test('#bottomRight', () {
    Point point = rect1234().bottomRight;

    testPoint(point, 4, 6);
  });

  test('#bottomRight=', () {
    Rectangle rect = rect1234();

    rect.bottomRight = new Point(10, 10);

    testRectangle(rect, x: 1, y: 2, width: 9, height: 8);
  });

  test('#center', () {
    Point point = rect1234().center;

    testPoint(point, 2.5, 4);
  });

  test('#size', () {
    Point point = rect1234().size;

    testPoint(point, 3, 4);
  });

  test('#size=', () {
    Rectangle rect = rect1234();

    rect.size = new Point(10, 10);

    testRectangle(rect, x: 1, y: 2, width: 10, height: 10);
  });

  List<List> containsPointMatches = [
    [0, 0, isFalse],
    [1, 0, isFalse],
    [2, 0, isFalse],
    [3, 0, isFalse],
    [0, 1, isFalse],
    [1, 1, isTrue],
    [2, 1, isTrue],
    [3, 1, isFalse],
    [0, 2, isFalse],
    [1, 2, isTrue],
    [2, 2, isTrue],
    [3, 2, isFalse],
    [0, 3, isFalse],
    [1, 3, isFalse],
    [2, 3, isFalse],
    [3, 3, isFalse]
  ];

  test('#contains', () {
    Rectangle rect = new Rectangle(1, 1, 2, 2);

    for (List args in containsPointMatches) {
      expect(rect.contains(args[0], args[1]), args[2]);
    }
  });

  test('#containsPoint', () {
    Rectangle rect = new Rectangle(1, 1, 2, 2);

    for (List args in containsPointMatches) {
      expect(rect.containsPoint(new Point(args[0], args[1])), args[2]);
    }
  });

  test('#containsRect', () {
    Rectangle rect = new Rectangle(1, 1, 2, 2);

    expect(rect.containsRectangle(new Rectangle(0, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(1, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(2, 0, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(0, 1, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(1, 1, 2, 2)), isTrue);
    expect(rect.containsRectangle(new Rectangle(2, 1, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(0, 2, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(1, 2, 2, 2)), isFalse);
    expect(rect.containsRectangle(new Rectangle(2, 2, 2, 2)), isFalse);
  });

  test('#equals', () {
    Rectangle rect = rect1234();

    expect(rect.equals(rect1234()), isTrue);
    expect(rect.equals(rect0000()), isFalse);
  });

  group('#intersects', () {
    test('is false when there is no intersection', () {
      testRectangleIntersection(x1: 0, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 1, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 2, y1: 0, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 0, y1: 1, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 2, y1: 1, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 0, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 1, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
      testRectangleIntersection(x1: 2, y1: 2, x2: 1, y2: 1, sideSize: 1, matcher: isFalse);
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
    expect(new Rectangle(0, 0, 0, 0).isEmpty, isTrue);
    expect(new Rectangle(0, 0, 1, 0).isEmpty, isTrue);
    expect(new Rectangle(0, 0, 0, 1).isEmpty, isTrue);
    expect(new Rectangle(0, 0, -1, 5).isEmpty, isTrue);
    expect(new Rectangle(0, 0, 5, -1).isEmpty, isTrue);
    expect(new Rectangle(0, 0, 1, 1).isEmpty, isFalse);
  });

  test('#copyFrom', () {
    Rectangle rect = rect1234();
    Rectangle rect2 = new Rectangle(3, 3, 2, 1);

    rect.copyFrom(rect2);

    testRectangle(rect, x: 3, y: 3, width: 2, height: 1);
  });

  test('#inflate', () {
    Rectangle rect = rect1234();
    rect.inflate(1, 2);

    testRectangle(rect, x: 1, y: 2, width: 4, height: 6);
  });

  test('#inflatePoint', () {
    Rectangle rect = rect1234();
    rect.inflatePoint(new Point(1, 2));

    testRectangle(rect, x: 1, y: 2, width: 4, height: 6);
  });

  test('#offset', () {
    Rectangle rect = rect1234();
    rect.offset(1, 2);

    testRectangle(rect, x: 2, y: 4, width: 3, height: 4);
  });

  test('#offsetPoint', () {
    Rectangle rect = rect1234();
    rect.offsetPoint(new Point(1, 2));

    testRectangle(rect, x: 2, y: 4, width: 3, height: 4);
  });

  test('#setTo', () {
    Rectangle rect = rect1234();
    rect.setTo(4, 3, 2, 1);

    testRectangle(rect, x: 4, y: 3, width: 2, height: 1);
  });

  group('#intersection', () {
    test('return rectangle with negative width/height if there is no intersection', () {
      Rectangle r1 = new Rectangle(0, 0, 2, 2);
      Rectangle r2 = new Rectangle(3, 3, 2, 2);
      Rectangle rect = r1.intersection(r2);

      testRectangle(rect, x: 3, y: 3, width: -1, height: -1);
    });

    test('with rectangles intersecting', () {
      Rectangle r1 = new Rectangle(0, 0, 2, 2);
      Rectangle r2 = new Rectangle(1, 1, 2, 2);
      Rectangle rect = r1.intersection(r2);

      testRectangle(rect, x: 1, y: 1, width: 1, height: 1);
    });
  });

  test('#boundingBox', () {
    Rectangle r1 = new Rectangle(0, 0, 2, 2);
    Rectangle r2 = new Rectangle(1, 1, 2, 2);
    Rectangle rect = r1.boundingBox(r2);

    testRectangle(rect, x: 0, y: 0, width: 3, height: 3);
  });

  test('#align', () {
    Rectangle rect = new Rectangle(0.8, 0.7, 2.5, 2.7);

    testRectangle(rect.align(), x: 0, y: 0, width: 4, height: 4);
  });
}

Rectangle rect1234() => new Rectangle(1, 2, 3, 4);
Rectangle rect0000() => new Rectangle(0, 0, 0, 0);

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

void testRectangleIntersection({num x1: 0, num y1: 0, num x2: 1, num y2: 1, num sideSize: 2, Matcher matcher: isTrue}) {
  Rectangle r1 = new Rectangle(x1, y1, sideSize, sideSize);
  Rectangle r2 = new Rectangle(x2, y2, sideSize, sideSize);

  expect(r1.intersects(r2), matcher);
}
