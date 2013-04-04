part of stagexl;

class TimeGauge extends Gauge implements Animatable {
  
  static const String TIME_OUT = 'TIME_OUT';
  static const String TIME_SHORT = 'TIME_SHORT';

  bool _isStarted = false;
  num _currentTime = 0.0;
  num _totalTime = 0.0;

  Map<String, num> _alarms;
  bool _alarmsEnabled = true;

  TimeGauge(num time, BitmapData bitmapData, [String direction = Gauge.DIRECTION_LEFT]) : super(bitmapData, direction) {
    
    if (time <= 0)
      throw new ArgumentError('Time must be greater than zero');

    _totalTime = time;

    clearAlarms();
  }

  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time) {
    
    if (_isStarted && ratio > 0.0) {
      
      ratio = ratio - time / totalTime;

      if (ratio == 0.0)
        pause();
    }

    return true;
  }

  //-------------------------------------------------------------------------------------------------

  void start() {
    _isStarted = true;
  }

  void pause() {
    _isStarted = false;
  }

  void reset([num time = 0.0]) {
    
    pause();

    time = max(time, 0.0);

    if (time != 0.0) {
      _totalTime = time;
      clearAlarms();
    }

    ratio = 1.0;
  }

  void addAlarm(String name, num restTime) {
    
    _alarms[name] = restTime / totalTime;
  }

  void removeAlarm(String name) {
    
    _alarms.remove(name);
  }

  void clearAlarms() {
    
    _alarms = new Map<String, num>();
    addAlarm(TimeGauge.TIME_OUT, 0);
  }

  //-------------------------------------------------------------------------------------------------

  num get totalTime => _totalTime;
  bool get isStarted => _isStarted;

  bool get alarmsEnabled => _alarmsEnabled;
  void set alarmsEnabled(bool value) { _alarmsEnabled = value; }

  num get restTime => ratio * totalTime;
  void set restTime(num value) { ratio = value / totalTime; }

  num get elapsedTime => totalTime - restTime;
  void set elapsedTime(num value) { restTime = totalTime - value; }

  num get elapsedRatio => 1.0 - ratio;
  void set elapsedRatio(num value) { ratio = 1.0 - value; }

  void set ratio(num value) {
    
    num oldRatio = ratio;
    super.ratio = value;

    if (_alarmsEnabled) {
      
      _alarms.forEach((alarmName, alarmRatio) {
        if (alarmRatio < oldRatio && alarmRatio >= ratio)
          dispatchEvent(new Event(alarmName));
      });
    }
  }

}
