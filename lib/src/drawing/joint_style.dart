part of stagexl.drawing;

/// The JointStyle class is an enumeration of constant values that specify the
/// joint style to use in drawing lines.
///
/// These constants are provided for use as values in the joints parameter of
/// the [Graphics.lineStyle] method. The method supports three types of joints:
/// miter, round, and bevel.

class JointStyle {
  static const String MITER = "miter";
  static const String ROUND = "round";
  static const String BEVEL = "bevel";
}
