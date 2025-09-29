part of '../events.dart';

/// Provides a stream of [Event]s.
class EventStream<T extends Event> extends Stream<T> {
  /// The event target.
  final EventDispatcher target;

  /// The event type of this stream.
  final String eventType;

  // We store the subscriptions in a immutable fixed length list.
  // If subscriptions are added or canceled we create a new list.
  // This is safe and gives good performance in JavaScript.

  List<EventStreamSubscription<T>?> _subscriptions = [];
  int _capturingSubscriptionCount = 0;

  EventStream._(this.target, this.eventType);

  //----------------------------------------------------------------------------

  @override
  bool get isBroadcast => true;

  @override
  Stream<T> asBroadcastStream(
          {void Function(StreamSubscription<T> subscription)? onListen,
          void Function(StreamSubscription<T> subscription)? onCancel}) =>
      this;

  bool get hasSubscriptions => _subscriptions.isNotEmpty;
  bool get hasCapturingSubscriptions => _capturingSubscriptionCount > 0;
  bool get hasBubblingSubscriptions =>
      _subscriptions.length > _capturingSubscriptionCount;

  //----------------------------------------------------------------------------

  /// Adds a subscription to this stream that processes the event during the
  /// target or bubbling phase.
  ///
  /// In contrast, the [capture] method processes the event during the capture
  /// phase.
  ///
  /// On each data event from this stream, the subscriber's [onData] handler
  /// is called.
  ///
  /// The [priority] level of the event listener can be specified. The higher
  /// the number, the higher the priority. All listeners with priority n are
  /// processed before listeners of priority n-1. If two or more listeners share
  /// the same priority, they are processed in the order in which they were
  /// added. The default priority is 0.
  ///
  /// Note: The [onError] and [onDone] handlers and [cancelOnError] are not used
  /// as the stream has no errors and is never done.

  @override
  EventStreamSubscription<T> listen(void Function(T event)? onData,
          {Function? onError,
          void Function()? onDone,
          bool? cancelOnError = false,
          int priority = 0}) =>
      _subscribe(onData, false, priority);

  //----------------------------------------------------------------------------

  /// Adds a subscription to this stream that processes the event during the
  /// capture phase.
  ///
  /// In contrast, the [listen] method processes the event during the target or
  /// bubbling phase.
  ///
  /// On each data event from this stream, the subscriber's [onData] handler
  /// is called.
  ///
  /// The [priority] level of the event listener can be specified. The higher
  /// the number, the higher the priority. All listeners with priority n are
  /// processed before listeners of priority n-1. If two or more listeners share
  /// the same priority, they are processed in the order in which they were
  /// added. The default priority is 0.

  EventStreamSubscription<T> capture(void Function(T event) onData,
          {int priority = 0}) =>
      _subscribe(onData, true, priority);

  //----------------------------------------------------------------------------

  /// Cancels all subscriptions to this stream.

  void cancelSubscriptions() {
    final subscriptions = _subscriptions;

    for (var i = 0; i < subscriptions.length; i++) {
      if (subscriptions[i] != null) {
        _cancelSubscription(subscriptions[i]!);
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  EventStreamSubscription<T> _subscribe(
      EventListener<T>? eventListener, bool captures, int priority) {
    final subscription =
        EventStreamSubscription<T>._(this, eventListener, captures, priority);

    // Insert the subscription according to its priority.

    final oldSubscriptions = _subscriptions;
    final newSubscriptions = List<EventStreamSubscription<T>?>.filled(
        oldSubscriptions.length + 1, null);
    var index = newSubscriptions.length - 1;

    for (var o = 0, n = 0; o < oldSubscriptions.length; o++) {
      final oldSubscription = oldSubscriptions[o];
      if (o == n && oldSubscription!.priority < priority) index = n++;
      newSubscriptions[n++] = oldSubscription;
    }

    newSubscriptions[index] = subscription;
    _subscriptions = newSubscriptions;

    // Increment the capturing subscription counter
    // or optimization for broadcast events.

    if (captures) {
      _capturingSubscriptionCount += 1;
    } else if (subscription is EventStreamSubscription<EnterFrameEvent>) {
      _enterFrameSubscriptions
          .add(subscription as EventStreamSubscription<EnterFrameEvent>);
    } else if (subscription is EventStreamSubscription<ExitFrameEvent>) {
      _exitFrameSubscriptions
          .add(subscription as EventStreamSubscription<ExitFrameEvent>);
    } else if (subscription is EventStreamSubscription<RenderEvent>) {
      _renderSubscriptions
          .add(subscription as EventStreamSubscription<RenderEvent>);
    }

    return subscription;
  }

  //----------------------------------------------------------------------------

  void _unsubscribe(EventListener<T> eventListener, bool captures) {
    final subscriptions = _subscriptions;

    for (var i = 0; i < subscriptions.length; i++) {
      if (subscriptions[i] != null) {
        final subscription = subscriptions[i]!;
        if (subscription.eventListener == eventListener &&
            subscription.isCapturing == captures) {
          _cancelSubscription(subscription);
        }
      }
    }
  }

  //----------------------------------------------------------------------------

  void _cancelSubscription(EventStreamSubscription eventStreamSubscription) {
    eventStreamSubscription._canceled = true;

    final oldSubscriptions = _subscriptions;
    if (oldSubscriptions.isEmpty) return;

    final newSubscriptions = List<EventStreamSubscription<T>?>.filled(
        oldSubscriptions.length - 1, null);

    for (var o = 0, n = 0; o < oldSubscriptions.length; o++) {
      final oldSubscription = oldSubscriptions[o];
      if (identical(oldSubscription, eventStreamSubscription)) continue;
      if (n >= newSubscriptions.length) return;
      newSubscriptions[n++] = oldSubscription;
    }

    if (eventStreamSubscription.isCapturing) {
      _capturingSubscriptionCount -= 1;
    }

    _subscriptions = newSubscriptions;
  }

  //----------------------------------------------------------------------------

  void _dispatchEventInternal(
      T event, EventDispatcher target, EventPhase eventPhase) {
    final subscriptions = _subscriptions;
    final isCapturing = eventPhase == EventPhase.CAPTURING_PHASE;

    for (var i = 0; i < subscriptions.length; i++) {
      final subscription = subscriptions[i];
      if (subscription == null) continue;

      if (subscription.isCanceled == true ||
          subscription.isPaused == true ||
          subscription.isCapturing != isCapturing) {
        continue;
      }

      event._target = target;
      event._currentTarget = this.target;
      event._eventPhase = eventPhase;

      InputEvent.current = event is InputEvent ? event : null;

      if (subscription.eventListener != null) {
        subscription.eventListener!(event);
      }
      InputEvent.current = null;

      if (event.isImmediatePropagationStopped) return;
    }
  }
}
