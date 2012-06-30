class BoardEvent extends Event
{
  static final String Explosion = "Explosion";
  static final String Unlocked = "Unlocked";
  static final String Finalized = "Finalized";
  static final String Timeouted = "Timeouted";

  Map<String, Dynamic> _info;

  BoardEvent(String type, Map<String, Dynamic> info, [bool bubbles = false]) : super(type, bubbles)
  {
    _info = info;
  }

  Map<String, Dynamic> get info()
  {
    return _info;
  }
}