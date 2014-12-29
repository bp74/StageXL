part of stagexl.events;

/// A factory to expose [Event]s as streams.
class EventStreamProvider<T extends Event> {

  final String eventType;

  const EventStreamProvider(this.eventType);

  /// Gets an [EventStream] for this event type, on the specified [target].

  EventStream<T> forTarget(EventDispatcher target) => target.on(eventType);
}
