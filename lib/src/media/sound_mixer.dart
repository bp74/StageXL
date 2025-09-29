part of '../media.dart';

class SoundMixer {
  static SoundEngine? _engineDetected;
  static SoundEngine? _engineOverride;
  static SoundTransform _soundTransform = SoundTransform();

  static WebAudioApiMixer? _webAudioApiMixer;
  static AudioElementMixer? _audioElementMixer;

  //---------------------------------------------------------------------------

  /// Get or set the [SoundEngine] that is used to load and play sounds.
  ///
  /// The engine is automatically detected based on the best engine supported
  /// by the browser. It is possible to override the detected engine with a
  /// different one. Setting the engine to `null` will switch back to the
  /// automatically detected engine.

  static SoundEngine get engine {
    _initEngine();
    return _engineOverride ?? _engineDetected!;
  }

  static set engine(SoundEngine value) {
    _engineOverride = value;
    _initEngine();
  }

  //---------------------------------------------------------------------------

  static SoundTransform get soundTransform => _soundTransform;

  static set soundTransform(SoundTransform value) {
    _initEngine();
    _soundTransform = value;
    _webAudioApiMixer?.applySoundTransform(_soundTransform);
    _audioElementMixer?.applySoundTransform(_soundTransform);
  }

  //---------------------------------------------------------------------------

  /// A helper method to unlock audio on mobile devices.
  ///
  /// Some mobile devices (like iOS) do not allow audio playback by default.
  /// Call this method in the first onTouchBegin event to unlock the website
  /// for audio playback.
  ///
  ///     stage.onTouchBegin.first.then((e) {
  ///       SoundMixer.unlockMobileAudio();
  ///     });

  static void unlockMobileAudio() {
    if (engine == SoundEngine.WebAudioApi) {
      try {
        final context = WebAudioApiMixer.audioContext;
        final source = context.createBufferSource();
        source.buffer = context.createBuffer(1, 1, 22050);
        source.connect(context.destination);
        source.start(0);
      } catch (e) {
        // There is nothing we can do :(
      }
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  static void _initEngine() {
    if (_engineDetected != null) return;

    _engineDetected = SoundEngine.AudioElement;
    _audioElementMixer = AudioElementMixer();

    if (web.window.has('AudioContext')) {
      _engineDetected = SoundEngine.WebAudioApi;
      _webAudioApiMixer = WebAudioApiMixer();
    }

    final ua = web.window.navigator.userAgent;

    if (ua.contains('IEMobile')) {
      if (ua.contains('9.0')) {
        _engineDetected = SoundEngine.Mockup;
      }
    }

    if (ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod')) {
      if (ua.contains('OS 3') || ua.contains('OS 4') || ua.contains('OS 5')) {
        _engineDetected = SoundEngine.Mockup;
      }
    }

    if (AudioLoader.supportedTypes.isEmpty) {
      _engineDetected = SoundEngine.Mockup;
    }

    print('StageXL sound engine  : $engine');
  }
}
