part of stagexl;

class TextEvent extends Event {

  static const String LINK = "link";
  static const String TEXT_INPUT = "textInput";

  //-------------------------------------------------------------------------------------------------

  String _text = "";

  TextEvent(String type, [bool bubbles = false]) : super(type, bubbles);

  //-------------------------------------------------------------------------------------------------

  String get text => _text;
}
