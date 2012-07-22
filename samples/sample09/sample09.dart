#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

String jsonJelly = '{"sourcePosition" : { "x" : 160.00, "y" : 370.00 }, "sourcePositionVariance": { "x" : 20.00, "y" : 0.00 }, "speed" : 140.00, "speedVariance" : 0.00, "particleLifeSpan" : 0.70, "particleLifespanVariance" : 0.00, "angle" : 225.00, "angleVariance" : 360.00, "gravity" : { "x" : 0.00, "y" : -1400.00 }, "radialAcceleration" : 0.00, "tangentialAcceleration" : 0.00, "radialAccelVariance" : 0.00, "tangentialAccelVariance" : 0.00, "startColor" : { "red" : 0.15, "green" : 0.06 , "blue" : 1.00 , "alpha" : 1.0 }, "finishColor" : { "red" : 0.00 , "green" : 0.14 , "blue" : 0.23 , "alpha" : 0.00 }, "maxParticles" : 100, "startParticleSize" : 40.00, "startParticleSizeVariance" : 0.00, "finishParticleSize" : 80.00, "FinishParticleSizeVariance" : 0.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 100.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00 }';
String jsonFire = '{"sourcePosition" : { "x" : 160.00, "y" : 430.00 }, "sourcePositionVariance": { "x" : 40.00, "y" : 0.00 }, "speed" : 190.00, "speedVariance" : 30.00, "particleLifeSpan" : 1.00, "particleLifespanVariance" : 0.70, "angle" : 270.00, "angleVariance" : 15.00, "gravity" : { "x" : 0.00, "y" : 0.00 }, "radialAcceleration" : 0.00, "tangentialAcceleration" : 0.00, "radialAccelVariance" : 0.00, "tangentialAccelVariance" : 0.00, "startColor" : { "red" : 1.00, "green" : 0.31 , "blue" : 0.00 , "alpha" : 0.62 }, "finishColor" : { "red" : 1.00 , "green" :  0.31 , "blue" : 0.00 , "alpha" : 0.00 }, "maxParticles" : 200, "startParticleSize" : 50.00, "startParticleSizeVariance" : 30.00, "finishParticleSize" : 10.00, "FinishParticleSizeVariance" : 0.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 100.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00 }';
String jsonSun = '{"sourcePosition" : { "x" : 160.00, "y" : 230.00 }, "sourcePositionVariance": { "x" : 7.00, "y" : 7.00 }, "speed" : 260.00, "speedVariance" : 10.00, "particleLifeSpan" : 1.00, "particleLifespanVariance" : 0.70, "angle" : 0.00, "angleVariance" : 360.00, "gravity" : { "x" : 0.00, "y" : 0.00 }, "radialAcceleration" : -600.00, "tangentialAcceleration" : -100.00, "radialAccelVariance" : 0.00, "tangentialAccelVariance" : 0.00, "startColor" : { "red" : 1.00, "green" : 0.0 , "blue" : 0.0 , "alpha" : 1.0 }, "finishColor" : { "red" : 1.00 , "green" : 1.00 , "blue" : 0.00 , "alpha" : 1.00 }, "maxParticles" : 200, "startParticleSize" : 30.00, "startParticleSizeVariance" : 20.00, "finishParticleSize" : 5.00, "FinishParticleSizeVariance" : 5.00, "duration" : -1.00, "emitterType" : 0, "maxRadius" : 40.00, "maxRadiusVariance" : 0.00, "minRadius" : 0.00, "rotatePerSecond" : 0.00, "rotatePerSecondVariance" : 0.00 }';

Resource resource;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stageBackground = new Stage("stageBackground", html.document.query('#stageBackground'));
  Stage stageForeground = new Stage("stageForeground", html.document.query('#stageForeground'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stageBackground);
  renderLoop.addStage(stageForeground);

  //------------------------------------------------------------------
  // prepare Background and Particle System
  //------------------------------------------------------------------

  Bitmap background = new Bitmap(new BitmapData(800, 600, false, 0x000000));
  stageBackground.addChild(background);
  stageBackground.renderMode = StageRenderMode.ONCE;
 
  ParticleSystem particleSystem = null;
  
  var startParticleSystem = (String config)
  {
    if (particleSystem != null) {
      particleSystem.stop(true);
      stageForeground.removeChild(particleSystem);
      Juggler.instance.remove(particleSystem);
    }
    
    particleSystem = new ParticleSystem(config);
    particleSystem.emitterX = 400;
    particleSystem.emitterY = 400;
    particleSystem.start();

    stageForeground.addChild(particleSystem);
    Juggler.instance.add(particleSystem);
  };

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

  var mouseAction = (MouseEvent me) {
    if (me.buttonDown) {
      particleSystem.emitterX = me.localX;
      particleSystem.emitterY = me.localY;  
    }
  };
  
  glassPlate.addEventListener(MouseEvent.MOUSE_DOWN, mouseAction);
  glassPlate.addEventListener(MouseEvent.MOUSE_MOVE, mouseAction);
  
  //------------------------------------------------------------------
  // Draw some buttons to show different particle systems.
  //------------------------------------------------------------------

  resource = new Resource();
  resource.addImage("buttonUp", "../images/ButtonUp.png");
  resource.addImage("buttonOver", "../images/ButtonOver.png");
  resource.addImage("buttonDown", "../images/ButtonDown.png");
  
  resource.load().then((result)
  {
    List<Sprite> buttons = [
      getButton("Jelly", () => startParticleSystem(jsonJelly)),
      getButton("Fire", () => startParticleSystem(jsonFire)),
      getButton("Sun", () => startParticleSystem(jsonSun)),
      getButton("Stop", () => particleSystem.stop(false))
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

  Bitmap buttonUp = new Bitmap(resource.getBitmapData("buttonUp"));
  Bitmap buttonOver = new Bitmap(resource.getBitmapData("buttonOver"));
  Bitmap buttonDown = new Bitmap(resource.getBitmapData("buttonDown"));

  SimpleButton simpleButton = new SimpleButton(buttonUp, buttonOver, buttonDown, buttonOver);
  simpleButton.x = 20;
  simpleButton.y = 20;

  TextFormat textFormat = new TextFormat("Verdana", 30, Color.White, false);
  textFormat.align = TextFormatAlign.CENTER;

  TextField textField = new TextField();
  textField.defaultTextFormat = textFormat;
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



