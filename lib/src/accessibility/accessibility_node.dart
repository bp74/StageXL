part of '../display.dart';

/// A semantic representation of a [DisplayObject] on an accessible stage.
class AccessibilityNode {
  AccessibilityNode._(this.displayObject, this.role,
      AccessibilityManager manager, this._textInput)
      : _element = _textInput?.element ??
            (role._isAction
                ? (web.HTMLButtonElement()..type = 'button')
                : role == AccessibilityRole.text
                    ? web.HTMLSpanElement()
                    : web.HTMLDivElement()) {
    // The canvas continues to receive pointer input and draw the control.
    _element.style.pointerEvents = 'none';
    _setAttribute('role', role._ariaRole);
    if (role == AccessibilityRole.dialog) _element.tabIndex = -1;
    if (role._isGroup) return;
    _element.style
      ..position = 'absolute'
      ..boxSizing = 'border-box'
      ..margin = '0'
      ..padding = '0'
      ..border = '0'
      ..background = 'transparent'
      ..color = 'transparent'
      ..caretColor = 'transparent'
      ..overflow = 'hidden'
      ..setProperty('forced-color-adjust', 'none');

    if (_isControl) {
      _subscriptions.addAll([
        _element.onFocus.listen((_) => manager._onFocus(this)),
        _element.onBlur.listen((_) => manager._onBlur(this)),
        _element.onKeyDown.listen((event) => manager._onKeyEvent(this, event)),
        _element.onKeyUp.listen((event) => manager._onKeyEvent(this, event)),
      ]);
      if (_textInput case final input?) {
        _subscriptions.addAll(input._listen());
      } else {
        _subscriptions.addAll([
          _element.onClick.listen((_) => manager._activate(this)),
          _element.onKeyPress
              .listen((event) => manager._onKeyEvent(this, event)),
        ]);
      }
    }
  }

  final DisplayObject displayObject;
  final AccessibilityRole role;
  final web.HTMLElement _element;
  final _AccessibilityTextInput? _textInput;
  AccessibilityNode? _group;

  bool get _isControl => role._isAction || _textInput != null;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  String? _label;
  Rectangle<num>? _bounds;
  bool _focusable = false;
  bool _outsideViewport = false;

  /// The accessible name or text currently exposed by the node.
  String? get label => _label;

  void _update(String? label, String? description) {
    _setLabel(label);
    _setAttribute('aria-description', description);

    if (_isControl) {
      final object = displayObject;
      final interactive = object is InteractiveObject ? object : null;
      final disabled = !(interactive?._isAccessibilityActionEnabled ?? false);
      _focusable = !disabled && (interactive?.focusable ?? false);
      _element.toggleAttribute('disabled', disabled);

      switch (role) {
        case AccessibilityRole.checkbox:
        case AccessibilityRole.radio:
          _setAttribute(
              'aria-checked', '${interactive?.accessibilityChecked ?? false}');
        case AccessibilityRole.option:
          _setAttribute('aria-selected',
              '${interactive?.accessibilitySelected ?? false}');
        case AccessibilityRole.button:
          _setAttribute(
              'aria-pressed', interactive?.accessibilityPressed?.toString());
        default:
          break;
      }
      _textInput?._sync();
    }
  }

  bool get _tabEnabled =>
      _focusable && (displayObject as InteractiveObject).tabEnabled;

  void _setTabStop(bool value) {
    final tabIndex = value ? 0 : -1;
    if (_element.tabIndex != tabIndex) _element.tabIndex = tabIndex;
  }

  void _setLabel(String? label) {
    if (_label == label) return;
    _label = label;
    if (role == AccessibilityRole.text) {
      _element.textContent = label ?? '';
    } else {
      _setAttribute('aria-label', label);
    }
  }

  void _setAttribute(String name, String? value) {
    if (_element.getAttribute(name) == value) return;
    if (value == null) {
      _element.removeAttribute(name);
    } else {
      _element.setAttribute(name, value);
    }
  }

  bool _updateBounds(Stage stage, Rectangle<num> content, Matrix toCss) {
    if (role._isGroup) return false;
    final bounds = displayObject.getBounds(stage);
    // Give controls with no measurable artwork a visible focus indicator.
    if (_isControl) {
      if (bounds.width == 0) bounds.width = 12;
      if (bounds.height == 0) bounds.height = 12;
    }
    final visibleBounds = bounds.intersection(content);
    final hidden = _isControl && visibleBounds.isEmpty;
    final visibilityChanged = _outsideViewport != hidden;
    if (visibilityChanged) {
      _outsideViewport = hidden;
      _element.toggleAttribute('hidden', hidden);
    }
    if (visibleBounds.isEmpty) {
      visibleBounds.width = 0;
      visibleBounds.height = 0;
    }
    final cssBounds = toCss.transformRectangle(visibleBounds, visibleBounds);
    if (_bounds == cssBounds) return visibilityChanged;

    _bounds = cssBounds;
    _element.style
      ..left = '${cssBounds.left}px'
      ..top = '${cssBounds.top}px'
      ..width = '${cssBounds.width}px'
      ..height = '${cssBounds.height}px';
    return visibilityChanged;
  }

  void _dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _element.remove();
  }
}
