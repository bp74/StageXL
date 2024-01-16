part of '../display_ex.dart';

/// The HtmlObject adds a regular HTML element to the display list.
/// You can set all the well known DisplayObject properties like x, y, scaleX,
/// scaleY, rotation or alpha which will be applied to the HTML element. Because
/// the HtmlObject is still rendered by the browser it will appear on top of
/// the Stage and can't be overlayed by regular DisplayObjects.
///
/// Please use this HTML configuration to get the correct results:
///
///     <div style="position: relative;">
///       <canvas id="stage" width="800" height="600"></canvas>
///       <div id="htmlObject">Hello World</div>
///     </div>
///
/// The HtmlObject will automatically set the following CSS properties
/// for the element to control it's position and opacity:
///
///     position: absolute;
///     left: 0px;
///     top: 0px;
///     transformOrigin: 0% 0% 0;
///     opacity: (htmlObject.alpha)
///     visibility: (htmlObject.visible)
///     transform: (htmlObject.transformationMatrix)
///
/// Example:
///
///     var element = html.querySelector("#htmlObject");
///     var htmlObject = new HtmlObject(element);
///     htmlObject.x = 400;
///     htmlObject.y = 300;
///     stage.addChild(htmlObject);

class HtmlObject extends DisplayObject {
  final Element element;

  late final CssStyleDeclaration _style;
  String _styleOpacity = '';
  String _styleTransform = '';
  String _styleVisibility = '';

  HtmlObject(this.element) {
    _style = element.style;
    _style.position = 'absolute';
    _style.left = '0px';
    _style.top = '0px';
    _style.transformOrigin = '0% 0% 0';
    _style.visibility = 'hidden';

    onRemovedFromStage.listen(_onRemovedFromStage);
  }

  //-----------------------------------------------------------------------------------------------

  void _hideElement() {
    _style.visibility = _styleVisibility = 'hidden';
  }

  void _onRemovedFromStage(Event e) {
    _hideElement();
  }

  @override
  set visible(bool value) {
    super.visible = value;
    if (value == false) _hideElement();
  }

  @override
  set off(bool value) {
    super.off = value;
    if (value) _hideElement();
  }

  //-----------------------------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    final globalMatrix = renderState.globalMatrix;
    final globalAlpha = renderState.globalAlpha;
    final visibility = visible && off == false;
    final stage = this.stage;
    final pixelRatio = stage != null ? stage.pixelRatio : 1.0;

    final ma = (globalMatrix.a / pixelRatio).toStringAsFixed(4);
    final mb = (globalMatrix.b / pixelRatio).toStringAsFixed(4);
    final mc = (globalMatrix.c / pixelRatio).toStringAsFixed(4);
    final md = (globalMatrix.d / pixelRatio).toStringAsFixed(4);
    final mtx = (globalMatrix.tx / pixelRatio).toStringAsFixed(4);
    final mty = (globalMatrix.ty / pixelRatio).toStringAsFixed(4);

    final styleOpacity = globalAlpha.toStringAsFixed(4);
    final styleTransform = 'matrix($ma,$mb,$mc,$md,$mtx,$mty)';
    final styleVisibility = visibility ? 'visible' : 'hidden';

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
