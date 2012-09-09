abstract class SoundChannel extends EventDispatcher
{
  abstract SoundTransform get soundTransform();

  abstract void set soundTransform(SoundTransform value);   
  
  abstract void stop();
}
