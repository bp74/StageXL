library example09;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

String jsonJelly = '{"location" : { "x" : 160.00, "y" : 370.00 }, "locationVariance": { "x" : 20.00, "y" : 0.00 }, "speed" : 140.00, "speedVariance" : 0.00, "lifeSpan" : 0.70, "lifespanVariance" : 0.00, "angle" : 225.00, "angleVariance" : 360.00, "gravity" : { "x" : 0.00, "y" : -1400.00 }, "radialAcceleration" : 0.00, "tangentialAcceleration" : 0.00, "radialAccelerationVariance" : 0.00, "tangentialAccelerationVariance" : 0.00, "startColor" : { "red" : 0.15, "green" : 0.06 , "blue" : 1.00 , "alpha" : 1.0 }, "finishColor" : { "red" : 0.00 , "green" : 0.14 , "blue" : 0.23 , "alpha" : 0.00 }, "maxParticles" : 100, "startSize" : 40.00, "startSizeVariance" : 0.00, "finishSize" : 80.00, "finishSizeVariance" : 0.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 100.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00, "compositeOperation": "lighter" }';
String jsonFire = '{"location" : { "x" : 160.00, "y" : 430.00 }, "locationVariance": { "x" : 40.00, "y" : 0.00 }, "speed" : 190.00, "speedVariance" : 30.00, "lifeSpan" : 1.00, "lifespanVariance" : 0.70, "angle" : 270.00, "angleVariance" : 15.00, "gravity" : { "x" : 0.00, "y" : 0.00 }, "radialAcceleration" : 0.00, "tangentialAcceleration" : 0.00, "radialAccelerationVariance" : 0.00, "tangentialAccelerationVariance" : 0.00, "startColor" : { "red" : 1.00, "green" : 0.31 , "blue" : 0.00 , "alpha" : 0.62 }, "finishColor" : { "red" : 1.00 , "green" :  0.31 , "blue" : 0.00 , "alpha" : 0.00 }, "maxParticles" : 200, "startSize" : 50.00, "startSizeVariance" : 30.00, "finishSize" : 10.00, "finishSizeVariance" : 0.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 100.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00, "compositeOperation": "lighter" }';
String jsonSun = '{"location" : { "x" : 160.00, "y" : 230.00 }, "locationVariance": { "x" : 7.00, "y" : 7.00 }, "speed" : 260.00, "speedVariance" : 10.00, "lifeSpan" : 1.00, "lifespanVariance" : 0.70, "angle" : 0.00, "angleVariance" : 360.00, "gravity" : { "x" : 0.00, "y" : 0.00 }, "radialAcceleration" : -600.00, "tangentialAcceleration" : -100.00, "radialAccelerationVariance" : 0.00, "tangentialAccelerationVariance" : 0.00, "startColor" : { "red" : 1.00, "green" : 0.0 , "blue" : 0.0 , "alpha" : 1.0 }, "finishColor" : { "red" : 1.00 , "green" : 1.00 , "blue" : 0.00 , "alpha" : 1.00 }, "maxParticles" : 200, "startSize" : 30.00, "startSizeVariance" : 20.00, "finishSize" : 5.00, "finishSizeVariance" : 5.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 40.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00, "compositeOperation": "lighter" }';

Stage stageBackground;
Stage stageForeground;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main()
{

  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stageBackground = new Stage("stageBackground", html.document.query('#stageBackground'));
  stageForeground = new Stage("stageForeground", html.document.query('#stageForeground'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stageBackground);
  renderLoop.addStage(stageForeground);

  //------------------------------------------------------------------
  // prepare Background and Particle System
  //------------------------------------------------------------------

  Bitmap background = new Bitmap(new BitmapData(800, 600, false, 0x000000));
  stageBackground.addChild(background);
  stageBackground.renderMode = StageRenderMode.ONCE;

  ParticleEmitter particleEmitter = null;

  void startParticleSystem(String config) {

    if (particleEmitter != null) {
      particleEmitter.stop(true);
      stageForeground.removeChild(particleEmitter);
      renderLoop.juggler.remove(particleEmitter);
    }

    particleEmitter = new ParticleEmitter(config);
    particleEmitter.setEmitterLocation(400, 400);
    particleEmitter.start();

    stageForeground.addChild(particleEmitter);
    renderLoop.juggler.add(particleEmitter);
  }

  startParticleSystem(jsonJelly);

  //------------------------------------------------------------------
  // control the emitter of the particle system with the mouse
  //------------------------------------------------------------------

  TextField textField = new TextField();
  textField.defaultTextFormat = new TextFormat("Arial", 14, 0xFFFFFF);
  textField.width = 400;
  textField.x = 10;
  textField.y = 570;
  textField.text = "Use the mouse to control the particle emitter position.";
  stageBackground.addChild(textField);

  GlassPlate glassPlate = new GlassPlate(800, 600);
  stageForeground.addChild(glassPlate);

  void mouseAction(MouseEvent me) {
    if (me.buttonDown) {
      particleEmitter.setEmitterLocation(me.localX, me.localY);
    }
  }

  glassPlate.addEventListener(MouseEvent.MOUSE_DOWN, mouseAction);
  glassPlate.addEventListener(MouseEvent.MOUSE_MOVE, mouseAction);

  //------------------------------------------------------------------
  // Draw some buttons to show different particle systems.
  //------------------------------------------------------------------

  resourceManager = new ResourceManager()
    ..addBitmapData("buttonUp", "../common/images/ButtonUp.png")
    ..addBitmapData("buttonOver", "../common/images/ButtonOver.png")
    ..addBitmapData("buttonDown", "../common/images/ButtonDown.png");

  resourceManager.load().then((result) {

    List<Sprite> buttons = [
      getButton("Jelly", () => startParticleSystem(jsonJelly)),
      getButton("Fire", () => startParticleSystem(jsonFire)),
      getButton("Sun", () => startParticleSystem(jsonSun)),
      getButton("Stop", () => particleEmitter.stop(false))
    ];

    for(int b = 0; b < buttons.length; b++) {
      Sprite button = buttons[b];
      stageForeground.addChild(button);

      button.x = (b < 3) ? 10 + b * 130 : 645;
      button.y = 10;
      button.scaleX = 0.5;
      button.scaleY = 0.5;
    }
  });
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



