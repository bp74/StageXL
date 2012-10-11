part of dartflash;

class EnterFrameEvent extends Event
{
  num _passedTime;

  EnterFrameEvent(num passedTime):super(Event.ENTER_FRAME, false)
  {
    _passedTime = passedTime;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get passedTime => _passedTime;
  bool get captures => false;

}
