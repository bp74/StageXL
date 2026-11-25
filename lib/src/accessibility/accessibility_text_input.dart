part of '../display.dart';

// The editing API shared by HTMLInputElement and HTMLTextAreaElement.
extension type _NativeTextControl(JSObject _) implements JSObject {
  external String get value;
  external set value(String value);
  external int get maxLength;
  external int? get selectionStart;
  external int? get selectionEnd;
  external String? get selectionDirection;
  external void setSelectionRange(int start, int end, String direction);
}

/// Bridges the canvas model to a native editor that handles keyboard editing.
class _AccessibilityTextInput {
  _AccessibilityTextInput(this.field)
      : multiline = field.multiline && !field.displayAsPassword,
        password = field.displayAsPassword;

  final TextField field;
  final bool multiline;
  final bool password;
  bool _handlingInput = false;
  String? _compositionStart;

  bool get _needsReplacement =>
      multiline != (field.multiline && !field.displayAsPassword) ||
      password != field.displayAsPassword;

  // A stage embedded in a form owns its own input and Enter handling.
  late final web.HTMLElement element = (multiline
      ? (web.HTMLTextAreaElement()..style.resize = 'none')
      : (web.HTMLInputElement()..type = password ? 'password' : 'text'))
    ..setAttribute('form', '');

  _NativeTextControl get _control => _NativeTextControl(element);

  List<StreamSubscription<Object?>> _listen() => [
        const web.EventStreamProvider<web.InputEvent>('beforeinput')
            .forTarget(element)
            .listen(_beforeInput),
        element.onInput.listen((_) => _readValue()),
        element.onSelect.listen((_) => _readSelection()),
        const web.EventStreamProvider<web.Event>('selectionchange')
            .forTarget(element)
            .listen((_) => _readSelection()),
        const web.EventStreamProvider<web.Event>('compositionstart')
            .forTarget(element)
            .listen((_) => _compositionStart = field.text),
        const web.EventStreamProvider<web.Event>('compositionend')
            .forTarget(element)
            .listen((_) => _finishComposition()),
      ];

  void _beforeInput(web.InputEvent event) {
    // Let StageXL listeners veto an insertion before the browser applies it.
    if (event.isComposing || _compositionStart != null) return;
    final text = event.data ??
        event.dataTransfer?.getData('text/plain') ??
        (event.inputType == 'insertLineBreak' ? '\n' : null);
    if (text == null || text.isEmpty) return;
    final input = TextEvent(TextEvent.TEXT_INPUT, true, text);
    field.dispatchEvent(input);
    if (input.isDefaultPrevented) event.preventDefault();
  }

  void _readValue() {
    final value = _control.value;
    final changed = field.text != value;
    _handlingInput = true;
    try {
      if (changed) field.text = value;
      _readSelection();
    } finally {
      _handlingInput = false;
    }
    // Show provisional IME text on the canvas and notify the activity at commit.
    if (changed && _compositionStart == null) {
      field.dispatchEvent(Event(Event.CHANGE, true));
    }
  }

  void _finishComposition() {
    final previous = _compositionStart;
    if (previous == null) return;
    _readValue();
    _compositionStart = null;
    if (previous != field.text) field.dispatchEvent(Event(Event.CHANGE, true));
  }

  void _readSelection() {
    final text = field.text;
    final value = _control.value;
    if (value != text && value != _normalize(text)) return;
    final nativeStart = _control.selectionStart ?? 0;
    final nativeEnd = _control.selectionEnd ?? nativeStart;
    final start = value == text ? nativeStart : _modelOffset(text, nativeStart);
    final end = value == text ? nativeEnd : _modelOffset(text, nativeEnd);
    if (_control.selectionDirection == 'backward') {
      field.setSelection(end, start);
    } else {
      field.setSelection(start, end);
    }
  }

  void _sync() {
    final control = _control;
    if (field.maxChars <= 0) {
      if (control.maxLength != -1) element.removeAttribute('maxlength');
    } else if (control.maxLength != field.maxChars) {
      element.setAttribute('maxlength', '${field.maxChars}');
    }
    // Writing the DOM value during composition can cancel the IME session.
    if (_handlingInput || _compositionStart != null) return;

    // HTML normalizes line endings. Convert offsets together with the value.
    final text = field.text;
    final currentValue = control.value;
    final value = currentValue == text ? text : _normalize(text);
    if (currentValue != value) control.value = value;
    final start = text == value
        ? field.selectionStart
        : _normalize(text.substring(0, field.selectionStart)).length;
    final end = text == value
        ? field.selectionEnd
        : _normalize(text.substring(0, field.selectionEnd)).length;
    final direction =
        field.caretIndex < field.selectionEnd ? 'backward' : 'forward';
    if (control.selectionStart != start ||
        control.selectionEnd != end ||
        (start != end && control.selectionDirection != direction)) {
      control.setSelectionRange(start, end, direction);
    }
  }

  static final _carriageReturn = RegExp(r'\r\n?');
  static final _lineBreak = RegExp(r'[\r\n]');

  String _normalize(String text) => multiline
      ? text.replaceAll(_carriageReturn, '\n')
      : text.replaceAll(_lineBreak, '');

  int _modelOffset(String text, int nativeOffset) {
    var visible = 0;
    for (var offset = 0; offset < text.length; offset++) {
      if (visible == nativeOffset) return offset;
      final code = text.codeUnitAt(offset);
      if (multiline || (code != 13 && code != 10)) visible++;
      if (code == 13 &&
          offset + 1 < text.length &&
          text.codeUnitAt(offset + 1) == 10) {
        offset++;
      }
    }
    return text.length;
  }
}
