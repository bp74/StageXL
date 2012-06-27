class RenderLoop
{
  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime = double.NAN;

  RenderLoop()
  {
    _juggler = Juggler.instance;
    _stages = new List<Stage>();

    _requestAnimationFrame();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _requestAnimationFrame()
  {
    try
    {
      html.window.requestAnimationFrame(_onAnimationFrame);
    }
    catch(Exception ex)
    {
      html.window.setTimeout(function() { _onAnimationFrame(null); }, 16);
    }
  }

  //-------------------------------------------------------------------------------------------------

  bool _onAnimationFrame(num currentTime)
  {
    _requestAnimationFrame();

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
