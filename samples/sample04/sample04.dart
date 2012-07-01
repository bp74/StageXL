#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

#source('world.dart');

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps and Sounds
  //------------------------------------------------------------------

  Resource resource = new Resource();
  resource.addImage("house", "../images/House.png");
  resource.addImage("sun", "../images/Sun.png");
  resource.addImage("tree", "../images/Tree.png");
  resource.addImage("buttonUp", "../images/ButtonUp.png");
  resource.addImage("buttonOver", "../images/ButtonOver.png");
  resource.addImage("buttonDown", "../images/ButtonDown.png");
  resource.addSound("plop", "../sounds/Plop.mp3");

  Future resourceLoader = resource.load();

  resourceLoader.then((result)
  {
    // Create a SimpleButton

    Bitmap buttonUp = new Bitmap(resource.getBitmapData("buttonUp"));
    Bitmap buttonOver = new Bitmap(resource.getBitmapData("buttonOver"));
    Bitmap buttonDown = new Bitmap(resource.getBitmapData("buttonDown"));

    SimpleButton simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
    simpleButton.x = 20;
    simpleButton.y = 20;

    stage.addChild(simpleButton);

    // Overlay the button with a TextField

    TextFormat textFormat = new TextFormat("Verdana", 30, Color.White, true);
    textFormat.align = TextFormatAlign.CENTER;

    TextField textField = new TextField();
    textField.defaultTextFormat = textFormat;
    textField.width = simpleButton.width;
    textField.height = 40;
    textField.text = "Click me";
    textField.x = simpleButton.x;
    textField.y = simpleButton.y + 10;
    textField.mouseEnabled = false;

    stage.addChild(textField);

    // Add an event listener to the SimpleButton

    int clickCount = 0;

    simpleButton.addEventListener(MouseEvent.CLICK, (MouseEvent me)
    {
      // play plop sound

      SoundTransform soundTransform = new SoundTransform(1);
      Sound sound = resource.getSound("plop");
      SoundChannel soundChannel = sound.play(false, soundTransform);

      // add a new world to the stage

      World world = new World(resource);
      world.x = 20 + clickCount * 40;
      world.y = 100 + clickCount * 20;
      stage.addChild(world);

      clickCount++;
    });
  });

  // ToDo: handle the exception correctly
  resourceLoader.handleException((exception) => true);

}
