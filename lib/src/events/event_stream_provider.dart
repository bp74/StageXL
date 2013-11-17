part of stagexl;

class EventStreamProvider<T extends Event>  {

  final String eventType;
  const EventStreamProvider(this.eventType);

  EventStream<T> forTarget(EventDispatcher target) => target.on(eventType);
}
