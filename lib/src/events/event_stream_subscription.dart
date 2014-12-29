part of stagexl.events;

/// A handler function that is used to listen to events.

typedef void EventListener<T extends Event>(T event);

/// A subscription on events from an [EventStream].
///
/// The subscription provides events to the listener, and holds the callbacks
/// used to handle the events. The subscription can also be used to unsubscribe
/// from the events, or to temporarily pause the events from the stream.

class EventStreamSubscription<T extends Event> extends StreamSubscription<T> {

  int _priority = 0;
  int _pauseCount = 0;
  bool _canceled = false;
  bool _captures = false;

  EventStream<T> _eventStream;
  EventListener<T> _eventListener;

  EventStreamSubscription._(
      this._eventStream, this._eventListener, this._captures, this._priority);

  //-----------------------------------------------------------------------------------------------

  int get priority => _priority;

  bool get isPaused => _pauseCount > 0;
  bool get isCanceled => _canceled;
  bool get isCapturing => _captures;

  EventStream<T> get eventStream => _eventStream;
  EventListener<T> get eventListener => _eventListener;

  //-----------------------------------------------------------------------------------------------

  @override
  void onData(void handleData(T event)) {
    _eventListener = handleData;
  }

  @override
  void onError(void handleError(error)) {
    // This stream has no errors.
  }

  @override
  void onDone(void handleDone()) {
    // This stream is never done.
  }

  //-----------------------------------------------------------------------------------------------

  @override
  Future asFuture([var futureValue]) {
    // This stream is never done and has no errors.
    return new Completer().future;
  }

  //-----------------------------------------------------------------------------------------------

  @override
  Future cancel() {
    if (_canceled == false) {
      _eventStream._cancelSubscription(this);
    }
    return null;
  }

  @override
  void pause([Future resumeSignal]) {
    _pauseCount++;
    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  @override
  void resume() {
    if (_pauseCount == 0) {
      throw new StateError("Subscription is not paused.");
    }
    _pauseCount--;
  }

}

