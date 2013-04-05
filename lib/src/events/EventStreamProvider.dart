part of stagexl;

class EventStreamProvider<T extends Event>  {
  
  final String _eventType;

  const EventStreamProvider(this._eventType);

  Stream<T> forTarget(EventDispatcher target, {bool useCapture: false}) {
    return target._getEventStream(_eventType, useCapture);
  }

  String get eventType => _eventType;
}



