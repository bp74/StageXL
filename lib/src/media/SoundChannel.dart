part of dartflash;

abstract class SoundChannel extends EventDispatcher
{
  SoundTransform get soundTransform;
  void set soundTransform(SoundTransform value);
  void stop();
}
