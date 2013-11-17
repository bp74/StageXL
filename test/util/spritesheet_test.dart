library spritesheet_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';
import 'dart:async';

void main() {
  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('spiders', '/StageXL/test/assets/spider.png');
  var spiders, spritesheet;

  setUp(() {
    return resourceManager.load().then((_) {
      spiders = resourceManager.getBitmapData('spiders');
      spritesheet = new SpriteSheet(spiders, 32, 32);
    });
  });

  test('SpriteSheet assigns source BitmapData', () {
    expect(spritesheet.source, equals(spiders));
  });

  test('SpriteSheet.frames is the expected size', () {
    expect(spritesheet.frames.length, equals(28));
  });

  // TODO: I tested the below "manually" because Dart's testing
  // sucks ATM.

  // Not going to bother testing whether spritesheet.frames has the
  // correct contents or not, or if its at least called
  // BitmapData.sliceSpriteSheet with the correct parameters.
  // Testing these basic things in Dart is highly
  // unpleasant at the moment. Maybe in the future.
  // There's no "pending" concept, either...
  test('SpriteSheet.frames calls BitmapData.sliceSpriteSheet correctly', () {});
  test('SpriteSheet.frameAt uses SpriteSheet.frames', () {});
}