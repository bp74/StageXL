part of '../media.dart';

abstract class SoundChannel extends EventDispatcher {
  EventStream<Event> get onComplete => on<Event>(Event.COMPLETE);

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
    paused = true;
  }

  void resume() {
    paused = false;
  }
}
