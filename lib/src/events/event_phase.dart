part of stagexl.events;

class EventPhase {

  final int phase;
  final String name;

  const EventPhase(this.phase, this.name);

  static const EventPhase CAPTURING_PHASE = const EventPhase(1, "CAPTURING_PHASE");
  static const EventPhase AT_TARGET = const EventPhase(2, "AT_TARGET");
  static const EventPhase BUBBLING_PHASE = const EventPhase(3, "BUBBLING_PHASE");
}

