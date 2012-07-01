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
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  Resource resource = new Resource();
  resource.addImage("house", "../images/House.png");
  resource.addImage("sun", "../images/Sun.png");
  resource.addImage("tree", "../images/Tree.png");

  Future resourceLoader = resource.load();

  resourceLoader.then((result)
  {
    // Let's create a new World

    World world = new World(resource);
    world.pivotX = world.width / 2;
    world.pivotY = world.height / 2;
    world.x = 100;
    world.y = 100;
    stage.addChild(world);

    // Flash does not support programmable animations out of the box.
    // So we create our own :) Let's move the world ...

    Tween tweenDown = new Tween(world, 2.0, Transitions.easeOutBounce);
    tweenDown.animate("x", 700);
    tweenDown.animate("y", 500);
    tweenDown.delay = 1.0;

    Tween tweenUp = new Tween(world, 2.0, Transitions.easeOutBounce);
    tweenUp.animate("x", 100);
    tweenUp.animate("y", 100);
    tweenUp.delay = 4.0;

    Tween tweenRotation = new Tween(world, 6.0, Transitions.easeInOutElastic);
    tweenRotation.animate("rotation", Math.PI * 4);
    tweenRotation.delay = 7.0;

    Juggler.instance.add(tweenDown);
    Juggler.instance.add(tweenUp);
    Juggler.instance.add(tweenRotation);
  });

  // ToDo: handle the exception correctly
  resourceLoader.handleException((exception) => true);

}
