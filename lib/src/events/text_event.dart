part of stagexl.events;

/// An object dispatches a [TextEvent] object when a user enters text in a text 
/// field or clicks a hyperlink in an HTML-enabled text field. 
/// 
/// There are two types of text events: 
/// 
/// * [TextEvent.LINK] 
/// * [TextEvent.TEXT_INPUT]
class TextEvent extends Event {

  static const String LINK = "link";
  static const String TEXT_INPUT = "textInput";

  //---------------------------------------------------------------------------

  /// For a [TEXT_INPUT] event, the character or sequence of characters entered 
  /// by the user. For a [LINK] event, the text of the event attribute of the 
  /// href attribute of the <a> tag.
  final String text;

  /// Creates a new [TextEvent].
  TextEvent(String type, bool bubbles, this.text) : super(type, bubbles);

  //---------------------------------------------------------------------------

  bool _isDefaultPrevented = false;

  void preventDefault() {
    _isDefaultPrevented = true;
  }

  bool get isDefaultPrevented => _isDefaultPrevented;
}
