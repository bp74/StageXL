part of stagexl.media;

abstract class SoundChannel extends EventDispatcher {

  static const EventStreamProvider<Event> completeEvent =
      const EventStreamProvider<Event>(Event.COMPLETE);

  EventStream<Event> get onComplete =>
      SoundChannel.completeEvent.forTarget(this);

  //---------------------------------------------------------------------------

  bool get loop;
  bool get stopped;
  num get position;
  Sound get sound;

  bool paused;
  SoundTransform soundTransform;

  //---------------------------------------------------------------------------

  void stop();

  void pause() {
    this.paused = true;
  }

  void resume() {
    this.paused = false;
  }

}
