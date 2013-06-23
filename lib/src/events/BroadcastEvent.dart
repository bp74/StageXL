part of stagexl;

class BroadcastEvent extends Event {
  BroadcastEvent(String type):super(type, false);
  bool get captures => false;
}

class EnterFrameEvent extends BroadcastEvent {
  num _passedTime;
  num get passedTime => _passedTime;
  EnterFrameEvent(num passedTime):super(Event.ENTER_FRAME), _passedTime = passedTime;
}

class ExitFrameEvent extends BroadcastEvent {
  ExitFrameEvent():super(Event.EXIT_FRAME);
}

class RenderEvent extends BroadcastEvent {
  RenderEvent():super(Event.RENDER);
}

//-------------------------------------------------------------------------------------------------

final _BroadcastEventIndex<EnterFrameEvent> _enterFrameEventIndex = new _BroadcastEventIndex<EnterFrameEvent>();
final _BroadcastEventIndex<ExitFrameEvent> _exitFrameEventIndex = new _BroadcastEventIndex<ExitFrameEvent>();
final _BroadcastEventIndex<RenderEvent> _renderEventIndex = new _BroadcastEventIndex<RenderEvent>();

class _BroadcastEventIndex<T extends BroadcastEvent> {

  final List<_EventStream<T>> _eventStreams = [];

  addEventStream(_EventStream<T> eventStream) {
    _eventStreams.add(eventStream);
  }

  dispatchEvent(T event) {

    // Dispatch event to current event streams. Do not dispatch events to
    // newly added streams. It is guaranteed that this function is not
    // called recursively, therefore we can mutate the list.

    var eventStreams = _eventStreams;
    var eventStreamsLength = _eventStreams.length;

    for(int i = 0; i < eventStreamsLength; i++) {
      var eventStream = eventStreams[i];
      if (eventStream._hasSubscriptions) {
        event._target = eventStream._target;
        event._currentTarget = eventStream._target;
        event._eventPhase = EventPhase.AT_TARGET;
        event._stopsPropagation = false;
        event._stopsImmediatePropagation = false;
        eventStream.dispatchEvent(event);
      } else {
        eventStreams.removeAt(i);
        eventStreamsLength--;
        i--;
      }
    }
  }
}