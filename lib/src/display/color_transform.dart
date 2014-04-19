part of stagexl;

class ColorTransform {

  num redMultiplier;
  num greenMultiplier;
  num blueMultiplier;
  num alphaMultiplier;

  int redOffset;
  int greenOffset;
  int blueOffset;
  int alphaOffset;

  ColorTransform([
    this.redMultiplier = 1.0, this.greenMultiplier = 1.0, this.blueMultiplier = 1.0, this.alphaMultiplier = 1.0,
    this.redOffset = 0, this.greenOffset = 0, this.blueOffset = 0, this.alphaOffset = 0]);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get color => (redOffset << 16) + (greenOffset << 8) + (blueOffset << 0);

  void set color(int value) {

    value = _ensureInt(value);

    redOffset =   (value & 0x00FF0000) >> 16;
    greenOffset = (value & 0x0000FF00) >> 8;
    blueOffset =  (value & 0x000000FF);

    redMultiplier = 0.0;
    greenMultiplier = 0.0;
    blueMultiplier = 0.0;
  }

  //-------------------------------------------------------------------------------------------------

  void concat(ColorTransform second) {

    // ToDo
    throw new UnimplementedError("Error #2014: Feature is not available at this time.");
  }

}
