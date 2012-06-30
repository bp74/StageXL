class Game extends Sprite
{
  InfoBox _infoBox;
  SimpleButton _shuffleButton;
  SimpleButton _exitButton;
  Board _board;
  TimeGauge _timeGauge;
  Head _head;
  Alarm _alarm;
  TextField _pointsTextField;
  TextField _shufflesTextField;

  int _level;
  int _lives;
  int _shuffles;
  int _chainCount;
  int _points;

  Sprite _gameLayer;
  Sprite _messageLayer;
  Sprite _exitLayer;

  Sound _introSound;
  SoundChannel _introSoundChannel;

  //---------------------------------------------------------------------------------------------------

  Game()
  {
    Bitmap shuffleButtonNormal = new Bitmap(Grafix.resource.getBitmapData("ShuffleButtonNormal"));
    Bitmap shuffleButtonPressed = new Bitmap(Grafix.resource.getBitmapData("ShuffleButtonPressed"));

    _shuffleButton = new SimpleButton(shuffleButtonNormal, shuffleButtonNormal, shuffleButtonPressed, shuffleButtonPressed);
    _shuffleButton.addEventListener(MouseEvent.CLICK, _onShuffleButtonClick);
    _shuffleButton.x = 530;
    _shuffleButton.y = 525;
    addChild(_shuffleButton);

    Bitmap exitButtonNormal = new Bitmap(Grafix.resource.getBitmapData("ExitButtonNormal"));
    Bitmap exitButtonPressed = new Bitmap(Grafix.resource.getBitmapData("ExitButtonPressed"));

    _exitButton = new SimpleButton(exitButtonNormal, exitButtonNormal, exitButtonPressed, exitButtonPressed);
    _exitButton.addEventListener(MouseEvent.CLICK, _onExitButtonClick);
    _exitButton.x = 700;
    _exitButton.y = 500;
    addChild(_exitButton);

    _infoBox = new InfoBox();
    _infoBox.x = 540;
    _infoBox.y = -1000;
    addChild(_infoBox);

    _timeGauge = new TimeGauge(10, Grafix.resource.getBitmapData("TimeGauge"), Gauge.DIRECTION_UP);
    _timeGauge.x = 659;
    _timeGauge.y = 244;
    _timeGauge.addEventListener("TimeShort", _onTimeShort);
    _timeGauge.addEventListener("TimeOver", _onTimeOver);
    addChild(_timeGauge);
    Juggler.instance.add(_timeGauge);

    _head = new Head();
    _head.x = 640;
    _head.y = 230;
    addChild(_head);

    _alarm = new Alarm();
    _alarm.x = 665;
    _alarm.y = 160;
    addChild(_alarm);

    //-------------------------------

    _pointsTextField = new TextField();
    _pointsTextField.defaultTextFormat = new TextFormat("Arial", 30, 0xD0D0D0, true, align:TextFormatAlign.CENTER);
    _pointsTextField.width = 140;
    _pointsTextField.height = 36;
    _pointsTextField.wordWrap = false;
    //_pointsTextField.selectable = false;
    _pointsTextField.x = 646;
    _pointsTextField.y = 130;
    //_pointsTextField.filters = [new GlowFilter(0x000000, 1.0, 2, 2)];
    _pointsTextField.mouseEnabled = false;
    _pointsTextField.text = "0";
    _pointsTextField.scaleX = 0.9;
    addChild(_pointsTextField);

    //-------------------------------

    _shufflesTextField = new TextField();
    _shufflesTextField.defaultTextFormat = new TextFormat("Arial", 20, 0xFFFFFF, true, align:TextFormatAlign.CENTER);
    _shufflesTextField.width = 44;
    _shufflesTextField.height = 30;
    _shufflesTextField.wordWrap = false;
    //_shufflesTextField.selectable = false;
    _shufflesTextField.x = 610;
    _shufflesTextField.y = 559;
    _shufflesTextField.mouseEnabled = false;
    _shufflesTextField.text = "3x";
    addChild(_shufflesTextField);

    //-------------------------------

    _gameLayer = new Sprite();
    addChild(_gameLayer);

    _messageLayer = new Sprite();
    addChild(_messageLayer);

    _exitLayer = new Sprite();
    addChild(_exitLayer);

    //-------------------------------

    _introSound = Sounds.resource.getSound("Intro");
    _introSoundChannel = _introSound.play();

  }

  //---------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------

  void start()
  {
    _level = 1;
    _lives = 1;
    _points = 0;
    _shuffles = 3;

    MessageBox messageBox  = new MessageBox(Texts.resource.getText("ESCStartText"));
    _messageLayer.addChild(messageBox);

    Juggler.instance.delayCall(() => _head.nod(21), 1);

    messageBox.show(() => Juggler.instance.delayCall(() => _nextLevel(), 0.5));
  }

  //---------------------------------------------------------------------------------------------------

  void _nextLevel()
  {
    if (_board != null && this.contains(_board))
      _gameLayer.removeChild(_board);

    int level = _level;
    int chainCount = 0;
    num time = 0;

    switch(_level)
    {
      case 01: time = 50; _board = new Board(chainCount = 40, 3, 0, 0, 0, 0, [0,1,2]); break;
      case 02: time = 45; _board = new Board(chainCount = 45, 3, 1, 0, 0, 0, [2,3,4]); break;
      case 03: time = 40; _board = new Board(chainCount = 50, 4, 2, 2, 1, 0, [5,6,7]); break;
      case 04: time = 35; _board = new Board(chainCount = 55, 4, 3, 3, 2, 0, [0,2,6]); break;
      case 05: time = 30; _board = new Board(chainCount = 60, 5, 4, 4, 2, 1, [1,3,5]); break;
      case 06: time = 34; _board = new Board(chainCount = 60, 5, 5, 5, 3, 2, [1,2,4,7]); break;
      case 07: time = 33; _board = new Board(chainCount = 65, 5, 5, 6, 3, 2, [0,1,2,3]); break;
      case 08: time = 32; _board = new Board(chainCount = 70, 5, 5, 6, 3, 2, [0,2,5,6]); break;
      case 09: time = 31; _board = new Board(chainCount = 75, 5, 5, 6, 3, 2, [1,4,5,7]); break;
      default: time = 30; _board = new Board(chainCount = 80 + (_level - 10) * 5, 5, 5, 6, 3, 2, [0,1,2,3]); break;
    }

    _chainCount = chainCount;
    //_logger.info(TextUtil.format("Level: {0}, Time: {1}, Chains: {2}", level, time, chainCount));

    if (_shuffles < 3)
    {
      _shuffles++;
      _shufflesTextField.text = "${_shuffles}x";
    }

    _board.addEventListener(BoardEvent.Explosion, _onBoardEventExplosion);
    _board.addEventListener(BoardEvent.Unlocked, _onBoardEventUnlocked);
    _board.addEventListener(BoardEvent.Finalized, _onBoardEventFinalized);
    _board.addEventListener(BoardEvent.Timeouted, _onBoardEventTimeouted);

    _board.x = 20;
    _board.y = 16;
    _board.mouseEnabled = false;

    _gameLayer.addChild(_board );

    _timeGauge.reset(time);
    _timeGauge.addAlarm("TimeShort", 9);
    _timeGauge.addAlarm("TimeOver", 0);
    _timeGauge.pause();

    _infoBox.level = level;
    _infoBox.chains = chainCount;
    _infoBox.y = -210;

    Tween tween1 = new Tween(_infoBox, 0.4, Transitions.easeOutCubic);
    tween1.animate("y", -90);

    Juggler.instance.add(tween1);

    MessageBox messageBox = new MessageBox(Texts.resource.getText("ESCLevelBoxText").replaceAll("{0}", "$chainCount"));
    _messageLayer.addChild(messageBox);

    messageBox.show(()
    {
      _board.mouseEnabled = true;
      _timeGauge.start();

      if (_introSound != null)
      {
        Tween tween2 = new Tween(null, 4.0, Transitions.linear);

        tween2.animateValue((volume)
        {
          _introSoundChannel.soundTransform.volume = volume;
          _introSoundChannel.soundTransform = _introSoundChannel.soundTransform;
        }, 1.0, 0.0);

        tween2.onComplete = ()
        {
          _introSoundChannel.stop();
          _head.nodStop();
        };

        Juggler.instance.add(tween2);
        _introSound = null;
      }
    });

  }

  //---------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------

  void _onTimeShort(Event e)
  {
    //_logger.info("onTimeShort");
    _alarm.start();
  }

  //---------------------------------------------------------------------------------------------------

  void _onTimeOver(Event e)
  {
    // _logger.info("onTimeOver");
    _board.updateStatus(BoardStatus.Timeouting);
  }

  //---------------------------------------------------------------------------------------------------

  void _onBoardEventUnlocked(BoardEvent be)
  {
    // _logger.info(TextUtil.format("onBoardEventUnlocked ({0})", be.info.type));

    int unlockPoints = 0;
    Point position = be.info["Position"];
    String type = be.info["Type"];

    if (type == "SingleLocked") unlockPoints = 3000;
    if (type == "SingleUnlocked") unlockPoints = 1000;
    if (type == "All") unlockPoints = 10000;

    Bonus bonus = new Bonus(unlockPoints);
    bonus.x = position.x;
    bonus.y = position.y;
    _gameLayer.addChild(bonus);

    _points = _points + unlockPoints;

    _pointsTextField.text = "$_points";
  }

  //---------------------------------------------------------------------------------------------------

  void _onBoardEventExplosion(BoardEvent be)
  {
    //_logger.info("onBoardEventExplosion");

    int chainCount = _chainCount;
    int chainLength = be.info["Length"];
    int chainFactor = be.info["Factor"];

    chainCount = (chainCount > chainLength) ? chainCount - chainLength : 0;

    _chainCount = chainCount;
    _infoBox.chains = chainCount;

    if (chainCount == 0)
      _board.updateStatus(BoardStatus.Finalizing);

    //----------------------------------

    int chainPoints = 0;

    switch(chainLength)
    {
      case 3: chainPoints = 1000; break;
      case 4: chainPoints = 2000; break;
      case 5: chainPoints = 5000; break;
      default: chainPoints = 5000;
    }

    _points = _points + chainPoints * chainFactor;
    _pointsTextField.text = "$_points";
  }

  //---------------------------------------------------------------------------------------------------

  void _onBoardEventFinalized(BoardEvent be)
  {
   //_logger.info("onBoardEventFinalized");

    _timeGauge.pause();
    _alarm.stop();

    Sound laugh = Sounds.resource.getSound("Laugh");
    Sound levelUp = Sounds.resource.getSound("LevelUp");

    laugh.play();
    _head.nod(3);

    Sprite levelUpAnimation = Grafix.getLevelUpAnimation();
    levelUpAnimation.x = 55;
    levelUpAnimation.y = 260;
    _gameLayer.addChild(levelUpAnimation);

    Juggler.instance.delayCall(()
    {
      _board.dropFields();
      levelUp.play();
    }, 2.0);

    Juggler.instance.delayCall(()
    {
      int timePoints = (_timeGauge.restTime * 1000).toInt();
      Bonus timeBonus = new Bonus(timePoints);
      timeBonus.x = 704;
      timeBonus.y = 360;
      _gameLayer.addChild(timeBonus);

      _points = _points + timePoints;
      _pointsTextField.text = "$_points";
    }, 2.5);

    Tween tween = new Tween(_infoBox, 0.5, Transitions.easeOutCubic);
    tween.animate("y", -210);
    tween.delay = 3.0;

    Juggler.instance.add(tween);

    Juggler.instance.delayCall(()
    {
      _gameLayer.removeChild(levelUpAnimation);
    }, 3.5);

    Juggler.instance.delayCall(()
    {
      _level++;
      _nextLevel();
    }, 4.0);
  }

  //---------------------------------------------------------------------------------------------------

  void _onBoardEventTimeouted(BoardEvent be)
  {
    _alarm.stop();
    _board.dropFields();

    MessageBox messageBox;
    Sound sound;

    if (_lives > 0)
    {
      //_logger.info("onBoardEventTimeouted (SecondChance)");

      _lives--;

      messageBox = new MessageBox(Texts.resource.getText("GEN2ndchancetime"));
      _messageLayer.addChild(messageBox);

      sound = Sounds.resource.getSound("LevelUp");
      sound.play();

      messageBox.show(()
      {
        Juggler.instance.delayCall(() => _nextLevel(), 0.5);

        Tween tween = new Tween(_infoBox, 0.5, Transitions.easeOutCubic);
        tween.animate("y", -210);

        Juggler.instance.add(tween);
      });
    }
    else
    {
      // _logger.info("onBoardEventTimeouted (GameOver)");

      messageBox = new MessageBox(Texts.resource.getText("GENtimeup"));
      _messageLayer.addChild(messageBox);

      sound = Sounds.resource.getSound("GameOver");
      sound.play();

      messageBox.show(()
      {
        Juggler.instance.delayCall(() => _gameOver(), 0.5);

        Tween tween = new Tween(_infoBox, 0.5, Transitions.easeOutCubic);
        tween.animate("y", -210);

        Juggler.instance.add(tween);
      });
    }
  }

  //---------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------

  void _onShuffleButtonClick(MouseEvent me)
  {
   //  _logger.info("onShuffleButtonClick");

    if (_board != null && _shuffles > 0)
    {
      bool shuffled = _board.shuffleField();

      if (shuffled)
      {
        //_logger.info("shuffled");

        _shuffles = _shuffles - 1;
        _shufflesTextField.text = "${_shuffles}x";
      }
    }
  }

  void _onExitButtonClick(MouseEvent me)
  {
    //_logger.info("onExitButtonClick");

    Sprite dark = new Sprite();
    dark.addChild(new Bitmap(new BitmapData(800,600, false, 0x000000)));
    dark.alpha = 0.6;

    _exitLayer.addChild(dark);

    ExitBox exitBox = new ExitBox();
    exitBox.x = 235;
    exitBox.y = 150;
    _exitLayer.addChild(exitBox);

    exitBox.show((bool exit)
    {
      _exitLayer.removeChild(exitBox);

      if (exit == false)
        _exitLayer.removeChild(dark);
      else
        _exitGame(false);
    });
  }

  //---------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------

  _gameOver()
  {
    Sprite gameOverBox = new Sprite();

    Bitmap background = new Bitmap(Grafix.resource.getBitmapData("ExitBox"));
    gameOverBox.addChild(background);

    TextFormat textFormat = new TextFormat("Arial", 30, 0xFFFFFF, true);
    textFormat.align = TextFormatAlign.CENTER;

    TextField textField = new TextField();
    textField.defaultTextFormat = textFormat;
    textField.width = 240;
    textField.height = 200;
    textField.wordWrap = true;
    //textField.selectable = false;
    textField.text = Texts.resource.getText("GENgameover");
    textField.x = 47;
    textField.y = 30 + (textField.height - textField.textHeight)/2;
    //textField.filters = [new GlowFilter(0x000000, 0.7, 3, 3)];
    textField.mouseEnabled = false;
    gameOverBox.addChild(textField);

    gameOverBox.x = 110;
    gameOverBox.y = -gameOverBox.height;
    _messageLayer.addChild(gameOverBox);

    Sound laugh = Sounds.resource.getSound("Laugh");
    Juggler.instance.delayCall(() => laugh.play(), 0.3);

    Tween tween = new Tween(gameOverBox, 0.3, Transitions.easeOutCubic);
    tween.animate("y", 150);

    Juggler.instance.add(tween);

    //----------------------------------------------

    Juggler.instance.delayCall(() => _exitGame(true), 5.0);

    gameOverBox.addEventListener(MouseEvent.CLICK, (MouseEvent me) => _exitGame(true));
  }

  //---------------------------------------------------------------------------------------------------

  bool _exitCalled = false;

  void _exitGame(bool gameEnded)
  {
    _timeGauge.pause();

    if (_exitCalled == false)
    {
      _exitCalled = true;
      //  GameApi.instance.exit(_points.intValue, gameEnded);
    }
  }

}