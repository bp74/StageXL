@TestOn('browser')
library;

import 'package:stagexl/stagexl.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  late web.HTMLCanvasElement canvas;
  late Stage stage;

  Stage createStage({bool enabled = true}) => Stage(canvas,
      width: 200,
      height: 100,
      options: StageOptions()
        ..renderEngine = RenderEngine.Canvas2D
        ..stageRenderMode = StageRenderMode.STOP
        ..accessibilityEnabled = enabled);

  web.Element? overlay() =>
      canvas.nextElementSibling?.hasAttribute('data-stagexl-accessibility') ==
              true
          ? canvas.nextElementSibling
          : null;

  List<web.Node> selectAll(String selectors) {
    final nodes = overlay()!.querySelectorAll(selectors);
    return List.generate(nodes.length, (index) => nodes.item(index)!);
  }

  List<web.HTMLButtonElement> buttons() =>
      selectAll('button').cast<web.HTMLButtonElement>();

  Future<void> flushSemantics() => Future<void>.delayed(Duration.zero);

  setUp(() {
    canvas = web.HTMLCanvasElement()
      ..width = 200
      ..height = 100
      ..style.width = '400px'
      ..style.height = '200px'
      ..tabIndex = 3;
    web.document.body!.append(canvas);
  });

  tearDown(() {
    stage.dispose();
    canvas.remove();
  });

  test('keeps the canvas and display list behaviour when accessibility is off',
      () async {
    stage = createStage(enabled: false);
    final button = SimpleButton();
    stage
      ..addChild(button)
      ..focus = button;
    await flushSemantics();

    expect(StageOptions().accessibilityEnabled, isFalse);
    expect(
        (StageOptions()..accessibilityEnabled = true)
            .clone()
            .accessibilityEnabled,
        isTrue);
    expect(stage.accessibility.nodeFor(button), isNull);
    expect(stage.accessibility.focus(button), isFalse);
    expect(stage.focus, same(button));
    expect(canvas.tabIndex, 3);
    expect(overlay(), isNull);
  });

  test('exposes grouped text and native buttons without duplicate names',
      () async {
    stage = createStage();
    final instructions = TextField('Choose a word');
    final artwork = TextField('Cat');
    final simpleButton = SimpleButton(artwork, artwork, artwork, artwork)
      ..x = 30;
    final word = TextField('Dog');
    final customButton = Sprite()
      ..accessible = true
      ..focusable = true
      ..accessibilityOrder = -1
      ..accessibilityDescription = 'Choose this word'
      ..addChild(word);
    final group = Sprite()
      ..accessible = true
      ..accessibilityRole = AccessibilityRole.group
      ..accessibilityLabel = 'Answers'
      ..addChild(simpleButton)
      ..addChild(customButton);
    final native = web.HTMLButtonElement()..textContent = 'Help';
    web.document.body!.append(native);
    // External JS interop methods cannot be torn off.
    // ignore: unnecessary_lambdas
    addTearDown(() => native.remove());
    stage
      ..addChild(instructions)
      ..addChild(group)
      ..addChild(Shape())
      ..addChild(TextField('private value')..displayAsPassword = true)
      ..addChild(TextField('editable value')..type = TextFieldType.INPUT)
      ..addChild(HtmlObject(native)..accessible = true);
    await flushSemantics();

    expect(canvas.tabIndex, -1);
    expect(
        overlay()!.querySelector('[role="group"]')!.getAttribute('aria-label'),
        'Answers');
    expect(
        selectAll('span').map((node) => node.textContent), ['Choose a word']);
    expect(buttons().map((button) => button.getAttribute('aria-label')),
        ['Dog', 'Cat']);
    expect(
        buttons().first.getAttribute('aria-description'), 'Choose this word');
    expect(stage.accessibility.nodeFor(word), isNull);
    expect(stage.accessibility.nodeFor(simpleButton)!.role,
        AccessibilityRole.button);

    final nativeButton = buttons().first;
    word.text = 'Bird';
    instructions.text = 'Choose an animal';
    artwork.text = 'Mouse';
    stage.materialize(0, 0);
    await flushSemantics();
    expect(buttons().first, same(nativeButton));
    expect(buttons().map((button) => button.getAttribute('aria-label')),
        ['Bird', 'Mouse']);
    expect(overlay()!.querySelector('span')!.textContent, 'Choose an animal');

    group.accessibilityChildren = false;
    await flushSemantics();
    expect(buttons(), isEmpty);
    expect(overlay()!.querySelector('[role="group"]'), isNotNull);
  });

  test('keeps focus through reordering and removes unavailable tab stops',
      () async {
    stage = createStage();
    final first = SimpleButton()..accessibilityLabel = 'First';
    final second = SimpleButton()..accessibilityLabel = 'Second';
    final parent = Sprite()
      ..addChild(first)
      ..addChild(second);
    stage.addChild(parent);
    await flushSemantics();

    final firstElement = buttons().first;
    firstElement.focus();
    expect(stage.focus, same(first));
    parent.swapChildren(first, second);
    await flushSemantics();
    expect(buttons().last, same(firstElement));
    expect(web.document.activeElement, same(firstElement));
    expect(stage.focus, same(first));

    first.enabled = false;
    await flushSemantics();
    expect(firstElement.disabled, isTrue);
    expect(stage.focus, isNull);
    expect(stage.accessibility.focus(first), isFalse);
    expect(stage.accessibility.focus(second), isTrue);
    expect(stage.focus, same(second));

    final legacyInput = TextField()..type = TextFieldType.INPUT;
    stage.addChild(legacyInput);
    stage.focus = legacyInput;
    expect(web.document.activeElement, same(canvas));
    expect(stage.focus, same(legacyInput));
    expect(stage.accessibility.focus(second), isTrue);

    parent.alpha = 0;
    await flushSemantics();
    expect(buttons(), isEmpty);
    expect(stage.focus, isNull);

    parent.alpha = 1;
    await flushSemantics();
    stage.focus = second;
    expect(web.document.activeElement, same(buttons().first));
    second.removeFromParent();
    await flushSemantics();
    expect(stage.focus, isNull);
    expect(buttons().single.disabled, isTrue);
  });

  test('maps bounds and routes one native click through the display tree',
      () async {
    stage = createStage();
    final artwork = Shape()
      ..graphics.rect(0, 0, 30, 10)
      ..graphics.fillColor(Color.Black);
    final button = SimpleButton(artwork, artwork, artwork, artwork)
      ..accessibilityLabel = 'Play sound'
      ..x = 10
      ..y = 15;
    final group = Sprite()..addChild(button);
    stage.addChild(group);
    final events = <MouseEvent>[];
    button.onMouseClick.listen(events.add);
    group.onMouseClick.listen(events.add);
    await flushSemantics();

    final element = buttons().single;
    final canvasRect = canvas.getBoundingClientRect();
    final buttonRect = element.getBoundingClientRect();
    expect(buttonRect.left - canvasRect.left, closeTo(20, 0.5));
    expect(buttonRect.top - canvasRect.top, closeTo(30, 0.5));
    expect(buttonRect.width, closeTo(60, 0.5));
    expect(element.style.pointerEvents, 'none');

    element.click();
    expect(events, hasLength(2));
    expect(events.first, same(events.last));
    expect(events.first.target, same(button));
    expect(events.first.localX, 15);
    expect(events.first.stageX, 25);

    button.x = 300;
    stage.materialize(0, 0);
    expect(element.hasAttribute('hidden'), isTrue);
    expect(stage.accessibility.focus(button), isFalse);
    element.click();
    expect(events, hasLength(2));
  });

  test('announces status and releases the semantic DOM on disposal', () async {
    stage = createStage();
    RenderLoop()
      ..stop()
      ..addStage(stage);
    final button = SimpleButton()..accessibilityLabel = 'Answer';
    stage.addChild(button);
    await flushSemantics();
    final domButton = buttons().single;
    var clicks = 0;
    button.onMouseClick.listen((_) => clicks++);
    stage.accessibility.announce('Correct answer');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(overlay()!.querySelector('[role="status"]')!.textContent,
        'Correct answer');

    stage.dispose();
    expect(stage.renderLoop, isNull);
    expect(overlay(), isNull);
    expect(canvas.tabIndex, 3);
    expect(stage.accessibility.enabled, isFalse);
    domButton.click();
    expect(clicks, 0);
  });
}
