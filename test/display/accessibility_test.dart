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

  // Wasm can wrap the same DOM node in distinct Dart objects.
  void expectSameNode(web.Node? actual, web.Node expected) {
    expect(actual?.isSameNode(expected), isTrue,
        reason: 'Expected the same DOM node as ${expected.nodeName}.');
  }

  Future<void> flushSemantics() => Future<void>.delayed(Duration.zero);

  web.HTMLElement element(String selector) =>
      overlay()!.querySelector(selector)! as web.HTMLElement;

  void press(web.HTMLElement target, String key, {bool shift = false}) {
    target.dispatchEvent(web.KeyboardEvent(
        'keydown',
        web.KeyboardEventInit(
            key: key, shiftKey: shift, bubbles: true, cancelable: true)));
  }

  SimpleButton control(String label, [AccessibilityRole? role]) =>
      SimpleButton()
        ..accessibilityLabel = label
        ..accessibilityRole = role ?? AccessibilityRole.button;

  Sprite group(String label, AccessibilityRole role) => Sprite()
    ..accessible = true
    ..accessibilityRole = role
    ..accessibilityLabel = label;

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
    expectSameNode(buttons().first, nativeButton);
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
    expectSameNode(buttons().last, firstElement);
    expectSameNode(web.document.activeElement, firstElement);
    expect(stage.focus, same(first));

    first.enabled = false;
    await flushSemantics();
    expect(firstElement.disabled, isTrue);
    expect(stage.focus, isNull);
    expect(stage.accessibility.focus(first), isFalse);
    expect(stage.accessibility.focus(second), isTrue);
    expect(stage.focus, same(second));

    final legacyInput = TextField()
      ..type = TextFieldType.INPUT
      ..accessible = false;
    stage.addChild(legacyInput);
    stage.focus = legacyInput;
    expectSameNode(web.document.activeElement, canvas);
    expect(stage.focus, same(legacyInput));
    expect(stage.accessibility.focus(second), isTrue);

    parent.alpha = 0;
    await flushSemantics();
    expect(buttons(), isEmpty);
    expect(stage.focus, isNull);

    parent.alpha = 1;
    await flushSemantics();
    stage.focus = second;
    expectSameNode(web.document.activeElement, buttons().first);
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
    expect(element.tabIndex, -1);
    expect(stage.accessibility.focus(button), isFalse);
    element.click();
    expect(events, hasLength(2));

    button.x = 10;
    stage.materialize(0, 0);
    expect(element.hasAttribute('hidden'), isFalse);
    expect(element.tabIndex, 0);
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

  test('syncs text and backward selection while preserving input callbacks',
      () async {
    stage = createStage();
    final field = TextField('cat')
      ..type = TextFieldType.INPUT
      ..accessibilityLabel = 'Answer'
      ..maxChars = 12
      ..setSelection(3, 1);
    stage.addChild(field);
    expect(stage.accessibility.focus(field), isTrue);
    final input = element('input') as web.HTMLInputElement;
    expect(input.value, 'cat');
    expect(input.maxLength, 12);
    expect(input.selectionStart, 1);
    expect(input.selectionEnd, 3);
    expect(input.selectionDirection, 'backward');
    expect(stage.focus, same(field));

    final offered = <String>[];
    final changes = <String>[];
    field.onTextInput.listen((event) {
      offered.add(event.text);
      if (event.text == '!') event.preventDefault();
    });
    field.addEventListener(Event.CHANGE, (_) => changes.add(field.text));
    final blocked = web.InputEvent(
        'beforeinput', web.InputEventInit(data: '!', cancelable: true));
    expect(input.dispatchEvent(blocked), isFalse);
    expect(offered, ['!']);

    input
      ..value = 'cat dog'
      ..setSelectionRange(1, 5, 'backward')
      ..dispatchEvent(web.Event('input'));
    expect(field.text, 'cat dog');
    expect(field.selectionStart, 1);
    expect(field.selectionEnd, 5);
    expect(field.caretIndex, 1);
    expect(changes, ['cat dog']);

    field
      ..text = 'new text'
      ..setSelection(2, 6)
      ..maxChars = 0;
    await flushSemantics();
    expect(input.value, 'new text');
    expect(input.selectionStart, 2);
    expect(input.selectionEnd, 6);
    expect(input.hasAttribute('maxlength'), isFalse);
    expect(changes, ['cat dog']);

    canvas.focus();
    field.dispatchEvent(TouchEvent(
        TouchEvent.TOUCH_TAP, true, 1, 1, 1, 1, false, false, false, 0, true));
    expect(stage.focus, same(field));
    expectSameNode(web.document.activeElement, input);

    field.accessibilityDisabled = true;
    await flushSemantics();
    expect(input.disabled, isTrue);
    expect(stage.focus, isNull);
  });

  test('uses native multiline editing and replaces it with a masked password',
      () async {
    stage = createStage();
    final field = TextField()
      ..type = TextFieldType.INPUT
      ..multiline = true
      ..accessibilityLabel = 'Response';
    stage.addChild(field);
    expect(stage.accessibility.focus(field), isTrue);
    final textarea = element('textarea') as web.HTMLTextAreaElement;
    var changes = 0;
    field.addEventListener(Event.CHANGE, (_) => changes++);
    textarea
      ..dispatchEvent(web.Event('compositionstart'))
      ..value = '日本\n語'
      ..setSelectionRange(4, 4)
      ..dispatchEvent(web.Event('input'));
    expect(field.text, '日本\n語');
    expect(changes, 0);
    textarea.dispatchEvent(web.Event('compositionend'));
    expect(changes, 1);

    field
      ..text = 'secret'
      ..displayAsPassword = true;
    await flushSemantics();
    final password = element('input') as web.HTMLInputElement;
    expect(password.type, 'password');
    expect(password.value, 'secret');
    expect(password.getAttribute('aria-label'), 'Response');
    expect(password.hasAttribute('value'), isFalse);
    expect(password.isConnected, isTrue);
    expectSameNode(web.document.activeElement, password);
    expect(textarea.isConnected, isFalse);
  });

  test('exposes control state and navigates composite groups in reading order',
      () async {
    stage = createStage();
    final first = control('One', AccessibilityRole.radio)
      ..accessibilityChecked = true;
    final disabled = control('Disabled', AccessibilityRole.radio)
      ..accessibilityDisabled = true;
    final last = control('Three', AccessibilityRole.radio);
    final radios = group('Choices', AccessibilityRole.radioGroup)
      ..addChild(first)
      ..addChild(disabled)
      ..addChild(last);
    final checkbox = control('Repeat', AccessibilityRole.checkbox)
      ..accessibilityChecked = true;
    final toggle = control('Mute')..accessibilityPressed = false;
    final optionA = control('A', AccessibilityRole.option);
    final optionB = control('B', AccessibilityRole.option)
      ..accessibilitySelected = true;
    final list = group('Letters', AccessibilityRole.listBox)
      ..addChild(optionA)
      ..addChild(optionB);
    stage
      ..addChild(radios)
      ..addChild(checkbox)
      ..addChild(toggle)
      ..addChild(list);
    last.onMouseClick.listen((_) {
      first.accessibilityChecked = false;
      last.accessibilityChecked = true;
    });
    var optionActivations = 0;
    optionA.onMouseClick.listen((_) => optionActivations++);
    await flushSemantics();

    final firstDom = element('[aria-label="One"]');
    final lastDom = element('[aria-label="Three"]');
    expect(firstDom.tabIndex, 0);
    expect(lastDom.tabIndex, -1);
    expect(stage.accessibility.focus(first), isTrue);
    press(firstDom, 'ArrowDown');
    await flushSemantics();
    expect(firstDom.getAttribute('aria-checked'), 'false');
    expect(lastDom.getAttribute('aria-checked'), 'true');
    expect(lastDom.tabIndex, 0);
    expect(stage.focus, same(last));
    expect(element('[role="checkbox"]').getAttribute('aria-checked'), 'true');
    expect(
        element('[aria-label="Mute"]').getAttribute('aria-pressed'), 'false');

    final optionDom = element('[aria-label="B"]');
    expect(optionDom.tabIndex, 0);
    expect(stage.accessibility.focus(optionB), isTrue);
    press(optionDom, 'ArrowUp');
    expect(stage.focus, same(optionA));
    expect(optionDom.getAttribute('aria-selected'), 'true');
    expect(optionActivations, 0);
  });

  test(
      'traps dialog focus, restores it on removal and preserves existing inert',
      () async {
    stage = createStage();
    final outside = web.HTMLButtonElement()..textContent = 'Outside';
    final addedWhileOpen = web.HTMLButtonElement()..textContent = 'Added later';
    final alreadyInert = web.HTMLDivElement()..inert = true;
    web.document.body!
      ..append(outside)
      ..append(alreadyInert);
    addTearDown(() {
      outside.remove();
      addedWhileOpen.remove();
      alreadyInert.remove();
    });
    final opener = control('Open');
    final cancel = control('Cancel');
    final confirm = control('Confirm');
    final dialog = group('Confirm answer', AccessibilityRole.dialog)
      ..addChild(cancel)
      ..addChild(confirm);
    stage
      ..addChild(opener)
      ..addChild(dialog);
    expect(stage.accessibility.focus(opener), isTrue);
    expect(
        stage.accessibility.openModal(dialog, initialFocus: confirm), isTrue);
    expect(stage.focus, same(confirm));
    expect(outside.inert, isTrue);
    expect(element('[role="dialog"]').getAttribute('aria-modal'), 'true');
    expect(stage.accessibility.nodeFor(opener), isNull);

    web.document.body!.append(addedWhileOpen);
    await flushSemantics();
    expect(addedWhileOpen.inert, isTrue);

    press(element('[aria-label="Confirm"]'), 'Tab');
    expect(stage.focus, same(cancel));
    press(element('[aria-label="Cancel"]'), 'Tab', shift: true);
    expect(stage.focus, same(confirm));

    dialog.removeFromParent();
    await flushSemantics();
    expect(outside.inert, isFalse);
    expect(addedWhileOpen.inert, isFalse);
    expect(alreadyInert.inert, isTrue);
    expect(stage.focus, same(opener));
    expect(element('[aria-label="Open"]').tabIndex, 0);

    stage.addChild(dialog);
    expect(stage.accessibility.openModal(dialog), isTrue);
    expect(stage.focus, same(cancel));
    final nestedButton = control('Done');
    final nested = group('Review', AccessibilityRole.dialog)
      ..addChild(nestedButton);
    dialog.addChild(nested);
    expect(stage.accessibility.openModal(nested), isTrue);
    expect(stage.focus, same(nestedButton));
    expect(element('[aria-label="Review"]').getAttribute('aria-modal'), 'true');
    expect(stage.accessibility.closeModal(nested), isTrue);
    expect(stage.focus, same(cancel));
    expect(stage.accessibility.closeModal(dialog), isTrue);
    expect(element('[role="dialog"]').hasAttribute('aria-modal'), isFalse);
    expect(stage.focus, same(opener));
  });
}
