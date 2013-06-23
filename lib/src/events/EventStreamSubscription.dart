part of stagexl;

typedef void _EventListener<T extends Event>(T event);

class _EventStreamSubscription<T extends Event> extends StreamSubscription<T> {

  int _pauseCount = 0;
  bool _canceled = false;

  _EventStream<T> _eventStream;
  _EventListener<T> _onData;
  _EventStreamSubscription(this._eventStream, this._onData);

  //-----------------------------------------------------------------------------------------------

  bool get isPaused => _pauseCount > 0;

  //-----------------------------------------------------------------------------------------------

  void onData(void handleData(T event)) {
    _onData = handleData;
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
    var completer = new Completer();
    return completer.future;
  }

  //-----------------------------------------------------------------------------------------------

  void cancel() {
    _eventStream.cancelSubscription(this);
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

