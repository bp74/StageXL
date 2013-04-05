part of stagexl;

abstract class SoundChannel extends EventDispatcher {
  
  SoundTransform get soundTransform;
  void set soundTransform(SoundTransform value);
  void stop();
}
