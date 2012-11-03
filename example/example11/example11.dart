library example11;

import 'dart:math';
import 'dart:html' as html;
import 'package:dartflash/dartflash.dart';

part 'dot.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var stage = new Stage("stage", html.document.query('#stage'));

  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // add Touch Event handlers
  //------------------------------------------------------------------

  var dots = new Map<int, Dot>();

  void onTouchBegin(TouchEvent touchEvent)
  {
     var dot = new Dot(touchEvent.touchPointID);
     dot.x = touchEvent.stageX;
     dot.y = touchEvent.stageY;
     dot.addTo(stage);
     dots[touchEvent.touchPointID] = dot;
  }

  void onTouchEnd(TouchEvent touchEvent)
  {
    var dot =  dots[touchEvent.touchPointID];
    dot.removeFromParent();
    dots.remove(touchEvent.touchPointID);
  }

  void onTouchMove(TouchEvent touchEvent)
  {
    var dot =  dots[touchEvent.touchPointID];
    dot.x = touchEvent.stageX;
    dot.y = touchEvent.stageY;
  }

  stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
  stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
  stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
}
