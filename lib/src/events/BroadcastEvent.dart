part of stagexl;

class BroadcastEvent extends Event {
  BroadcastEvent(String type):super(type, false);
  bool get captures => false;
}

class EnterFrameEvent extends BroadcastEvent {
  num _passedTime;

  EnterFrameEvent(num passedTime):super(Event.ENTER_FRAME) {
    _passedTime = passedTime;
  }

  num get passedTime => _passedTime;
}

class ExitFrameEvent extends BroadcastEvent {
  ExitFrameEvent():super(Event.EXIT_FRAME);
}

class RenderEvent extends BroadcastEvent {
  RenderEvent():super(Event.RENDER);
}