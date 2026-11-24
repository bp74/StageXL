part of '../display.dart';

/// Maintains the native HTML semantics for a [Stage], independent of rendering.
class AccessibilityManager {
  AccessibilityManager._(this._stage, {required bool enabled})
      : _enabled = enabled {
    if (!enabled) return;
    _canvasTabIndex = _stage._canvas.getAttribute('tabindex');
    _stage._canvas.tabIndex = -1;

    _root
      ..setAttribute('data-stagexl-accessibility', '')
      ..style.position = 'absolute'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.zIndex = '1'
      ..style.pointerEvents = 'none';
    final style = web.HTMLStyleElement()
      ..textContent = '''
[data-stagexl-accessibility] button:focus {
  outline: 2px solid black;
  box-shadow: 0 0 0 4px white;
}
''';
    _root
      ..append(style)
      ..append(_tree)
      ..append(_status)
      ..append(_alert);
    web.window.addEventListener('scroll', _viewportListener, true.toJS);
    web.window.addEventListener('resize', _viewportListener);
    if (env.isResizeObserverSupported) {
      _resizeObserver = web.ResizeObserver(
          ((JSArray<web.ResizeObserverEntry> _, web.ResizeObserver __) =>
              _update()).toJS)
        ..observe(_stage._canvas);
    }
  }

  final Stage _stage;
  bool _enabled;
  bool _dirty = false;
  bool _updating = false;
  String? _canvasTabIndex;
  Timer? _politeAnnouncement;
  Timer? _assertiveAnnouncement;
  web.ResizeObserver? _resizeObserver;

  late final web.HTMLDivElement _root = web.HTMLDivElement();
  late final web.HTMLDivElement _tree = web.HTMLDivElement();
  late final web.HTMLDivElement _status = _liveRegion('status');
  late final web.HTMLDivElement _alert = _liveRegion('alert');
  final Map<DisplayObject, AccessibilityNode> _nodes = Map.identity();

  /// Whether the stage has an active accessibility manager.
  bool get enabled => _enabled;

  /// The current node for [object], if it is exposed by this stage.
  AccessibilityNode? nodeFor(DisplayObject object) {
    if (!enabled) return null;
    _update();
    final node = _nodes[object];
    return _isExposed(node) ? node : null;
  }

  /// Gives an exposed control browser and StageXL keyboard focus.
  /// Returns false if the control cannot receive focus.
  bool focus(InteractiveObject object) {
    if (!enabled) return false;
    _update();
    final node = _nodes[object];
    if (!_canFocus(node)) return false;
    _stage._focus = object;
    node!._element.focus();
    return node._element == _activeElement;
  }

  /// Sends a message to assistive technology. Use [assertive] for messages
  /// that should interrupt the current announcement.
  void announce(String message, {bool assertive = false}) {
    if (!enabled) return;
    final region = assertive ? _alert : _status;
    region.textContent = '';
    // Leaving the region empty briefly allows the same message to be repeated.
    if (assertive) {
      _assertiveAnnouncement?.cancel();
      _assertiveAnnouncement = Timer(
          const Duration(milliseconds: 50), () => region.textContent = message);
    } else {
      _politeAnnouncement?.cancel();
      _politeAnnouncement = Timer(
          const Duration(milliseconds: 50), () => region.textContent = message);
    }
  }

  static web.HTMLDivElement _liveRegion(String role) => web.HTMLDivElement()
    ..setAttribute('role', role)
    ..setAttribute('aria-atomic', 'true')
    ..style.position = 'absolute'
    ..style.width = '1px'
    ..style.height = '1px'
    ..style.overflow = 'hidden'
    ..style.setProperty('clip-path', 'inset(50%)');

  web.Element? get _activeElement =>
      _stage._canvas.ownerDocument?.activeElement;

  late final JSFunction _viewportListener = ((web.Event _) => _update()).toJS;

  void _markDirty() {
    if (!enabled || _dirty) return;
    _dirty = true;
    scheduleMicrotask(() {
      if (_dirty) _update();
    });
  }

