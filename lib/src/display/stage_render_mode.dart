part of stagexl.display;

/// The StageRenderMode defines how often the Stage is renderes by
/// the [RenderLoop] where the Stage is attached to.

class StageRenderMode {

  final int index;
  const StageRenderMode._(this.index);

  static const StageRenderMode AUTO = const StageRenderMode._(0);
  static const StageRenderMode STOP = const StageRenderMode._(1);
  static const StageRenderMode ONCE = const StageRenderMode._(2);
}
