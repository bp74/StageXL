part of '../display.dart';

class _AccessibilityModal {
  _AccessibilityModal(this.dialog, this.opener, this.previousFocus);

  final DisplayObjectContainer dialog;
  final web.Element? opener;
  final InteractiveObject? previousFocus;
}

extension _AccessibilityModalManagement on AccessibilityManager {
  AccessibilityNode? get _modalNode => _nodes[_modals.lastOrNull?.dialog];

  bool _isInModal(DisplayObject object) {
    final dialog = _modals.lastOrNull?.dialog;
    return dialog == null || dialog.contains(object);
  }

  bool _isAvailableDialog(AccessibilityNode? node) =>
      node?.role == AccessibilityRole.dialog &&
      node!._element.isConnected &&
      _root.isConnected &&
      !_root.hasAttribute('hidden');

  void _syncModal({required bool recheckIsolation}) {
    _AccessibilityModal? closed;
    while (_modals.isNotEmpty && !_isAvailableDialog(_modalNode)) {
      closed = _modals.removeLast();
      _nodes[closed.dialog]?._setAttribute('aria-modal', null);
    }

    final node = _modalNode;
    if (node == null) {
      _clearModalIsolation();
    } else if (recheckIsolation || closed != null) {
      _isolateModal(node);
    }

    if (closed != null) {
      _refreshTabStops();
      _restoreModalFocus(closed);
    }
    if (node != null && !node._element.contains(_activeElement)) {
      _focusModal();
    }
  }

  void _isolateModal(AccessibilityNode node) {
    final element = node._element;
    final document = element.ownerDocument!;
    if (_modalDocument != document) {
      _clearModalIsolation();
      _modalDocument = document;
      document.addEventListener('keydown', _modalKeyListener, true.toJS);
      document.addEventListener('focusin', _modalFocusListener, true.toJS);
    }
    for (final modal in _modals) {
      _nodes[modal.dialog]?._setAttribute('aria-modal',
          identical(modal.dialog, node.displayObject) ? 'true' : null);
    }

    // Watch sibling lists along the dialog's ancestor path. Moving objects
    // inside the canvas does not require scanning the page again.
    final observer = _modalObserver ??= web.MutationObserver(
        ((JSArray<web.MutationRecord> _, web.MutationObserver __) =>
            _update(modalDomChanged: true)).toJS);
    observer.disconnect();
    final childListChanges = web.MutationObserverInit(childList: true);
    final outside = <web.Element>{};
    web.Element current = element;
    while (current != document.body && current.parentElement != null) {
      final parent = current.parentElement!;
      observer.observe(parent, childListChanges);
      for (var sibling = parent.firstElementChild;
          sibling != null;
          sibling = sibling.nextElementSibling) {
        // Keep canvas pointer input and live announcements available.
        if (sibling != current &&
            sibling != _stage._canvas &&
            sibling != _status &&
            sibling != _alert) {
          outside.add(sibling);
        }
      }
      current = parent;
    }
    _inertElements.removeWhere((element) {
      if (outside.contains(element)) return false;
      element.removeAttribute('inert');
      return true;
    });
    for (final sibling in outside) {
      if (sibling.hasAttribute('inert')) continue;
      sibling.setAttribute('inert', '');
      _inertElements.add(sibling);
    }
  }

  void _clearModalIsolation() {
    final document = _modalDocument;
    if (document == null) return;
    _modalDocument = null;
    _modalObserver?.disconnect();
    document.removeEventListener('keydown', _modalKeyListener, true.toJS);
    document.removeEventListener('focusin', _modalFocusListener, true.toJS);
    for (final element in _inertElements) {
      element.removeAttribute('inert');
    }
    _inertElements.clear();
  }

  void _restoreModalFocus(_AccessibilityModal modal) {
    final previous = modal.previousFocus;
    final previousNode = _nodes[previous];
    if (_canFocus(previousNode)) {
      previousNode!._element.focus();
      return;
    }

    final opener = modal.opener;
    if (opener != null &&
        opener.isConnected &&
        opener.isA<web.HTMLElement>() &&
        (_modals.isEmpty || _modalNode?._element.contains(opener) == true)) {
      if (opener == _stage._canvas && previous?.stage == _stage) {
        _stage._focus = previous;
      }
      (opener as web.HTMLElement).focus();
    } else if (_modals.isEmpty && _stage._canvas.isConnected) {
      _stage._focus = null;
      _stage._canvas.focus();
    }
  }

  void _focusModal() {
    final modal = _modalNode;
    if (!_isAvailableDialog(modal)) return;
    final first = _modalTabStops.firstOrNull;
    if (first == null) {
      _stage._focus = null;
      modal!._element.focus();
    } else {
      first._element.focus();
    }
  }

  Iterable<AccessibilityNode> get _modalTabStops =>
      _orderedNodes.where((node) =>
          node._isControl && _canFocus(node) && node._element.tabIndex == 0);

  void _keepModalFocus(web.Event event) {
    final modal = _modalNode;
    if (!_isAvailableDialog(modal) ||
        modal!._element.contains(_activeElement)) {
      return;
    }
    _focusModal();
  }

  void _handleModalTab(web.KeyboardEvent event) {
    if (event.key != 'Tab' || !_isAvailableDialog(_modalNode)) return;
    final entries = _modalTabStops.toList();
    event.preventDefault();
    if (entries.isEmpty) {
      _focusModal();
      return;
    }
    final index = entries.indexWhere((node) => node._element == _activeElement);
    final next = index == -1
        ? (event.shiftKey ? entries.last : entries.first)
        : entries[(index + (event.shiftKey ? -1 : 1)) % entries.length];
    next._element.focus();
  }
}
