part of stagexl.display;

/// The StageAlign defines how the content of the Stage is aligned inside
/// of the Canvas. The setting controls where the origin (point 0,0) of the
/// Stage will be placed on the Canvas.

class StageAlign {
  final int index;
  const StageAlign._(this.index);

  static const StageAlign BOTTOM = const StageAlign._(0);
  static const StageAlign BOTTOM_LEFT = const StageAlign._(1);
  static const StageAlign BOTTOM_RIGHT = const StageAlign._(2);
  static const StageAlign LEFT = const StageAlign._(3);
  static const StageAlign RIGHT = const StageAlign._(4);
  static const StageAlign TOP = const StageAlign._(5);
  static const StageAlign TOP_LEFT = const StageAlign._(6);
  static const StageAlign TOP_RIGHT = const StageAlign._(7);
  static const StageAlign NONE = const StageAlign._(8);
}
