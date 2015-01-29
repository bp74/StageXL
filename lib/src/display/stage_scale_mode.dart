part of stagexl.display;

/// The StageScaleMode defines how the Stage is scaled inside of the Canvas.

class StageScaleMode {

  final int index;
  
  final double scaleX = 1.0;      //It's ugly, but specific scaling of the scene is a must
  final double scaleY = 1.0;
  
  const StageScaleMode(this.index,[double scaleX,double scaleY]) {
      if(?scaleX) { this.scaleX = scaleX; }
      if(?scaleY) { this.scaleY = scaleY; }
  }

  static const StageScaleMode EXACT_FIT = const StageScaleMode._(0);
  static const StageScaleMode NO_BORDER = const StageScaleMode._(1);
  static const StageScaleMode NO_SCALE = const StageScaleMode._(2);
  static const StageScaleMode SHOW_ALL = const StageScaleMode._(3);
}
