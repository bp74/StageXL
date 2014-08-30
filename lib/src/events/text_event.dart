part of stagexl.events;

class TextEvent extends Event {

  static const String LINK = "link";
  static const String TEXT_INPUT = "textInput";

  //-----------------------------------------------------------------------------------------------

  final String text;

  TextEvent(String type, bool bubbles, this.text) : super(type, bubbles);
}
