#import('dart:html', prefix:"html");
#import('../../library/dartflash.dart');

//###########################################################################
//  Credits for "TheZakMan" on http://opengameart.org for the walking man.
//###########################################################################

Stage stage;
Resource resource;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Load a TextureAtlas
  //------------------------------------------------------------------

  resource = new Resource();
  resource.addTextureAtlas("ta1", "images/walk.json", TextureAtlasFormat.JSONARRAY);
  resource.load().then((result) => startAnimation());
}

//---------------------------------------------------------------------------------------

void startAnimation()
{
  num random = Math.random();

  //------------------------------------------------------------------
  // Get all the "walk" bitmapDatas in the texture atlas.
  //------------------------------------------------------------------

  TextureAtlas textureAtlas = resource.getTextureAtlas("ta1");
  List<BitmapData> bitmapDatas = textureAtlas.getBitmapDatas("walk");

  //------------------------------------------------------------------
  // Create a movie clip with the list of bitmapDatas.
  //------------------------------------------------------------------

  MovieClip movieClip = new MovieClip(bitmapDatas, 30);
  movieClip.x = -128;
  movieClip.y = 100.0 + 200.0 * random;
  movieClip.scaleX = movieClip.scaleY = 0.5 + 0.5 * random;
  movieClip.play();

  stage.addChild(movieClip);
  stage.sortChildren((c1, c2) => (c1.y < c2.y) ? -1 : ((c1.y > c2.y) ? 1 : 0));

  //------------------------------------------------------------------
  // Let's add a tween so the man walks from the left to the right.
  //------------------------------------------------------------------

  Tween tween = new Tween(movieClip, 5.0 + (1 - random) * 5, Transitions.linear);
  tween.animate("x", 800.0);
  tween.onComplete = ()
  {
    Juggler.instance.remove(movieClip);
    stage.removeChild(movieClip);
  };

  Juggler.instance.add(movieClip);
  Juggler.instance.add(tween);

  //------------------------------------------------------------------
  // after 0.3 seconds the next animation should start
  //------------------------------------------------------------------

  Juggler.instance.delayCall(startAnimation, 0.3);

}



