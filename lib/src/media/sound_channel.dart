part of stagexl.media;

abstract class SoundChannel extends EventDispatcher {

  EventStream<Event> get onComplete => this.on<Event>(Event.COMPLETE);

  //---------------------------------------------------------------------------

  bool get loop;
  bool get stopped;
  Sound get sound;

  num get position;
  set position(num value);

  bool get paused;
  set paused(bool value);

  SoundTransform get soundTransform;
  set soundTransform(SoundTransform value);

  //---------------------------------------------------------------------------

  void stop();

  void pause() {
    this.paused = true;
  }

  void resume() {
    this.paused = false;
  }

}