  void _update() {
    if (!enabled || _updating) return;
    _updating = true;
    final canvas = _stage._canvas;
    final active = _activeElement;
    final focusedObject = _stage._focus;
    final hadDomFocus =
        active != null && _nodes[focusedObject]?._element == active;
    try {
      if (!canvas.isConnected) {
        _root.remove();
        return;
      }
      if (canvas.nextSibling != _root) {
        canvas.parentNode!.insertBefore(_root, canvas.nextSibling);
      }

      if (canvas.clientWidth != _stage.stageWidth ||
          canvas.clientHeight != _stage.stageHeight) {
        _stage._updateCanvasSize();
      }

      final hide = !_isVisible(_stage) ||
          canvas.clientWidth == 0 ||
          canvas.clientHeight == 0 ||
          web.window.getComputedStyle(canvas).visibility != 'visible';
      _root.toggleAttribute('hidden', hide);

      if (_dirty) {
        _dirty = false;
        _reconcile();
      }
      if (!hide && _nodes.isNotEmpty) _updateBounds(canvas);
    } finally {
      _updating = false;
      if (hadDomFocus && identical(_stage._focus, focusedObject)) {
        final focused = _nodes[focusedObject];
        if (_canFocus(focused)) {
          if (focused!._element != _activeElement) focused._element.focus();
        } else {
          (active as web.HTMLElement).blur();
          _stage._focus = null;
        }
      }
    }
  }

  void _reconcile() {
    final stage = _stage;
    _setStageAttribute('role', stage.accessible ? 'group' : null);
    _setStageAttribute(
        'aria-label', stage.accessible ? stage.accessibilityLabel : null);
    _setStageAttribute('aria-description',
        stage.accessible ? stage.accessibilityDescription : null);

    final visited = Set<DisplayObject>.identity();
    final children = <AccessibilityNode>[];
    if (stage.accessibilityChildren && _isVisible(stage)) {
      _collectChildren(stage, visited, children);
    }
    _placeChildren(_tree, children);
    _nodes.removeWhere((object, node) {
      if (visited.contains(object)) return false;
      node._dispose();
      return true;
    });
  }

  void _setStageAttribute(String name, String? value) {
    if (_tree.getAttribute(name) == value) return;
    if (value == null) {
      _tree.removeAttribute(name);
    } else {
      _tree.setAttribute(name, value);
    }
  }

  void _collectChildren(DisplayObjectParent<DisplayObject> parent,
      Set<DisplayObject> visited, List<AccessibilityNode> siblings) {
    final children = parent.children;
    if (!children.any((child) => child.accessibilityOrder != null)) {
      for (final child in children) {
        _collect(child, visited, siblings);
      }
      return;
    }

    final indices = List<int>.generate(parent.numChildren, (index) => index);
    indices.sort((a, b) {
      final orderA = parent.getChildAt(a).accessibilityOrder ?? 0;
      final orderB = parent.getChildAt(b).accessibilityOrder ?? 0;
      final order = orderA.compareTo(orderB);
      return order != 0 ? order : a.compareTo(b);
    });
    for (final index in indices) {
      _collect(parent.getChildAt(index), visited, siblings);
    }
  }

  void _collect(DisplayObject object, Set<DisplayObject> visited,
      List<AccessibilityNode> siblings) {
    if (!_isVisible(object) || object.hasNativeAccessibility) return;
    final interactive = object is InteractiveObject ? object : null;
    final role = object.accessibilityRole ??
        (interactive?.focusable == true
            ? AccessibilityRole.button
            : AccessibilityRole.text);
    final label = object.accessible ? _labelFor(object, role) : null;
    final expose =
        object.accessible && (role != AccessibilityRole.text || label != null);
    AccessibilityNode? group;
    if (expose) {
      visited.add(object);
      var node = _nodes[object];
      if (node == null || node.role != role) {
        node?._dispose();
        node = _nodes[object] = AccessibilityNode._(object, role, this);
      }
      node._update(label, _nonEmpty(object.accessibilityDescription));
      siblings.add(node);
      if (role == AccessibilityRole.button) return;
      if (role == AccessibilityRole.group) group = node;
    }

    final children = group == null ? siblings : <AccessibilityNode>[];
    if (object.accessibilityChildren &&
        object is DisplayObjectParent<DisplayObject>) {
      _collectChildren(object, visited, children);
    }
    if (group != null) _placeChildren(group._element, children);
  }

  static void _placeChildren(
      web.Element parent, List<AccessibilityNode> children) {
    final elements = children.map((node) => node._element).toSet();
    web.Node? next;
    for (final node in children.reversed) {
      final element = node._element;
      var following = element.nextSibling;
      // Ignore nodes that will be moved or removed during reconciliation.
      while (following != null && !elements.contains(following)) {
        following = following.nextSibling;
      }
      if (element.parentNode != parent || following != next) {
        parent.insertBefore(element, next);
      }
      next = element;
    }
  }

  static bool _isVisible(DisplayObject object) =>
      object.visible && !object.off && object.alpha > 0;

  static String? _nonEmpty(String? text) {
    final trimmed = text?.trim();
    return trimmed == '' ? null : trimmed;
  }

  static String? _buttonLabel(DisplayObject object) {
    final text = <String>[];
    final source = object is SimpleButton ? object.upState : object;
    if (source != null) _collectButtonText(source, text);
    return _nonEmpty(text.join(' '));
  }

