class RenderLoop
{
  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime = double.NAN;

  RenderLoop()
  {
    _juggler = Juggler.instance;
    _stages = new List<Stage>();

    html.window.requestAnimationFrame(_onAnimationFrame);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool _onAnimationFrame(num currentTime)
  {
    html.window.requestAnimationFrame(_onAnimationFrame);

    if (currentTime == null)
      currentTime = new Date.now().millisecondsSinceEpoch;

    if (_renderTime.isNaN())
      _renderTime = currentTime;

    if (_renderTime > currentTime)
      _renderTime = currentTime;

    num deltaTime = currentTime - _renderTime;
    num deltaTimeSec = deltaTime / 1000.0;

    if (deltaTime >= 1)
    {
      _renderTime = currentTime;

      _EventDispatcherCatalog.dispatchEvent(new EnterFrameEvent(deltaTimeSec));
      _juggler.advanceTime(deltaTimeSec);

      for(int i = 0; i < _stages.length; i++)
        _stages[i].materialize();
    }

    return true;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addStage(Stage stage)
  {
    _stages.add(stage);
  }
}
