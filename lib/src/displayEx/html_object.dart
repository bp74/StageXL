part of stagexl;

/**
 * The HtmlObject adds a regular HTML element to the display list.
 * You can set all the well known DisplayObject properties like x, y, scaleX,
 * scaleY, rotation or alpha which will be applied to the HTML element. Because
 * the HtmlObject is still rendered by the browser it will appear on top of
 * the Stage and can't be overlayed by regular DisplayObjects.
 *
 * Please use this HTML configuration to get the correct results:
 *
 *     <div style="position: relative;">
 *       <canvas id="stage" width="800" height="600"></canvas>
 *       <div id="htmlObject">Hello World</div>
 *     </div>
 *
 * The HtmlObject will automatically set the following CSS properties
 * for the element to control it's position and opacity:
 *
 *     position: absolute;
 *     left: 0px;
 *     top: 0px;
 *     transformOrigin: 0% 0% 0;
 *     opacity: (htmlObject.alpha)
 *     visibility: (htmlObject.visible)
 *     transform: (htmlObject.transformationMatrix)
 *
 * Example:
 *
 *     var element = html.querySelector("#htmlObject");
 *     var htmlObject = new HtmlObject(element);
 *     htmlObject.x = 400;
 *     htmlObject.y = 300;
 *     stage.addChild(htmlObject);
 *
 */

class HtmlObject extends DisplayObject {

  final html.Element element;

  html.CssStyleDeclaration _style;
  String _styleOpacity = "";
  String _styleTransform = "";
  String _styleVisibility = "";

  HtmlObject(this.element) {

    _style = this.element.style;
    _style.position = "absolute";
    _style.left = "0px";
    _style.top = "0px";
    _style.transformOrigin = "0% 0% 0";
    _style.visibility = "hidden";

    this.onRemovedFromStage.listen(_onRemovedFromStage);
  }

  //-----------------------------------------------------------------------------------------------

  _hideElement() {
    _style.visibility = _styleVisibility = "hidden";
  }

  _onRemovedFromStage(Event e) {
    _hideElement();
  }

  set visible(bool value) {
    super.visible = value;
    if (value == false) _hideElement();
  }

  set off(bool value) {
    super.off = value;
    if (value) _hideElement();
  }

  //-----------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var contextState = renderState._currentContextState;
    var matrix = contextState.matrix;
    var alpha = contextState.alpha;
    var visibility = this.visible && this.off == false;

    var mxa = matrix.a.toStringAsFixed(4);
    var mxb = matrix.b.toStringAsFixed(4);
    var mxc = matrix.c.toStringAsFixed(4);
    var mxd = matrix.d.toStringAsFixed(4);
    var mxtx = matrix.tx.toStringAsFixed(4);
    var mxty = matrix.ty.toStringAsFixed(4);

    var styleOpacity = alpha.toStringAsFixed(4);
    var styleTransform = "matrix($mxa,$mxb,$mxc,$mxd,$mxtx,$mxty)";
    var styleVisibility = visibility ? "visible" : "hidden";

    if (_styleVisibility != styleVisibility) {
      _style.visibility = _styleVisibility = styleVisibility;
    }

    if (_styleOpacity != styleOpacity) {
      _style.opacity = _styleOpacity = styleOpacity;
    }

    if (_styleTransform != styleTransform) {
      _style.transform = _styleTransform = styleTransform;
    }
  }

}