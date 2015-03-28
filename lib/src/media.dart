/// The sound classes make it very easy to play audio even if a browser
/// does not support the latest and greates underlying audio API.
///
/// Since browsers do support different audio codecs, the library will also
/// load the correct sample for the browser automatically. Store your audio
/// samples in the mp3, ogg and ac3 format and the library will load the
/// sample which matches your browser.
///
/// Example:
///
///     // Load the audio sample with the ResourceManager. The mp3-extension
///     // will be replaced according to the capabilities of your browser.
///
///     var resourceManager = new ResourceManager();
///     resourceManager.addSound("bingo", "bingo.mp3");
///
///     resourceManager.load().then((_) {
///       // play the bingo sample
///       resourceManager.getSound("bingo").play();
///     });
///
library stagexl.media;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'dart:html' show HttpRequest, AudioElement, VideoElement;
import 'dart:typed_data';
import 'dart:web_audio';

import 'events.dart';
import 'internal/audio_loader.dart';
import 'internal/video_loader.dart';

part 'media/sound.dart';
part 'media/sound_channel.dart';
part 'media/sound_load_options.dart';
part 'media/sound_mixer.dart';
part 'media/sound_transform.dart';
part 'media/video.dart';
part 'media/video_load_options.dart';
part 'media/implementation/audio_element_mixer.dart';
part 'media/implementation/audio_element_sound.dart';
part 'media/implementation/audio_element_sound_channel.dart';
part 'media/implementation/mock_sound.dart';
part 'media/implementation/mock_sound_channel.dart';
part 'media/implementation/web_audio_api_mixer.dart';
part 'media/implementation/web_audio_api_sound.dart';
part 'media/implementation/web_audio_api_sound_channel.dart';
