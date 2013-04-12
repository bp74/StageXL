library example04;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

part 'world.dart';

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

  var resourceManager = new ResourceManager()
    ..addBitmapData("house", "../common/images/House.png")
    ..addBitmapData("sun", "../common/images/Sun.png")
    ..addBitmapData("tree", "../common/images/Tree.png")
    ..addBitmapData("buttonUp", "../common/images/ButtonUp.png")
    ..addBitmapData("buttonOver", "../common/images/ButtonOver.png")
    ..addBitmapData("buttonDown", "../common/images/ButtonDown.png")
    ..addSound("plop", "../common/sounds/Plop.mp3");

  resourceManager.load().then((result)
  {
    // Create a SimpleButton

    Bitmap buttonUp = new Bitmap(resourceManager.getBitmapData("buttonUp"));
    Bitmap buttonOver = new Bitmap(resourceManager.getBitmapData("buttonOver"));
    Bitmap buttonDown = new Bitmap(resourceManager.getBitmapData("buttonDown"));

    SimpleButton simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
    simpleButton.x = 20;
    simpleButton.y = 20;

    stage.addChild(simpleButton);

    // Overlay the button with a TextField

    TextField textField = new TextField();
    textField.defaultTextFormat = new TextFormat("Verdana", 30, 0xFFFFFF, bold:true, align:TextFormatAlign.CENTER);
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
      Sound sound = resourceManager.getSound("plop");
      SoundChannel soundChannel = sound.play(false, soundTransform);

      // add a new world to the stage

      World world = new World(resourceManager);
      world.x = 20 + clickCount * 40;
      world.y = 100 + clickCount * 20;
      stage.addChild(world);

      clickCount++;
    });
  }).catchError((error) {
    resourceManager.failedResources.forEach((rmr) {
      print("failed to load resource -> name: ${rmr.name}, url: ${rmr.url}");
    });
  });

}
