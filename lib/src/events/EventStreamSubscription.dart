part of stagexl;

typedef void _EventListener<T extends Event>(T event);

class _EventStreamSubscription<T extends Event> extends StreamSubscription<T> {

  _EventStream _eventStream;
  _EventListener<T> _onData;
  int _pauseCount;
  bool _canceled;

  _EventStreamSubscription(this._eventStream, this._onData)  {
    _pauseCount = 0;
    _canceled = false;
  }

  //-----------------------------------------------------------------------------------------------

  void cancel() {

    if (_canceled == false) {
      _eventStream._onSubscriptionCancel(this);
      _canceled = true;
      _onData = null;
    }
  }

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

  bool get isPaused => _pauseCount > 0;

  void pause([Future resumeSignal]) {

    _pauseCount++;

    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  void resume()  {

    if (isPaused == false) {
      throw new StateError("Subscription is not paused.");
    }

    _pauseCount--;
  }

}

