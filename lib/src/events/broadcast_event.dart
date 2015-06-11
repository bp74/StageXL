part of stagexl.events;

// TODO: We should make BroadcastEvents more generic.

/// An event that has no specific [DisplayObject] as target but rather all
/// [DisplayObject] instances, including those that are not on the display list.
///
/// This means that you can add a listener to any [DisplayObject] instance to
/// listen for [BroadcastEvent]s. Those events are always fired at the target
/// and there is no bubbling and capturing phase.

abstract class BroadcastEvent extends Event {
  BroadcastEvent(String type) : super(type, false);
  bool get captures => false;
  void dispatch();
}

/// An event that is dispatched when a new frame is entered.
///
/// This event is a [BroadcastEvent], which means that it is dispatched by all
/// [DisplayObject]s with a listener registered for this event.
class EnterFrameEvent extends BroadcastEvent {
  num passedTime;
  EnterFrameEvent(this.passedTime) : super(Event.ENTER_FRAME);
  void dispatch() => _dispatchBroadcastEvent(this, _enterFrameSubscriptions);
}

/// An event that is dispatched when the current frame is exited.
///
/// This event is a [BroadcastEvent], which means that it is dispatched
/// by all [DisplayObject]s with a listener registered for this event.
class ExitFrameEvent extends BroadcastEvent {
  ExitFrameEvent() : super(Event.EXIT_FRAME);
  void dispatch() => _dispatchBroadcastEvent(this, _exitFrameSubscriptions);
}

/// An event that is dispatched when the display list is about to be updated
/// and rendered.
///
/// This event provides the last opportunity for
/// objects listening for this event to make changes before the display list is
/// rendered. You must call the invalidate() method of the [Stage] object each
/// time you want a [RenderEvent] to be dispatched.
///
/// This event is a [BroadcastEvent], which means that it is dispatched
/// by all [DisplayObject]s with a listener registered for this event.
class RenderEvent extends BroadcastEvent {
  RenderEvent() : super(Event.RENDER);
  void dispatch() => _dispatchBroadcastEvent(this, _renderSubscriptions);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

final List<EventStreamSubscription> _enterFrameSubscriptions = [];
final List<EventStreamSubscription> _exitFrameSubscriptions = [];
final List<EventStreamSubscription> _renderSubscriptions = [];

_dispatchBroadcastEvent(BroadcastEvent broadcastEvent,
    List<EventStreamSubscription> subscriptions) {

  // Dispatch event to current subscriptions.
  // Do not dispatch events to newly added subscriptions.
  // It is guaranteed that this function is not called recursively.
  // Therefore it is safe to mutate the list.

  var length = subscriptions.length;

  for (int i = 0; i < length; i++) {
    var subscription = subscriptions[i];
    if (subscription.isCanceled == false) {
      broadcastEvent._isPropagationStopped = false;
      broadcastEvent._isImmediatePropagationStopped = false;
      broadcastEvent._target = subscription.eventStream.target;
      broadcastEvent._currentTarget = subscription.eventStream.target;
      broadcastEvent._eventPhase = EventPhase.AT_TARGET;
      subscription.eventListener(broadcastEvent);
    } else {
      subscriptions.removeAt(i);
      length--;
      i--;
    }
  }
}
