#import('dart:html', prefix:'html');
#import('package:dartflash/dartflash.dart');

void main() {

  var transitions = [

    { "name": "linear", "transition": Transitions.linear },
    { "name": "sine", "transition": Transitions.sine },
    { "name": "cosine", "transition": Transitions.cosine },
    { "name": "random", "transition": Transitions.random },

    { "name": "easeInQuadratic", "transition": Transitions.easeInQuadratic },
    { "name": "easeOutQuadratic", "transition": Transitions.easeOutQuadratic },
    { "name": "easeInOutQuadratic", "transition": Transitions.easeInOutQuadratic },
    { "name": "easeOutInQuadratic", "transition": Transitions.easeOutInQuadratic },

    { "name": "easeInCubic", "transition": Transitions.easeInCubic },
    { "name": "easeOutCubic", "transition": Transitions.easeOutCubic },
    { "name": "easeInOutCubic", "transition": Transitions.easeInOutCubic },
    { "name": "easeOutInCubic", "transition": Transitions.easeOutInCubic },

    { "name": "easeInQuartic", "transition": Transitions.easeInQuartic },
    { "name": "easeOutQuartic", "transition": Transitions.easeOutQuartic },
    { "name": "easeInOutQuartic", "transition": Transitions.easeInOutQuartic },
    { "name": "easeOutInQuartic", "transition": Transitions.easeOutInQuartic },

    { "name": "easeInQuintic", "transition": Transitions.easeInQuintic },
    { "name": "easeOutQuintic", "transition": Transitions.easeOutQuintic },
    { "name": "easeInOutQuintic", "transition": Transitions.easeInOutQuintic },
    { "name": "easeOutInQuintic", "transition": Transitions.easeOutInQuintic },

    { "name": "easeInCircular", "transition": Transitions.easeInCircular },
    { "name": "easeOutCircular", "transition": Transitions.easeOutCircular },
    { "name": "easeInOutCircular", "transition": Transitions.easeInOutCircular },
    { "name": "easeOutInCircular", "transition": Transitions.easeOutInCircular },

    { "name": "easeInSine", "transition": Transitions.easeInSine },
    { "name": "easeOutSine", "transition": Transitions.easeOutSine },
    { "name": "easeInOutSine", "transition": Transitions.easeInOutSine },
    { "name": "easeOutInSine", "transition": Transitions.easeOutInSine },

    { "name": "easeInExponential", "transition": Transitions.easeInExponential },
    { "name": "easeOutExponential", "transition": Transitions.easeOutExponential },
    { "name": "easeInOutExponential", "transition": Transitions.easeInOutExponential },
    { "name": "easeOutInExponential", "transition": Transitions.easeOutInExponential },

    { "name": "easeInBack", "transition": Transitions.easeInBack },
    { "name": "easeOutBack", "transition": Transitions.easeOutBack },
    { "name": "easeInOutBack", "transition": Transitions.easeInOutBack },
    { "name": "easeOutInBack", "transition": Transitions.easeOutInBack },

    { "name": "easeInElastic", "transition": Transitions.easeInElastic },
    { "name": "easeOutElastic", "transition": Transitions.easeOutElastic },
    { "name": "easeInOutElastic", "transition": Transitions.easeInOutElastic },
    { "name": "easeOutInElastic", "transition": Transitions.easeOutInElastic },

    { "name": "easeInBounce", "transition": Transitions.easeInBounce },
    { "name": "easeOutBounce", "transition": Transitions.easeOutBounce },
    { "name": "easeInOutBounce", "transition": Transitions.easeInOutBounce },
    { "name": "easeOutInBounce", "transition": Transitions.easeOutInBounce },

  ];

  for(int i = 0; i < transitions.length / 4; i++)
  {
    var rowDiv = new html.DivElement();
    rowDiv.id = "row";
    html.document.body.elements.add(rowDiv);

    for(int j = 0; j < 4; j++)
    {
      var name = transitions[i * 4 + j]["name"];
      var transition = transitions[i * 4 + j]["transition"];

      var cellDiv = drawTransition(name, transition);
      cellDiv.id = "cell";
      rowDiv.elements.add(cellDiv);
    }
  }

  html.document.body.elements.add(new html.Element.tag("br"));
  html.document.body.elements.add(new html.Element.tag("br"));
}


html.DivElement drawTransition(String name, TransitionFunction transitionFunction) {

  var div = new html.DivElement();
  div.style.width = "160px";
  div.style.height = "120px";
  div.style.padding = "0px 5px 10px 5px";

  var canvasElement = new html.CanvasElement(width:160, height:140);
  canvasElement.style.position = "absolute";
  canvasElement.style.zIndex = "1";
  div.elements.add(canvasElement);

  var headline = new html.DivElement();
  headline.text = name;
  headline.style.position = "relative";
  headline.style.zIndex = "2";
  headline.style.top = "6px";
  div.elements.add(headline);

  var stage = new Stage("stage", canvasElement);
  var shape = new Shape();
  var graphics = shape.graphics;

  graphics.beginPath();
  graphics.moveTo(0.5, 30.5);
  graphics.lineTo(159.5, 30.5);
  graphics.lineTo(159.5, 109.5);
  graphics.lineTo(0.5, 109.5);

  graphics.closePath();
  graphics.strokeColor(0xFF000000);
  graphics.fillColor(0xFFDFDFDF);

  graphics.beginPath();
  graphics.moveTo(0.5, 109.5);

  for(int i = 0; i <= 159; i++) {
    var ratio = i / 159.0;
    var x = 0.5 + ratio * 159.0;
    var y = 109.5 - 79.0 * transitionFunction(ratio);
    graphics.lineTo(x, y);
  }

  graphics.strokeColor(0xFF0000FF, 2);

  stage.addChild(shape);
  stage.materialize();

  return div;
}



