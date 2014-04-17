part of stagexl;

class SpriteSheet {
  int width;
  int height;
  BitmapData source;
  List<BitmapData> frames;

  SpriteSheet(this.source, this.width, this.height) {
    frames = source.sliceIntoFrames(width, height);
  }

  BitmapData frameAt(int index) {
    return frames[index];
  }
}
