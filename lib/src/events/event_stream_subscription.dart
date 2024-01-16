part of '../events.dart';

/// A handler function that is used to listen to events.

typedef EventListener<T extends Event> = void Function(T event);

/// A subscription on events from an [EventStream].
///
/// The subscription provides events to the listener, and holds the callbacks
/// used to handle the events. The subscription can also be used to unsubscribe
/// from the events, or to temporarily pause the events from the stream.

class EventStreamSubscription<T extends Event>
    implements StreamSubscription<T> {
  final int _priority;
  int _pauseCount = 0;
  bool _canceled = false;
  final bool _captures;

  final EventStream<T> _eventStream;
  EventListener<T>? _eventListener;

  EventStreamSubscription._(
      this._eventStream, this._eventListener, this._captures, this._priority);

  //-----------------------------------------------------------------------------------------------

  int get priority => _priority;

  @override
  bool get isPaused => _pauseCount > 0;

  bool get isCanceled => _canceled;

  bool get isCapturing => _captures;

  EventStream<T> get eventStream => _eventStream;
  EventListener<T>? get eventListener => _eventListener;

  //-----------------------------------------------------------------------------------------------

  @override
  void onData(void Function(T event)? handleData) {
    _eventListener = handleData;
  }

  @override
  void onError(Function? handleError) {
    // This stream has no errors.
  }

  @override
  void onDone(void Function()? handleDone) {
    // This stream is never done.
  }

  //-----------------------------------------------------------------------------------------------

  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;

  //-----------------------------------------------------------------------------------------------

  @override
  Future<void> cancel() async {
    if (_canceled == false) {
      _eventStream._cancelSubscription(this);
      _canceled = true;
    }
  }

  @override
  void pause([Future<void>? resumeSignal]) {
    _pauseCount++;
    resumeSignal?.whenComplete(resume);
  }

  @override
  void resume() {
    if (_pauseCount == 0) {
      throw StateError('Subscription is not paused.');
    }
    _pauseCount--;
  }
}
