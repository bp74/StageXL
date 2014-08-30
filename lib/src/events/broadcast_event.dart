part of stagexl.events;

// TODO: We should make BroadcastEvents more generic.

abstract class BroadcastEvent extends Event {
  BroadcastEvent(String type) : super(type, false);
  bool get captures => false;
  void dispatch();
}

class EnterFrameEvent extends BroadcastEvent {
  num passedTime;
  EnterFrameEvent(this.passedTime) : super(Event.ENTER_FRAME);
  void dispatch() => _dispatchBroadcastEvent(this, _enterFrameSubscriptions);
}

class ExitFrameEvent extends BroadcastEvent {
  ExitFrameEvent() : super(Event.EXIT_FRAME);
  void dispatch() => _dispatchBroadcastEvent(this, _exitFrameSubscriptions);
}

class RenderEvent extends BroadcastEvent {
  RenderEvent() : super(Event.RENDER);
  void dispatch() => _dispatchBroadcastEvent(this, _renderSubscriptions);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

final List<EventStreamSubscription> _enterFrameSubscriptions = [];
final List<EventStreamSubscription> _exitFrameSubscriptions = [];
final List<EventStreamSubscription> _renderSubscriptions = [];

_dispatchBroadcastEvent(BroadcastEvent broadcastEvent, List<EventStreamSubscription> subscriptions) {

  // Dispatch event to current subscriptions.
  // Do not dispatch events to newly added subscriptions.
  // It is guaranteed that this function is not called recursively.
  // Therefore it is safe to mutate the list.

  var length = subscriptions.length;

  for (int i = 0; i < length; i++) {
    var subscription = subscriptions[i];
    if (subscription.isCanceled == false) {
      broadcastEvent._stopsPropagation = false;
      broadcastEvent._stopsImmediatePropagation = false;
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
