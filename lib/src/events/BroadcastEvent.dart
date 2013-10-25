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
//-------------------------------------------------------------------------------------------------

final List<EventStreamSubscription<EnterFrameEvent>> _enterFrameSubscriptions = [];
final List<EventStreamSubscription<ExitFrameEvent>> _exitFrameSubscriptions = [];
final List<EventStreamSubscription<RenderEvent>> _renderSubscriptions = [];

_dispatchBroadcastEvent(BroadcastEvent broadcastEvent, List<EventStreamSubscription> subscriptions) {

  // Dispatch event to current subscriptions.
  // Do not dispatch events to newly added subscriptions.
  // It is guaranteed that this function is not called recursively.
  // Therefore it is safe to mutate the list.

  var length = subscriptions.length;

  for(int i = 0; i < length; i++) {
    var subscription = subscriptions[i];
    if (subscription.isCanceled == false) {
      broadcastEvent._stopsPropagation = false;
      broadcastEvent._stopsImmediatePropagation = false;
      var target = subscription.eventStream.target;
      subscription._dispatchEventInternal(broadcastEvent, target, EventPhase.AT_TARGET);
    } else {
      subscriptions.removeAt(i);
      length--;
      i--;
    }
  }
}
