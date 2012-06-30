class ExitBox extends Sprite
{
  TimeGauge _timeGauge;
  SimpleButton _yesButton;
  SimpleButton _noButton;

  Function _doneFunction;

  ExitBox()
  {
    Bitmap background = new Bitmap(Grafix.resource.getBitmapData("ExitBox"));
    addChild(background);

    TextFormat textFormat = new TextFormat("Arial", 24, 0xFFFFFF, true);
    textFormat.align = TextFormatAlign.CENTER;

    TextField textField = new TextField();
    textField.defaultTextFormat = textFormat;
    textField.width = 240;
    textField.height = 100;
    textField.wordWrap = true;
    //textField.selectable = false;
    textField.text = Texts.resource.getText("GENexitquery");
    textField.x = 47;
    textField.y = 150 - textField.textHeight/2;
    //textField.filters = [new GlowFilter(0x000000, 0.7, 3, 3)];    // ToDo
    textField.mouseEnabled = false;

    addChild(textField);

    //---------------------

    _timeGauge = new TimeGauge(7, Grafix.resource.getBitmapData("ExitGauge"), Gauge.DIRECTION_DOWN);
    _timeGauge.x = 268;
    _timeGauge.y = 25;
    _timeGauge.addEventListener("TimeOver", _onTimeOver);
    addChild(_timeGauge);

    _timeGauge.addAlarm("TimeOver", 0);
    _timeGauge.start();

    Bitmap exitYesButtonNormal = new Bitmap(Grafix.resource.getBitmapData("ExitYesButtonNormal"));
    Bitmap exitYesButtonPressed = new Bitmap(Grafix.resource.getBitmapData("ExitYesButtonPressed"));

    _yesButton = new SimpleButton(exitYesButtonNormal, exitYesButtonNormal, exitYesButtonPressed, exitYesButtonPressed);
    _yesButton.x = 68;
    _yesButton.y = 239;
    _yesButton.addEventListener(MouseEvent.CLICK, _onYesButtonClicked);
    addChild(_yesButton);

    Bitmap exitNoButtonNormal = new Bitmap(Grafix.resource.getBitmapData("ExitNoButtonNormal"));
    Bitmap exitNoButtonPressed = new Bitmap(Grafix.resource.getBitmapData("ExitNoButtonPressed"));

    _noButton = new SimpleButton(exitNoButtonNormal, exitNoButtonNormal, exitNoButtonPressed, exitNoButtonPressed);
    _noButton.x = 173;
    _noButton.y = 232;
    _noButton.addEventListener(MouseEvent.CLICK, _onNoButtonClicked);

    addChild(_noButton);

    //---------------------

    this.addEventListener(Event.ADDED_TO_STAGE, (e) => Juggler.instance.add(_timeGauge));
    this.addEventListener(Event.REMOVED_FROM_STAGE, (e) => Juggler.instance.remove(_timeGauge));
  }

  //-----------------------------------------------------------------------------------

  void _onExit(bool exit)
  {
    if (_doneFunction != null)
    {
      _doneFunction(exit);
      _doneFunction = null;
    }
  }

  //-----------------------------------------------------------------------------------

  void _onYesButtonClicked(MouseEvent me)
  {
    _onExit(true);
  }

  void _onNoButtonClicked(MouseEvent me)
  {
    _onExit(false);
  }

  void _onTimeOver(Event e)
  {
    _onExit(false);
  }

  //-----------------------------------------------------------------------------------

  show(Function doneFunction)
  {
    _doneFunction = doneFunction;
  }

}