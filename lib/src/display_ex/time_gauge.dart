part of '../display_ex.dart';

/// A [Gauge] specially designed to work in combination with the [Juggler].
///
/// The [TimeGauge] class implements the [Animatable] interface and therefore
/// can be added to the [Juggler]. The ratio of the gauge will automatically
/// be adjusted according to the time that has passed. This is useful for
/// time gauges used in games.
///
class TimeGauge extends Gauge implements Animatable {
  static const String TIME_OUT = 'TIME_OUT';
  static const String TIME_SHORT = 'TIME_SHORT';

  bool _isStarted = false;
  num _totalTime = 0.0;

  late Map<String, num> _alarms;
  bool alarmsEnabled = true;

  TimeGauge(num time, BitmapData bitmapData,
      [String direction = Gauge.DIRECTION_LEFT])
      : super(bitmapData, direction) {
    if (time <= 0) throw ArgumentError('Time must be greater than zero');
    _totalTime = time;
    clearAlarms();
  }

  //-------------------------------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {
    if (_isStarted && ratio > 0.0) {
      ratio = ratio - time / totalTime;
      // ignore: invariant_booleans
      if (ratio == 0.0) pause();
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
    _alarms = <String, num>{};
    addAlarm(TimeGauge.TIME_OUT, 0);
  }

  //-------------------------------------------------------------------------------------------------

  num get totalTime => _totalTime;
  bool get isStarted => _isStarted;

  num get restTime => ratio * totalTime;

  set restTime(num value) {
    ratio = value / totalTime;
  }

  num get elapsedTime => totalTime - restTime;

  set elapsedTime(num value) {
    restTime = totalTime - value;
  }

  num get elapsedRatio => 1.0 - ratio;

  set elapsedRatio(num value) {
    ratio = 1.0 - value;
  }

  @override
  set ratio(num value) {
    final oldRatio = ratio;
    super.ratio = value;
    if (alarmsEnabled) {
      _alarms.forEach((alarmName, alarmRatio) {
        if (alarmRatio < oldRatio && alarmRatio >= ratio) {
          dispatchEvent(Event(alarmName, true));
        }
      });
    }
  }
}