  static String? _labelFor(DisplayObject object, AccessibilityRole role) =>
      _nonEmpty(object.accessibilityLabel) ??
      _nonEmpty(object.accessibilityText) ??
      (role == AccessibilityRole.button ? _buttonLabel(object) : null);

  static void _collectButtonText(DisplayObject object, List<String> text) {
    if (!_isVisible(object) || object.hasNativeAccessibility) return;
    if (object.accessible &&
        object.accessibilityRole == AccessibilityRole.text) {
      final label = _nonEmpty(object.accessibilityLabel) ??
          _nonEmpty(object.accessibilityText);
      if (label != null) text.add(label);
    }
    if (object is DisplayObjectParent<DisplayObject>) {
      for (final child in object.children) {
        _collectButtonText(child, text);
      }
    }
  }

  void _updateBounds(web.HTMLCanvasElement canvas) {
    final rect = canvas.getBoundingClientRect();
    final root = _root.getBoundingClientRect();
    final content = _stage._contentRectangle;
    if (rect.width <= 0 ||
        rect.height <= 0 ||
        root.width <= 0 ||
        root.height <= 0 ||
        content.isEmpty ||
        canvas.offsetWidth == 0 ||
        canvas.offsetHeight == 0) {
      return;
    }

    final canvasScaleX = rect.width / canvas.offsetWidth;
    final canvasScaleY = rect.height / canvas.offsetHeight;
    final scaleX =
        canvasScaleX * canvas.clientWidth / content.width / root.width;
    final scaleY =
        canvasScaleY * canvas.clientHeight / content.height / root.height;
    final left =
        (rect.left + canvas.clientLeft * canvasScaleX - root.left) / root.width;
    final top =
        (rect.top + canvas.clientTop * canvasScaleY - root.top) / root.height;
    final toCss = Matrix(scaleX, 0, 0, scaleY, left - content.left * scaleX,
        top - content.top * scaleY);
    for (final node in _nodes.values) {
      final object = node.displayObject;
      if (object is SimpleButton && node.role == AccessibilityRole.button) {
        // Button artwork is outside the display list and may change on its own.
        node._setLabel(_labelFor(object, node.role));
      }
      node._updateBounds(_stage, content, toCss);
    }
  }

  bool _isExposed(AccessibilityNode? node) =>
      node != null &&
      _root.isConnected &&
      !_root.hasAttribute('hidden') &&
      !node._element.hasAttribute('hidden');

  bool _canFocus(AccessibilityNode? node) =>
      _isExposed(node) && node!._focusable;

  void _syncFocus() {
    if (!enabled || _updating) return;
    _update();
    final target = _stage._focus;
    final node = _nodes[target];
    final active = _activeElement;
    if (_canFocus(node)) {
      if (node!._element != active) node._element.focus();
    } else if (active != null && _root.contains(active)) {
      if (target == null) {
        (active as web.HTMLElement).blur();
      } else {
        // Preserve the canvas keyboard route for legacy display objects.
        _stage._canvas.focus();
      }
    }
  }

  void _onFocus(AccessibilityNode node) {
    if (_canFocus(node)) {
      _stage._focus = node.displayObject as InteractiveObject;
    }
  }

  void _onBlur(AccessibilityNode node) {
    if (!_updating && identical(_stage._focus, node.displayObject)) {
      _stage._focus = null;
    }
  }

  void _onKeyEvent(web.KeyboardEvent event) {
    // Native button activation and tab traversal have their own browser defaults.
    if (event.key == 'Enter' || event.key == ' ' || event.key == 'Tab') return;
    _stage._onKeyEvent(event);
  }

  void _activate(AccessibilityNode node) {
    _update();
    final object = node.displayObject;
    if (object is InteractiveObject &&
        identical(_nodes[object], node) &&
        _isExposed(node) &&
        object._isAccessibilityActionEnabled) {
      object.accessibilityActivate();
    }
  }

  void _dispose() {
    if (!enabled) return;
    _enabled = false;
    _dirty = false;
    _politeAnnouncement?.cancel();
    _assertiveAnnouncement?.cancel();
    _resizeObserver?.disconnect();
    web.window.removeEventListener('scroll', _viewportListener, true.toJS);
    web.window.removeEventListener('resize', _viewportListener);
    for (final node in _nodes.values) {
      node._dispose();
    }
    _nodes.clear();
    _root.remove();

    final canvas = _stage._canvas;
    if (canvas.getAttribute('tabindex') == '-1') {
      if (_canvasTabIndex == null) {
        canvas.removeAttribute('tabindex');
      } else {
        canvas.setAttribute('tabindex', _canvasTabIndex!);
      }
    }
  }
}
