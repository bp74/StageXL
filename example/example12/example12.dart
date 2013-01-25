library example01;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:dartflash/dartflash.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var stage = new Stage("stage", html.document.query('#stage'));

  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // load a Flump object and show it
  //------------------------------------------------------------------
  
  FlumpLibrary.load("images/library.json").then(onFlumpLibraryLoaded);
  
}

void onFlumpLibraryLoaded(FlumpLibrary flumpLibrary) 
{
    print("jsdhflkjasdfhglkjsdfkgljsdfg");
}



