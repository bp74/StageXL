class SoundChannel extends EventDispatcher
{
  //abstract SoundChannel();

  //-------------------------------------------------------------------------------------------------

  abstract SoundTransform get soundTransform();
  abstract void set soundTransform(SoundTransform value);   
 
  //-------------------------------------------------------------------------------------------------
   
  abstract void stop();
}
