part of stagexl;

class SpriteSheet {
  int width;
  int height;
  BitmapData source;
  List<BitmapData> frames;

  SpriteSheet(this.source, this.width, this.height) {
    frames = BitmapData.sliceSpriteSheet(source, width, height);
  }

  BitmapData spriteAt(int index) {
    return frames[index];
  }
}