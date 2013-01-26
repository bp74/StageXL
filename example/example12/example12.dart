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
  FlumpMovie idle = new FlumpMovie(flumpLibrary, "idle");
  idle.x = 220;
  idle.y = 250;
  idle.addTo(stage);   
  
  FlumpMovie walk = new FlumpMovie(flumpLibrary, "walk");
  walk.x = 580;
  walk.y = 250;
  walk.addTo(stage);   
    
  FlumpMovie attack = new FlumpMovie(flumpLibrary, "attack");
  attack.x = 220;
  attack.y = 520;
  attack.addTo(stage);

  FlumpMovie defeat = new FlumpMovie(flumpLibrary, "defeat");
  defeat.x = 580;
  defeat.y = 520;
  defeat.addTo(stage);
   
  renderLoop.juggler.add(idle);
  renderLoop.juggler.add(walk);
  renderLoop.juggler.add(attack);
  renderLoop.juggler.add(defeat);
}



