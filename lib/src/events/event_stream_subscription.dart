part of stagexl;

typedef void EventListener<T extends Event>(T event);

class EventStreamSubscription<T extends Event> extends StreamSubscription<T> {

  int _priority = 0;
  int _pauseCount = 0;
  bool _canceled = false;
  bool _captures = false;

  EventStream<T> _eventStream;
  EventListener<T> _eventListener;

  EventStreamSubscription._internal(
      this._eventStream, this._eventListener, this._captures, this._priority);

  //-----------------------------------------------------------------------------------------------

  int get priority => _priority;

  bool get isPaused => _pauseCount > 0;
  bool get isCanceled => _canceled;
  bool get isCapturing => _captures;

  EventStream<T> get eventStream => _eventStream;
  EventListener<T> get eventListener => _eventListener;

  //-----------------------------------------------------------------------------------------------

  void onData(void handleData(T event)) {
    _eventListener = handleData;
  }

  void onError(void handleError(error)) {
    // This stream has no errors.
  }

  void onDone(void handleDone()) {
    // This stream is never done.
  }

  //-----------------------------------------------------------------------------------------------

  Future asFuture([var futureValue]) {
    // This stream is never done and has no errors.
    return new Completer().future;
  }

  //-----------------------------------------------------------------------------------------------

  Future cancel() {
    if (_canceled == false) {
      _eventStream._cancelSubscription(this);
    }
    return null;
  }

  void pause([Future resumeSignal]) {
    _pauseCount++;
    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  void resume()  {
    if (_pauseCount == 0) {
      throw new StateError("Subscription is not paused.");
    }
    _pauseCount--;
  }

}

