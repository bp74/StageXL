part of stagexl.events;

/// Provides constant values for the eventPhase property of the [Event] class.

enum EventPhase {

  /// The capturing phase, which is the first phase of the event flow.
  CAPTURING_PHASE,

  /// The target phase, which is the second phase of the event flow.
  AT_TARGET,

  /// The bubbling phase, which is the third phase of the event flow.
  BUBBLING_PHASE
}
