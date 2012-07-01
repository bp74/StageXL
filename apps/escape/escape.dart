#import('dart:html', prefix:'html');
#import('../../library/dartflash.dart');

#source("source/Alarm.dart");
#source("source/Board.dart");
#source("source/BoardEvent.dart");
#source("source/BoardStatus.dart");
#source("source/Bonus.dart");
#source("source/ExitBox.dart");
#source("source/Explosion.dart");
#source("source/Field.dart");
#source("source/Game.dart");
#source("source/Grafix.dart");
#source("source/Head.dart");
#source("source/InfoBox.dart");
#source("source/Lock.dart");
#source("source/MessageBox.dart");
#source("source/Sounds.dart");
#source("source/Special.dart");
#source("source/SpecialJokerChain.dart");
#source("source/SpecialJokerLink.dart");
#source("source/SpecialWobble.dart");
#source("source/Texts.dart");
#source("source/ValueCounter.dart");

#source("source/Gauge.dart");
#source("source/TimeGauge.dart");

Stage stageBackground;
Stage stageForeground;
RenderLoop renderLoop;

Bitmap loadingBitmap;
Tween loadingBitmapTween;
TextField loadingTextField;

void main()
{
  stageBackground = new Stage("StageBackground", html.query('#stageBackground'));
  stageForeground = new Stage("StageForeground", html.query('#stageForeground'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stageBackground);
  renderLoop.addStage(stageForeground);

  //-------------------------------------------

  Future<BitmapData> loading = BitmapData.loadImage("images/Loading.png");

  loading.then((bitmapData)
  {
    loadingBitmap = new Bitmap(bitmapData);
    loadingBitmap.pivotX = 20;
    loadingBitmap.pivotY = 20;
    loadingBitmap.x = 400;
    loadingBitmap.y = 270;
    stageForeground.addChild(loadingBitmap);

    loadingBitmapTween = new Tween(loadingBitmap, 100, Transitions.linear);
    loadingBitmapTween.animate("rotation", 100 * 2 * Math.PI);
    Juggler.instance.add(loadingBitmapTween);

    loadingTextField = new TextField();
    loadingTextField.defaultTextFormat = new TextFormat("Arial", 20, 0xA0A0A0, true);;
    loadingTextField.width = 240;
    loadingTextField.height = 40;
    loadingTextField.text = "... loading ...";
    loadingTextField.x = 400 - loadingTextField.textWidth / 2;
    loadingTextField.y = 320;
    loadingTextField.mouseEnabled = false;
    stageForeground.addChild(loadingTextField);

    loadGame();
  });
}

void loadGame()
{
  Resource resource = new Resource();

  resource.addImage("Background", "images/Background.jpg");
  resource.addImage("ExitBox", "images/ExitBox.png");
  resource.addImage("ExitButtonNormal", "images/ExitButtonNormal.png");
  resource.addImage("ExitButtonPressed", "images/ExitButtonPressed.png");
  resource.addImage("ExitGauge", "images/ExitGauge.png");
  resource.addImage("ExitNoButtonNormal", "images/ExitNoButtonNormal.png");
  resource.addImage("ExitNoButtonPressed", "images/ExitNoButtonPressed.png");
  resource.addImage("ExitYesButtonNormal", "images/ExitYesButtonNormal.png");
  resource.addImage("ExitYesButtonPressed", "images/ExitYesButtonPressed.png");
  resource.addImage("InfoBox", "images/InfoBox.png");
  resource.addImage("MessageBox", "images/MessageBox.png");
  resource.addImage("ShuffleButtonNormal", "images/ShuffleButtonNormal.png");
  resource.addImage("ShuffleButtonPressed", "images/ShuffleButtonPressed.png");
  resource.addImage("TimeGauge", "images/TimeGauge.png");

  resource.addTextureAtlas("Alarm", "images/AlarmTextureAtlas.json", TextureAtlasFormat.JSONARRAY);
  resource.addTextureAtlas("Head", "images/HeadTextureAtlas.json", TextureAtlasFormat.JSONARRAY);
  resource.addTextureAtlas("Elements", "images/ElementsTextureAtlas.json", TextureAtlasFormat.JSONARRAY);
  resource.addTextureAtlas("Levelup", "images/LevelupTextureAtlas.json", TextureAtlasFormat.JSONARRAY);
  resource.addTextureAtlas("Locks", "images/LocksTextureAtlas.json", TextureAtlasFormat.JSONARRAY);

  resource.addSound("BonusAllUnlock", "sounds/BonusAllUnlock.mp3");
  resource.addSound("BonusUniversal", "sounds/BonusUniversal.mp3");
  resource.addSound("ChainBlast", "sounds/ChainBlast.mp3");
  resource.addSound("ChainBlastSpecial", "sounds/ChainBlastSpecial.mp3");
  resource.addSound("ChainError", "sounds/ChainError.mp3");
  resource.addSound("ChainFall", "sounds/ChainFall.mp3");
  resource.addSound("ChainHelp", "sounds/ChainHelp.mp3");
  resource.addSound("ChainLink", "sounds/ChainLink.mp3");
  resource.addSound("ChainRotate", "sounds/ChainRotate.mp3");
  resource.addSound("Click", "sounds/Click.mp3");
  resource.addSound("GameOver", "sounds/GameOver.mp3");
  resource.addSound("Laugh", "sounds/Laugh.mp3");
  resource.addSound("LevelUp", "sounds/LevelUp.mp3");
  resource.addSound("PointsCounter", "sounds/PointsCounter.mp3");
  resource.addSound("Unlock", "sounds/Unlock.mp3");
  resource.addSound("Warning", "sounds/Warning.mp3");
  resource.addSound("Intro", "sounds/Intro.mp3");

  resource.addText("ESCAPE_INS_AIM_0", "Connect at least 3 chain links of the same colour to a horizontal or vertical chain.");
  resource.addText("ESCAPE_INS_DES_0", "You can change the direction of a chain link by touching it.");
  resource.addText("ESCAPE_INS_TIP_0", "Earn extra points for connecting chain links displaying a key symbol.");
  resource.addText("ESCBlockErrorHint", "Sorry but block chains can´t be twisted!");
  resource.addText("ESCLevelBoxText", "Connect {0} chain links and help the crook to escape!");
  resource.addText("ESCNoActionHint", "Press on the chain links to twist them.");
  resource.addText("ESCNoComboHint", "You have to connect at least 3 chain links of the same colour.");
  resource.addText("ESCStartText", "Form horizontal or vertical same-colour chains and become an escape agent!");
  resource.addText("ESCtogo", "Chain links:");
  resource.addText("GENexitquery", "Do you really want to quit the game?");
  resource.addText("GEN2ndchancetime", "Time is up. Second chance!");
  resource.addText("GENtimeup", "Sorry! Your time is up.");
  resource.addText("GENgameover", "Game Over");

  resource.load().then((res)
  {
    stageForeground.removeChild(loadingBitmap);
    stageForeground.removeChild(loadingTextField);
    Juggler.instance.remove(loadingBitmapTween);

    //------------------------------

    Grafix.resource = resource;
    Sounds.resource = resource;
    Texts.resource = resource;

    Bitmap backgroundBitmap = new Bitmap(Grafix.resource.getBitmapData("Background"));
    stageBackground.addChild(backgroundBitmap);
    stageBackground.renderMode = StageRenderMode.ONCE;

    Game game = new Game();
    stageForeground.addChild(game);

    game.start();
  });
}


