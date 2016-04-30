part of stagexl.display;

class ColorTransform {

  final Float32List multipliers = new Float32List(4);
  final Int32List offsets = new Int32List(4);

  ColorTransform([
      num redMultiplier = 1.0,
      num greenMultiplier = 1.0,
      num blueMultiplier = 1.0,
      num alphaMultiplier = 1.0,
      int redOffset = 0,
      int greenOffset = 0,
      int blueOffset = 0,
      int alphaOffset = 0]) {

    this.redMultiplier = redMultiplier.toDouble();
    this.greenMultiplier = greenMultiplier.toDouble();
    this.blueMultiplier = blueMultiplier.toDouble();
    this.alphaMultiplier = alphaMultiplier.toDouble();
    this.redOffset = redOffset;
    this.greenOffset = greenOffset;
    this.blueOffset = blueOffset;
    this.alphaOffset = alphaOffset;
  }

  //---------------------------------------------------------------------------

  num get redMultiplier => multipliers[0];

  set redMultiplier(num value) {
    multipliers[0] = value.toDouble();
  }

  num get greenMultiplier => multipliers[1];

  set greenMultiplier(num value) {
    multipliers[1] = value.toDouble();
  }

  num get blueMultiplier => multipliers[2];

  set blueMultiplier(num value) {
    multipliers[2] = value.toDouble();
  }

  num get alphaMultiplier => multipliers[3];

  set alphaMultiplier(num value) {
    multipliers[3] = value.toDouble();
  }

  int get redOffset => offsets[0];

  set redOffset(int value) {
    offsets[0] = value;
  }

  int get greenOffset => offsets[1];

  set greenOffset(int value) {
    offsets[1] = value;
  }

  int get blueOffset => offsets[2];

  set blueOffset(int value) {
    offsets[2] = value;
  }

  int get alphaOffset => offsets[3];

  set alphaOffset(int value) {
    offsets[3] = value;
  }

  //---------------------------------------------------------------------------

  int get color => (redOffset << 16) + (greenOffset << 8) + (blueOffset << 0);

  set color(int value) {

    value = ensureInt(value);

    redOffset = (value & 0x00FF0000) >> 16;
    greenOffset = (value & 0x0000FF00) >> 8;
    blueOffset = (value & 0x000000FF);

    redMultiplier = 0.0;
    greenMultiplier = 0.0;
    blueMultiplier = 0.0;
  }

  //---------------------------------------------------------------------------

  void reset() {

    multipliers[0] = 1.0;
    multipliers[1] = 1.0;
    multipliers[2] = 1.0;
    multipliers[3] = 1.0;

    offsets[0] = 0;
    offsets[1] = 0;
    offsets[2] = 0;
    offsets[3] = 0;
  }

  //---------------------------------------------------------------------------

  void copyFrom(ColorTransform other) {

    multipliers[0] = other.multipliers[0];
    multipliers[1] = other.multipliers[1];
    multipliers[2] = other.multipliers[2];
    multipliers[3] = other.multipliers[3];

    offsets[0] = other.offsets[0];
    offsets[1] = other.offsets[1];
    offsets[2] = other.offsets[2];
    offsets[3] = other.offsets[3];
  }

  //---------------------------------------------------------------------------

  void concat(ColorTransform second) {

    multipliers[0] = multipliers[0] * second.multipliers[0];
    multipliers[1] = multipliers[1] * second.multipliers[1];
    multipliers[2] = multipliers[2] * second.multipliers[2];
    multipliers[3] = multipliers[3] * second.multipliers[3];

    offsets[0] = offsets[0] + second.offsets[0];
    offsets[1] = offsets[1] + second.offsets[1];
    offsets[2] = offsets[2] + second.offsets[2];
    offsets[3] = offsets[3] + second.offsets[3];
  }

  //---------------------------------------------------------------------------

  void interpolate(ColorTransform c1, ColorTransform c2, double value) {

    var c1m = c1.multipliers;
    var c2m = c2.multipliers;
    var c1o = c1.offsets;
    var c2o = c2.offsets;

    multipliers[0] = c1m[0] + (c2m[0] - c1m[0]) * value;
    multipliers[1] = c1m[1] + (c2m[1] - c1m[1]) * value;
    multipliers[2] = c1m[2] + (c2m[2] - c1m[2]) * value;
    multipliers[3] = c1m[3] + (c2m[3] - c1m[3]) * value;

    offsets[0] = c1o[0] + ((c2o[0] - c1o[0]) * value).toInt();
    offsets[1] = c1o[1] + ((c2o[1] - c1o[1]) * value).toInt();
    offsets[2] = c1o[2] + ((c2o[2] - c1o[2]) * value).toInt();
    offsets[3] = c1o[3] + ((c2o[3] - c1o[3]) * value).toInt();
  }

}
