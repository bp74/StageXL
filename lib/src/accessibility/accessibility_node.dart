part of '../display.dart';

/// A semantic representation of a [DisplayObject] on an accessible stage.
class AccessibilityNode {
  AccessibilityNode._(
      this.displayObject, this.role, AccessibilityManager manager)
      : _element = switch (role) {
          AccessibilityRole.button => web.HTMLButtonElement()..type = 'button',
          AccessibilityRole.text => web.HTMLSpanElement(),
          AccessibilityRole.group => web.HTMLDivElement(),
          AccessibilityRole.image => web.HTMLDivElement(),
        } {
    _element.style.pointerEvents = 'none';

    if (role == AccessibilityRole.group) {
      _element.setAttribute('role', 'group');
      return;
    }
    if (role == AccessibilityRole.image) {
      _element.setAttribute('role', 'img');
    }
    _element.style
      ..position = 'absolute'
      ..boxSizing = 'border-box'
      ..margin = '0'
      ..padding = '0'
      ..border = '0'
      ..background = 'transparent'
      ..color = 'transparent'
      ..overflow = 'hidden'
      ..setProperty('forced-color-adjust', 'none');

    if (role == AccessibilityRole.button) {
      final element = _element as web.HTMLButtonElement;
      _subscriptions.addAll([
        element.onFocus.listen((_) => manager._onFocus(this)),
        element.onBlur.listen((_) => manager._onBlur(this)),
        element.onClick.listen((_) => manager._activate(this)),
        element.onKeyDown.listen(manager._onKeyEvent),
        element.onKeyUp.listen(manager._onKeyEvent),
        element.onKeyPress.listen(manager._onKeyEvent),
      ]);
    }
  }

  final DisplayObject displayObject;
  final AccessibilityRole role;
  final web.HTMLElement _element;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  String? _label;
  Rectangle<num>? _bounds;
  bool _focusable = false;

  /// The accessible name or text currently exposed by the node.
  String? get label => _label;

  void _update(String? label, String? description) {
    _setLabel(label);
    _setAttribute('aria-description', description);

    if (role == AccessibilityRole.button) {
      final element = _element as web.HTMLButtonElement;
      final object = displayObject;
      final interactive = object is InteractiveObject ? object : null;
      final disabled = !(interactive?._isAccessibilityActionEnabled ?? false);
      _focusable = !disabled && (interactive?.focusable ?? false);
      final tabIndex = _focusable && interactive!.tabEnabled ? 0 : -1;
      if (element.disabled != disabled) element.disabled = disabled;
      if (element.tabIndex != tabIndex) element.tabIndex = tabIndex;
    }
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

  void _updateBounds(Stage stage, Rectangle<num> content, Matrix toCss) {
    if (role == AccessibilityRole.group) return;
    final bounds = displayObject.getBounds(stage);
    // Give controls with no measurable artwork a visible focus indicator.
    if (role == AccessibilityRole.button) {
      if (bounds.width == 0) bounds.width = 12;
      if (bounds.height == 0) bounds.height = 12;
    }
    final visibleBounds = bounds.intersection(content);
    final hidden = role == AccessibilityRole.button && visibleBounds.isEmpty;
    _element.toggleAttribute('hidden', hidden);
    if (visibleBounds.isEmpty) {
      visibleBounds.width = 0;
      visibleBounds.height = 0;
    }
    final cssBounds = toCss.transformRectangle(visibleBounds, visibleBounds);
    if (_bounds == cssBounds) return;

    _bounds = cssBounds;
    _element.style
      ..left = '${cssBounds.left}px'
      ..top = '${cssBounds.top}px'
      ..width = '${cssBounds.width}px'
      ..height = '${cssBounds.height}px';
  }

  void _dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _element.remove();
  }
}
