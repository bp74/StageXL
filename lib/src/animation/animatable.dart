part of stagexl;

/// This is the base class for all derived classes which can
/// be added to the Juggler.
abstract class Animatable {

  /// This method is called by the Juggler with the
  /// delta time since the last call.
  bool advanceTime(num time);
}
