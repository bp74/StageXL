part of dartflash;

class RenderLoop
{
  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime;

  _EventStreamIndex _enterFrameIndex;
  EnterFrameEvent _enterFrameEvent;

  RenderLoop()
  {
    _juggler = new Juggler();
    _stages = new List<Stage>();
    _renderTime = double.NAN;

    _enterFrameIndex = _EventStreamIndex.enterFrame;
    _enterFrameEvent = new EnterFrameEvent(0);

    html.window.requestAnimationFrame(_onAnimationFrame);
  }

  Juggler get juggler => _juggler;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onAnimationFrame(num currentTime)
  {
    html.window.requestAnimationFrame(_onAnimationFrame);

    if (_renderTime.isNaN)
      _renderTime = currentTime;

    if (_renderTime > currentTime)
      _renderTime = currentTime;

    num deltaTime = currentTime - _renderTime;
    num deltaTimeSec = deltaTime / 1000.0;

    if (deltaTime >= 1) {
      _renderTime = currentTime;
      _enterFrameEvent._passedTime = deltaTimeSec;
      _enterFrameIndex._dispatchEvent(_enterFrameEvent);
      _juggler.advanceTime(deltaTimeSec);

      for(int i = 0; i < _stages.length; i++) {
        var stage = _stages[i];
        stage.materialize();
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addStage(Stage stage)
  {
    _stages.add(stage);
  }
}
