library example08;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main() {

  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("myStage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // prepare different Masks for later use
  //------------------------------------------------------------------

  var starPath = new List<Point>();

  for(var i = 0; i < 6; i++) {
    var a1 = PI * (i * 60.0) / 180.0;
    var a2 = PI * (i * 60.0 + 30.0) / 180.0;
    starPath.add(new Point(400.0 + 200.0 * cos(a1), 350.0 + 200.0 * sin(a1)));
    starPath.add(new Point(400.0 + 100.0 * cos(a2), 350.0 + 100.0 * sin(a2)));
  }

  var rectangleMask = new Mask.rectangle(100.0, 200.0, 600.0, 300.0);
  var circleMask = new Mask.circle(400.0, 350.0, 200.0);
  var customMask = new Mask.custom(starPath);

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

  resourceManager.load().then((result) {

    var animation = getAnimation();
    animation.pivotX = 400;
    animation.pivotY = 350;
    animation.x = 400;
    animation.y = 350;
    stage.addChild(animation);

    var buttons = [
      getButton("None", () => animation.mask = null),
      getButton("Rectangle", () => animation.mask = rectangleMask),
      getButton("Circle", () => animation.mask = circleMask),
      getButton("Custom", () => animation.mask = customMask),
      getButton("spin", () {
        renderLoop.juggler.tween(animation, 2.0, TransitionFunction.easeInOutBack)
          ..animate.rotation.to(PI * 4.0)
          ..onComplete = () => animation.rotation = 0.0;
      })
    ];

    for(var b = 0; b < buttons.length; b++) {
      var button = buttons[b];
      stage.addChild(button);

      button.x = (b < 4 ) ? 10 + b * 130 : 645;
      button.y = 10;
      button.scaleX = 0.5;
      button.scaleY = 0.5;
    }

  });
}

Sprite getAnimation() {

  var sprite = new Sprite();
  var random = new Random();

  for(var i = 0; i < 150; i++) {
    var f = 1 + random.nextInt(3);
    var bitmapData = resourceManager.getBitmapData("flower$f");
    var bitmap = new Bitmap(bitmapData);
    bitmap.pivotX = 64;
    bitmap.pivotY = 64;
    bitmap.x = 64.0 + random.nextDouble() * 672.0;
    bitmap.y = 164.0 + random.nextDouble() * 372.0;
    sprite.addChild(bitmap);

    renderLoop.juggler.tween(bitmap, 180.0, TransitionFunction.linear)
      ..animate.rotation.to(PI * 20.0);
  }

  return sprite;
}


Sprite getButton(String text, Function clickHandler) {

  var container = new Sprite();

  var buttonUp = new Bitmap(resourceManager.getBitmapData("buttonUp"));
  var buttonOver = new Bitmap(resourceManager.getBitmapData("buttonOver"));
  var buttonDown = new Bitmap(resourceManager.getBitmapData("buttonDown"));

  var simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
  simpleButton.x = 20;
  simpleButton.y = 20;
  simpleButton.addTo(container);

  var textField = new TextField();
  textField.defaultTextFormat = new TextFormat("Verdana", 30, 0xFFFFFF, align:TextFormatAlign.CENTER);
  textField.width = simpleButton.width;
  textField.height = 40;
  textField.text = text;
  textField.x = simpleButton.x;
  textField.y = simpleButton.y + 10;
  textField.mouseEnabled = false;
  textField.addTo(container);

  simpleButton.onMouseClick.listen((me) => clickHandler());

  return container;
}


