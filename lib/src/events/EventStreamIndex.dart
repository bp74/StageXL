part of stagexl;

class _EventStreamIndex<T extends Event> {

  final List<_EventStream> _eventStreams = new List<_EventStream>();
  int _eventStreamsCount = 0;

  static _EventStreamIndex<EnterFrameEvent> enterFrame = new _EventStreamIndex<EnterFrameEvent>();
  static _EventStreamIndex<ExitFrameEvent> exitFrame = new _EventStreamIndex<ExitFrameEvent>();
  static _EventStreamIndex<RenderEvent> render = new _EventStreamIndex<RenderEvent>();

  //-----------------------------------------------------------------------------------------------

  void _addEventStream(_EventStream eventStream) {

    for(int i = 0; i < _eventStreamsCount; i++) {
      if (_eventStreams[i] == eventStream) return;
    }

    if (_eventStreamsCount == _eventStreams.length) {
      _eventStreams.add(eventStream);
    } else {
      _eventStreams[_eventStreamsCount] = eventStream;
    }

    _eventStreamsCount++;
  }

  //-----------------------------------------------------------------------------------------------

  void _dispatchEvent(Event event) {

    event._eventPhase = EventPhase.AT_TARGET;
    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;

    // Dispatch event to current event streams.
    // Do not dispatch events to newly added streams.
    // Adjust _eventStreams List.

    int eventStreamsCount = _eventStreamsCount;
    int tail = 0;

    if (eventStreamsCount is! int) throw "dart2js_hint";

    for(int head = 0; head < eventStreamsCount; head++) {

      var eventStream = _eventStreams[head];
      if (eventStream == null) continue;

      if (eventStream._subscriptionsCount == 0) {
        _eventStreams[head] = null;
        continue;
      }

      event._target = eventStream._target;
      event._currentTarget = eventStream._target;
      eventStream._dispatchEvent(event);

      if (tail != head) {
        _eventStreams[tail] = _eventStreams[head];
        _eventStreams[head] = null;
      }

      tail++;
    }

    if (tail != eventStreamsCount) {

      for(int head = eventStreamsCount; head < _eventStreamsCount; head++) {
        _eventStreams[tail++] = _eventStreams[head];
        _eventStreams[head] = null;
      }

      _eventStreamsCount = tail;
    }
  }

}


