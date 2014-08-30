part of stagexl.events;

class EventPhase {

  final int phase;
  final String name;

  const EventPhase._(this.phase, this.name);

  static const EventPhase CAPTURING_PHASE = const EventPhase._(1, "CAPTURING_PHASE");
  static const EventPhase AT_TARGET = const EventPhase._(2, "AT_TARGET");
  static const EventPhase BUBBLING_PHASE = const EventPhase._(3, "BUBBLING_PHASE");
}

