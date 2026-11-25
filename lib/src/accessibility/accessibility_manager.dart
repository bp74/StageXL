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
[data-stagexl-accessibility] :is(button, input, textarea):focus {
  outline: 2px solid black;
  box-shadow: 0 0 0 4px white;
}
[data-stagexl-accessibility] :is(input, textarea)::selection {
  background: transparent;
  color: transparent;
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
  final List<AccessibilityNode> _orderedNodes = [];
  final List<_AccessibilityModal> _modals = [];
  final Set<web.Element> _inertElements = {};
  web.Document? _modalDocument;
  web.MutationObserver? _modalObserver;

  /// Whether the field currently uses the browser's native editing behavior.
  bool hasNativeTextFocus(TextField field) {
    final node = _nodes[field];
    return node?._textInput != null && node!._element == _activeElement;
  }

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
    node!._element.focus();
    if (node._element != _activeElement) return false;
    _stage._focus = object;
    return true;
  }

  /// Opens a semantic modal for an accessible [AccessibilityRole.dialog].
  /// [initialFocus] may specify a control within it. Otherwise the first tab
  /// stop, or the dialog itself, receives focus. Call [closeModal] when the
  /// activity dismisses the dialog.
  bool openModal(DisplayObjectContainer dialog,
      {InteractiveObject? initialFocus}) {
    if (!enabled || _modals.any((modal) => modal.dialog == dialog)) {
      return false;
    }
    _update();
    final node = _nodes[dialog];
    if (node == null || !_isAvailableDialog(node)) return false;
    _modals.add(_AccessibilityModal(dialog, _activeElement, _stage._focus));
    _refreshTabStops();
    _isolateModal(node);
    final initial = _nodes[initialFocus];
    if (_canFocus(initial)) initial!._element.focus();
    if (!node._element.contains(_activeElement)) _focusModal();
    return true;
  }

  /// Closes the active modal and restores focus to its opener when available.
  bool closeModal(DisplayObjectContainer dialog) {
    if (!enabled || _modals.lastOrNull?.dialog != dialog) return false;
    final modal = _modals.removeLast();
    _nodes[dialog]?._setAttribute('aria-modal', null);
    _clearModalIsolation();
    _refreshTabStops();
    if (_modalNode case final node?) _isolateModal(node);
    _restoreModalFocus(modal);
    if (_modalNode?._element.contains(_activeElement) == false) _focusModal();
    return true;
  }

  late final JSFunction _modalKeyListener = _handleModalTab.toJS;
  late final JSFunction _modalFocusListener = _keepModalFocus.toJS;

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

  void _update({bool modalDomChanged = false}) {
    if (!enabled || _updating) return;
    _updating = true;
    final canvas = _stage._canvas;
    final active = _activeElement;
    final focusedObject = _stage._focus;
    final hadDomFocus =
        active != null && _nodes[focusedObject]?._element == active;
    var semanticsChanged = false;
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
      final visibilityChanged = _root.hasAttribute('hidden') != hide;
      if (visibilityChanged) _root.toggleAttribute('hidden', hide);

      semanticsChanged = _dirty;
      if (semanticsChanged) {
        _dirty = false;
        _reconcile();
      }
      // Animated objects can cross the viewport without a display tree change.
      final controlVisibilityChanged =
          !hide && _nodes.isNotEmpty && _updateBounds(canvas);
      if (semanticsChanged || visibilityChanged || controlVisibilityChanged) {
        _refreshTabStops();
      }
    } finally {
      _updating = false;
      // Reparenting or replacing an element can blur it during reconciliation.
      if (hadDomFocus && identical(_stage._focus, focusedObject)) {
        final focused = _nodes[focusedObject];
        if (_canFocus(focused)) {
          if (focused!._element != _activeElement) focused._element.focus();
        } else {
          (active as web.HTMLElement).blur();
          _stage._focus = null;
        }
      }
      if (_modals.isNotEmpty) {
        _syncModal(recheckIsolation: semanticsChanged || modalDomChanged);
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

    _orderedNodes.clear();
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
      Set<DisplayObject> visited, List<AccessibilityNode> siblings,
      [AccessibilityNode? composite]) {
    final children = parent.children;
    if (!children.any((child) => child.accessibilityOrder != null)) {
      for (final child in children) {
        _collect(child, visited, siblings, composite);
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
      _collect(parent.getChildAt(index), visited, siblings, composite);
    }
  }

  void _collect(DisplayObject object, Set<DisplayObject> visited,
      List<AccessibilityNode> siblings, AccessibilityNode? composite) {
    if (!_isVisible(object) || object.hasNativeAccessibility) return;
    final interactive = object is InteractiveObject ? object : null;
    final role = object.accessibilityRole ??
        (interactive?.focusable == true
            ? AccessibilityRole.button
            : AccessibilityRole.text);
    final label = object.accessible ? _labelFor(object, role) : null;
    final expose = object.accessible &&
        (role != AccessibilityRole.text || label != null) &&
        (role != AccessibilityRole.textInput || object is TextField);
    AccessibilityNode? group;
    if (expose) {
      visited.add(object);
      var node = _nodes[object];
      if (node == null ||
          node.role != role ||
          node._textInput?._needsReplacement == true) {
        node?._dispose();
        final input = role == AccessibilityRole.textInput
            ? _AccessibilityTextInput(object as TextField)
            : null;
        node = _nodes[object] = AccessibilityNode._(object, role, this, input);
      }
      node._group = switch (composite?.role) {
        AccessibilityRole.radioGroup when role == AccessibilityRole.radio =>
          composite,
        AccessibilityRole.listBox when role == AccessibilityRole.option =>
          composite,
        _ => null,
      };
      _orderedNodes.add(node);
      node._update(label, _nonEmpty(object.accessibilityDescription));
      siblings.add(node);
      if (node._isControl) return;
      if (role._isGroup) group = node;
      if (role == AccessibilityRole.radioGroup ||
          role == AccessibilityRole.listBox) {
        composite = node;
      }
    }

    final children = group == null ? siblings : <AccessibilityNode>[];
    if (object.accessibilityChildren &&
        object is DisplayObjectParent<DisplayObject>) {
      _collectChildren(object, visited, children, composite);
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
      (role._isAction ? _buttonLabel(object) : null);

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

  // Returns whether a control crossed the edge of the visible stage.
  bool _updateBounds(web.HTMLCanvasElement canvas) {
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
      return false;
    }

    // Account for CSS scaling on the canvas and its ancestors.
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
    var visibilityChanged = false;
    for (final node in _nodes.values) {
      final object = node.displayObject;
      if (object is SimpleButton && node.role._isAction) {
        // Button artwork is outside the display list and may change on its own.
        node._setLabel(_labelFor(object, node.role));
      }
      if (node._updateBounds(_stage, content, toCss)) visibilityChanged = true;
    }
    return visibilityChanged;
  }

  bool _isExposed(AccessibilityNode? node) =>
      node != null &&
      _root.isConnected &&
      !_root.hasAttribute('hidden') &&
      !node._outsideViewport &&
      _isInModal(node.displayObject);

  bool _canFocus(AccessibilityNode? node) =>
      _isExposed(node) && node!._focusable;

  void _syncFocus() {
    if (!enabled || _updating) return;
    _update();
    final target = _stage._focus;
    if (_modals.isNotEmpty && (target == null || !_isInModal(target))) {
      _focusModal();
      return;
    }
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
      if (node._group != null) _refreshTabStops();
    }
  }

  void _onBlur(AccessibilityNode node) {
    if (!_updating && identical(_stage._focus, node.displayObject)) {
      _stage._focus = null;
      if (node._group != null) _refreshTabStops();
    }
  }

  void _refreshTabStops() {
    final groups = <AccessibilityNode, List<AccessibilityNode>>{};
    for (final node in _orderedNodes) {
      if (!node._isControl) continue;
      final group = node._group;
      final tabStop = node._tabEnabled && _isExposed(node);
      if (group == null || !tabStop) {
        node._setTabStop(tabStop);
      } else {
        (groups[group] ??= []).add(node);
      }
    }
    // Each composite has one tab stop. Arrow keys move focus within it.
    final active = _activeElement;
    for (final entries in groups.values) {
      final focused = entries.where((node) => node._element == active);
      final selected = entries.where((node) {
        final control = node.displayObject as InteractiveObject;
        return node.role == AccessibilityRole.radio
            ? control.accessibilityChecked == true
            : control.accessibilitySelected == true;
      });
      final current =
          focused.firstOrNull ?? selected.firstOrNull ?? entries.first;
      for (final node in entries) {
        node._setTabStop(node == current);
      }
    }
  }

  void _onKeyEvent(AccessibilityNode node, web.KeyboardEvent event) {
    if (event.type == 'keydown' &&
        node._group != null &&
        _navigateGroup(node, event.key)) {
      event.preventDefault();
      return;
    }
    if (event.key == 'Tab') return;
    if (node._textInput case final input?) {
      if (event.type == 'keyup') input._readSelection();
      _stage._onKeyEvent(event, nativeEditing: true);
    } else if (event.key != 'Enter' && event.key != ' ') {
      // Native buttons already turn Enter and Space into a click.
      _stage._onKeyEvent(event);
    }
  }

  bool _navigateGroup(AccessibilityNode node, String key) {
    final delta = switch (key) {
      'ArrowLeft' || 'ArrowUp' => -1,
      'ArrowRight' || 'ArrowDown' => 1,
      'Home' || 'End' => 0,
      _ => null,
    };
    if (delta == null) return false;
    final candidates = _orderedNodes
        .where((item) =>
            item._group == node._group && item._tabEnabled && _isExposed(item))
        .toList();
    if (candidates.isEmpty) return true;
    final index = candidates.indexOf(node);
    final next = switch (key) {
      'Home' => candidates.first,
      'End' => candidates.last,
      _ => candidates[(max(index, 0) + delta) % candidates.length],
    };
    next._element.focus();
    if (next != node && node.role == AccessibilityRole.radio) _activate(next);
    return true;
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
    _modals.clear();
    _clearModalIsolation();
    _politeAnnouncement?.cancel();
    _assertiveAnnouncement?.cancel();
    _resizeObserver?.disconnect();
    web.window.removeEventListener('scroll', _viewportListener, true.toJS);
    web.window.removeEventListener('resize', _viewportListener);
    for (final node in _nodes.values) {
      node._dispose();
    }
    _nodes.clear();
    _orderedNodes.clear();
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
