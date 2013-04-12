library example07;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

//###########################################################################
//  Credits for "TheZakMan" on http://opengameart.org for the walking man.
//###########################################################################

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
  // Load a TextureAtlas
  //------------------------------------------------------------------

  resourceManager = new ResourceManager();
  resourceManager.addTextureAtlas("ta1", "images/walk.json", TextureAtlasFormat.JSONARRAY);
  resourceManager.load().then((result) => startAnimation());
}

//---------------------------------------------------------------------------------------

void startAnimation()
{
  Random random = new Random();

  //------------------------------------------------------------------
  // Get all the "walk" bitmapDatas in the texture atlas.
  //------------------------------------------------------------------

  TextureAtlas textureAtlas = resourceManager.getTextureAtlas("ta1");
  List<BitmapData> bitmapDatas = textureAtlas.getBitmapDatas("walk");

  bitmapDatas = bitmapDatas.map((bd) => bd.clone()).toList(growable:false);

  //------------------------------------------------------------------
  // Create a flip book with the list of bitmapDatas.
  //------------------------------------------------------------------

  num rnd = random.nextDouble();

  var flipBook1 = new FlipBook(bitmapDatas, 30);
  flipBook1.x = -128;
  flipBook1.y = 100.0 + 200.0 * rnd;
  flipBook1.scaleX = flipBook1.scaleY = 0.5 + 0.5 * rnd;
  flipBook1.play();
  flipBook1.alpha = 0.5;
  stage.addChild(flipBook1);
  
  var flipBook = new FlipBook(bitmapDatas, 30);
  flipBook.clipRectangle = new Rectangle(40, 40, 60, 120);
  flipBook.x = -128;
  flipBook.y = 100.0 + 200.0 * rnd;
  flipBook.scaleX = flipBook.scaleY = 0.5 + 0.5 * rnd;
  flipBook.play();
  stage.addChild(flipBook);
  
  stage.sortChildren((c1, c2) => (c1.y < c2.y) ? -1 : ((c1.y > c2.y) ? 1 : 0));

  //------------------------------------------------------------------
  // Let's add a tween so the man walks from the left to the right.
  //------------------------------------------------------------------

  Tween tween1 = new Tween(flipBook1, 5.0 + (1.0 - rnd) * 5.0, TransitionFunction.linear)
  ..animate.x.to(800.0)
  ..onComplete = () {
    renderLoop.juggler.remove(flipBook1);
    stage.removeChild(flipBook1);
  };

  Tween tween = new Tween(flipBook, 5.0 + (1.0 - rnd) * 5.0, TransitionFunction.linear)
    ..animate.x.to(800.0)
    ..onComplete = () {
      renderLoop.juggler.remove(flipBook);
      stage.removeChild(flipBook);      
    };

  renderLoop.juggler.add(flipBook1);
  renderLoop.juggler.add(tween1);    
  renderLoop.juggler.add(flipBook);
  renderLoop.juggler.add(tween);
  
  //------------------------------------------------------------------
  // after 0.3 seconds the next animation should start
  //------------------------------------------------------------------

  renderLoop.juggler.delayCall(startAnimation, 0.3);
}



