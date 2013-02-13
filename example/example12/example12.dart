library example01;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:dartflash/dartflash.dart';

Stage stage;
RenderLoop renderLoop;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("stage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // load a Flump object and show it
  //------------------------------------------------------------------
  
  FlumpLibrary.load("images/library.json").then(onFlumpLibraryLoaded);
}

void onFlumpLibraryLoaded(FlumpLibrary flumpLibrary) 
{
  BitmapData.load("images/atlas0.png").then((bitmapData) {
    Bitmap bitmap = new Bitmap(bitmapData);
    bitmap.x = 40;
    bitmap.y = 40;
    stage.addChild(bitmap);
  });
  
  FlumpMovie idle = new FlumpMovie(flumpLibrary, "idle");
  idle.x = 550;
  idle.y = 200;
  idle.addTo(stage);   
  
  FlumpMovie walk = new FlumpMovie(flumpLibrary, "walk");
  walk.x = 160;
  walk.y = 520;
  walk.addTo(stage);   
    
  FlumpMovie attack = new FlumpMovie(flumpLibrary, "attack");
  attack.x = 420;
  attack.y = 520;
  attack.addTo(stage);

  FlumpMovie defeat = new FlumpMovie(flumpLibrary, "defeat");
  defeat.x = 640;
  defeat.y = 520;
  defeat.addTo(stage);
   
  renderLoop.juggler.add(idle);
  renderLoop.juggler.add(walk);
  renderLoop.juggler.add(attack);
  renderLoop.juggler.add(defeat);
}



