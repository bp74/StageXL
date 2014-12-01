part of stagexl.events;

/// Provides constant values for the eventPhase property of the [Event] class.
class EventPhase {

  final int _ordinal;
  const EventPhase._(this._ordinal);

  static const EventPhase CAPTURING_PHASE = const EventPhase._(0);
  static const EventPhase AT_TARGET = const EventPhase._(1);
  static const EventPhase BUBBLING_PHASE = const EventPhase._(2);
}
