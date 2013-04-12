library example08;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("myStage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // prepare different Masks for later use
  //------------------------------------------------------------------

  List<Point> starPath = new List<Point>();

  for(int i = 0; i < 6; i++) {
    num a1 = PI * (i * 60.0) / 180.0;
    num a2 = PI * (i * 60.0 + 30.0) / 180.0;
    starPath.add(new Point(400.0 + 200.0 * cos(a1), 350.0 + 200.0 * sin(a1)));
    starPath.add(new Point(400.0 + 100.0 * cos(a2), 350.0 + 100.0 * sin(a2)));
  }

  Mask rectangleMask = new Mask.rectangle(100.0, 200.0, 600.0, 300.0);
  Mask circleMask = new Mask.circle(400.0, 350.0, 200.0);
  Mask customMask = new Mask.custom(starPath);

  var maskTarget = new Sprite();
  maskTarget.addChild(new GlassPlate(800, 700));
  maskTarget.startDrag(true);
  stage.addChild(maskTarget);
  
  rectangleMask.targetSpace = maskTarget;
  circleMask.targetSpace = maskTarget;
  customMask.targetSpace = maskTarget;
  
  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  resourceManager = new ResourceManager()
    ..addBitmapData("buttonUp", "../common/images/ButtonUp.png")
    ..addBitmapData("buttonOver", "../common/images/ButtonOver.png")
    ..addBitmapData("buttonDown", "../common/images/ButtonDown.png")
    ..addBitmapData("flower1", "../common/images/Flower1.png")
    ..addBitmapData("flower2", "../common/images/Flower2.png")
    ..addBitmapData("flower3", "../common/images/Flower3.png");

  //------------------------------------------------------------------
  // Draw buttons for different masks and start animation
  //------------------------------------------------------------------

  resourceManager.load().then((result)
  {
    Sprite animation = getAnimation();
    animation.pivotX = 400;
    animation.pivotY = 350;
    animation.x = 400;
    animation.y = 350;
    stage.addChild(animation);

    List<Sprite> buttons = [
      getButton("None", () => animation.mask = null),
      getButton("Rectangle", () => animation.mask = rectangleMask),
      getButton("Circle", () => animation.mask = circleMask),
      getButton("Custom", () => animation.mask = customMask),
      getButton("spin", () {
        var rotate = new Tween(animation, 2.0, TransitionFunction.easeInOutBack)
          ..animate.rotation.to(PI * 4.0)
          ..onComplete = () => animation.rotation = 0.0;
        
        renderLoop.juggler.add(rotate);
      })
    ];

    for(int b = 0; b < buttons.length; b++) {
      Sprite button = buttons[b];
      stage.addChild(button);

      button.x = (b < 4 ) ? 10 + b * 130 : 645;
      button.y = 10;
      button.scaleX = 0.5;
      button.scaleY = 0.5;
    }

  });
}

Sprite getAnimation()
{
  Sprite sprite = new Sprite();
  Random random = new Random();

  for(int i = 0; i < 150; i++) {
    int f = 1 + random.nextInt(3);
    BitmapData bitmapData = resourceManager.getBitmapData("flower$f");
    Bitmap bitmap = new Bitmap(bitmapData);
    bitmap.pivotX = 64;
    bitmap.pivotY = 64;
    bitmap.x = 64.0 + random.nextDouble() * 672.0;
    bitmap.y = 164.0 + random.nextDouble() * 372.0;
    sprite.addChild(bitmap);

    var tween = new Tween(bitmap, 180.0, TransitionFunction.linear)
      ..animate.rotation.to(PI * 20.0);
    
    renderLoop.juggler.add(tween);
  }

  return sprite;
}


Sprite getButton(String text, Function clickHandler)
{
  Sprite button = new Sprite();

  Bitmap buttonUp = new Bitmap(resourceManager.getBitmapData("buttonUp"));
  Bitmap buttonOver = new Bitmap(resourceManager.getBitmapData("buttonOver"));
  Bitmap buttonDown = new Bitmap(resourceManager.getBitmapData("buttonDown"));

  SimpleButton simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
  simpleButton.x = 20;
  simpleButton.y = 20;

  TextField textField = new TextField();
  textField.defaultTextFormat = new TextFormat("Verdana", 30, 0xFFFFFF, align:TextFormatAlign.CENTER);
  textField.width = simpleButton.width;
  textField.height = 40;
  textField.text = text;
  textField.x = simpleButton.x;
  textField.y = simpleButton.y + 10;
  textField.mouseEnabled = false;

  button.addChild(simpleButton);
  button.addChild(textField);

  simpleButton.addEventListener(MouseEvent.CLICK, (me) => clickHandler());

  return button;
}


