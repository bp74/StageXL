part of '../display.dart';

/// The semantic information associated with a [DisplayObject].
class AccessibilityProperties {
  AccessibilityProperties._(this._owner);

  final DisplayObject _owner;
  bool _accessible = false;
  String? _label;
  String? _description;
  AccessibilityRole? _role;
  bool _includeChildren = true;
  int? _order;

  /// Whether the object contributes its own node to the accessibility tree.
  bool get accessible => _accessible;
  set accessible(bool value) {
    if (_accessible == value) return;
    _accessible = value;
    _owner.invalidateAccessibility();
  }

  /// The name read by assistive technology.
  String? get label => _label;
  set label(String? value) {
    if (_label == value) return;
    _label = value;
    _owner.invalidateAccessibility();
  }

  /// Additional information read after the name.
  String? get description => _description;
  set description(String? value) {
    if (_description == value) return;
    _description = value;
    _owner.invalidateAccessibility();
  }

  AccessibilityRole? get role => _role;
  set role(AccessibilityRole? value) {
    if (_role == value) return;
    _role = value;
    _owner.invalidateAccessibility();
  }

  /// Whether descendants can contribute their own nodes.
  bool get includeChildren => _includeChildren;
  set includeChildren(bool value) {
    if (_includeChildren == value) return;
    _includeChildren = value;
    _owner.invalidateAccessibility();
  }

  /// Reading order among display siblings. Unspecified values sort as zero.
  /// Display order breaks ties.
  int? get order => _order;
  set order(int? value) {
    if (_order == value) return;
    _order = value;
    _owner.invalidateAccessibility();
  }
}
