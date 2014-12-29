part of stagexl.display;

/// The StageScaleMode defines how the Stage is scaled inside of the Canvas.

class StageScaleMode {

  final int index;
  const StageScaleMode._(this.index);

  static const StageScaleMode EXACT_FIT = const StageScaleMode._(0);
  static const StageScaleMode NO_BORDER = const StageScaleMode._(1);
  static const StageScaleMode NO_SCALE = const StageScaleMode._(2);
  static const StageScaleMode SHOW_ALL = const StageScaleMode._(3);
}
