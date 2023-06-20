import 'dart:async';

import 'package:flutter/services.dart';

import 'lot_values/lot_value.dart';

class LottieController {
  late int id;
  late MethodChannel _channel;
  late EventChannel _playFinished;

  LottieController(int id) {
    this.id = id;
    _channel = new MethodChannel('de.lotum/lottie_native_$id');
    _playFinished =
        EventChannel('de.lotum/lottie_native_stream_play_finished_$id');
  }

  Future<void> setLoopAnimation(bool loop) async {
    return _channel.invokeMethod('setLoopAnimation', {"loop": loop});
  }

  Future<void> setAutoReverseAnimation(bool reverse) async {
    return _channel
        .invokeMethod('setAutoReverseAnimation', {"reverse": reverse});
  }

  Future<void> play() async {
    return _channel.invokeMethod('play');
  }

  Future<void> playWithProgress({
    double? fromProgress,
    required double toProgress,
  }) async {
    return _channel.invokeMethod('playWithProgress', {
      "fromProgress": fromProgress,
      "toProgress": toProgress,
    });
  }

  Future<void> playWithFrames({int? fromFrame, required int toFrame}) async {
    return _channel.invokeMethod('playWithFrames', {
      "fromFrame": fromFrame,
      "toFrame": toFrame,
    });
  }

  Future<void> stop() async {
    return _channel.invokeMethod('stop');
  }

  Future<void> pause() async {
    return _channel.invokeMethod('pause');
  }

  Future<void> resume() async {
    return _channel.invokeMethod('resume');
  }

  Future<void> setAnimationSpeed(double speed) async {
    return _channel
        .invokeMethod('setAnimationSpeed', {"speed": speed.clamp(0.0, 1.0)});
  }

  Future<void> setAnimationProgress(double progress) async {
    return _channel.invokeMethod(
        'setAnimationProgress', {"progress": progress.clamp(0.0, 1.0)});
  }

  Future<void> setProgressWithFrame(int frame) async {
    return _channel.invokeMethod('setProgressWithFrame', {"frame": frame});
  }

  Future<double?> getAnimationDuration() async {
    return _channel.invokeMethod<double>('getAnimationDuration');
  }

  Future<double?> getAnimationProgress() async {
    return _channel.invokeMethod<double>('getAnimationProgress');
  }

  Future<double?> getAnimationSpeed() async {
    return _channel.invokeMethod<double>('getAnimationSpeed');
  }

  Future<bool?> isAnimationPlaying() async {
    return _channel.invokeMethod<bool>('isAnimationPlaying');
  }

  Future<bool?> getLoopAnimation() async {
    return _channel.invokeMethod<bool>('getLoopAnimation');
  }

  Future<bool?> getAutoReverseAnimation() async {
    return _channel.invokeMethod<bool>('getAutoReverseAnimation');
  }

  Future<void> setValue({
    required LOTValue value,
    required String keyPath,
  }) async {
    return _channel.invokeMethod('setValue', {
      "value": value.value,
      "type": value.type,
      "keyPath": keyPath,
    });
  }

  Stream<bool> get onPlayFinished {
    var animationFinished =
        _playFinished.receiveBroadcastStream().map<bool>((element) => element);
    return animationFinished;
  }
}
