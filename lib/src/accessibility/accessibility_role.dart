part of '../display.dart';

/// The meaning of an object in the stage's accessibility tree.
enum AccessibilityRole {
  button,
  text,
  group,
  image,

  /// A native editor provided by an editable [TextField].
  textInput,

  checkbox,
  radio,

  /// Contains mutually exclusive [radio] controls.
  radioGroup,

  option,

  /// Contains selectable [option] controls.
  listBox,

  /// A named container usable with [AccessibilityManager.openModal].
  dialog;

  bool get _isAction => switch (this) {
        button || checkbox || radio || option => true,
        _ => false,
      };

  bool get _isGroup => switch (this) {
        group || radioGroup || listBox || dialog => true,
        _ => false,
      };

  String? get _ariaRole => switch (this) {
        group => 'group',
        image => 'img',
        checkbox => 'checkbox',
        radio => 'radio',
        radioGroup => 'radiogroup',
        option => 'option',
        listBox => 'listbox',
        dialog => 'dialog',
        _ => null,
      };
}
