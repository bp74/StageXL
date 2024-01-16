part of '../resources.dart';

class SpriteSheet {
  int width;
  int height;
  BitmapData source;
  late List<BitmapData> frames;

  SpriteSheet(this.source, this.width, this.height) {
    frames = source.sliceIntoFrames(width, height);
  }

  BitmapData frameAt(int index) => frames[index];
}
