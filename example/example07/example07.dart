library example07;

import 'dart:async';
import 'dart:math' hide Point, Rectangle;
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

//###########################################################################
//  Credits for "TheZakMan" on http://opengameart.org for the walking man.
//###########################################################################

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
  // Load a TextureAtlas
  //------------------------------------------------------------------

  BitmapData.defaultLoadOptions.webp = true;

  resourceManager = new ResourceManager();
  resourceManager.addTextureAtlas("ta1", "images/walk.json", TextureAtlasFormat.JSONARRAY);
  resourceManager.load().then((result) => startAnimation());
}

//---------------------------------------------------------------------------------------

void startAnimation() {

  var random = new Random();

  //------------------------------------------------------------------
  // Get all the "walk" bitmapDatas in the texture atlas.
  //------------------------------------------------------------------

  var textureAtlas = resourceManager.getTextureAtlas("ta1");
  var bitmapDatas = textureAtlas.getBitmapDatas("walk");

  //------------------------------------------------------------------
  // Create a flip book with the list of bitmapDatas.
  //------------------------------------------------------------------

  var rnd = random.nextDouble();

  var flipBook = new FlipBook(bitmapDatas, 30);
  flipBook.x = -128;
  flipBook.y = 100.0 + 200.0 * rnd;
  flipBook.scaleX = flipBook.scaleY = 0.5 + 0.5 * rnd;
  flipBook.play();

  stage.addChild(flipBook);
  stage.sortChildren((c1, c2) => (c1.y < c2.y) ? -1 : ((c1.y > c2.y) ? 1 : 0));

  //------------------------------------------------------------------
  // Let's add a tween so the man walks from the left to the right.
  //------------------------------------------------------------------

  var tween = new Tween(flipBook, 5.0 + (1.0 - rnd) * 5.0, TransitionFunction.linear)
    ..animate.x.to(800.0)
    ..onComplete = () {
      stage.juggler.remove(flipBook);
      stage.removeChild(flipBook);
    };

  stage.juggler.add(flipBook);
  stage.juggler.add(tween);

  //------------------------------------------------------------------
  // after 0.3 seconds the next animation should start
  //------------------------------------------------------------------

  stage.juggler.delayCall(startAnimation, 0.3);
}



