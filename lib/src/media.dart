library stagexl.media;

import 'dart:async';
import 'dart:html';
import 'dart:html' as html;
import 'dart:math' as math;

import 'dart:html' show AudioElement;

import 'dart:web_audio' show AudioContext, AudioBuffer, AudioBufferSourceNode,
    AudioNode, GainNode, PannerNode, DynamicsCompressorNode, ChannelSplitterNode,
    ChannelMergerNode;

part 'media/sound.dart';
part 'media/sound_channel.dart';
part 'media/sound_load_options.dart';
part 'media/sound_mixer.dart';
part 'media/sound_transform.dart';
part 'media/implementation/audio_element_mixer.dart';
part 'media/implementation/audio_element_sound.dart';
part 'media/implementation/audio_element_sound_channel.dart';
part 'media/implementation/mock_sound.dart';
part 'media/implementation/mock_sound_channel.dart';
part 'media/implementation/web_audio_api_mixer.dart';
part 'media/implementation/web_audio_api_sound.dart';
part 'media/implementation/web_audio_api_sound_channel.dart';


