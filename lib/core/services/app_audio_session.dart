import 'package:audio_session/audio_session.dart';

/// Owns the single native playback session shared by ambience and UI effects.
/// Serializing activation prevents the global tap sound and an ambience button
/// from racing each other on the same iOS AVAudioSession.
abstract final class AppAudioSession {
  static Future<void>? _configuration;
  static Future<void> _activationQueue = Future<void>.value();

  static Future<void> configure() => _configuration ??= () async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }();

  static Future<void> activate() {
    final operation = _activationQueue.then((_) async {
      await configure();
      final session = await AudioSession.instance;
      final active = await session.setActive(true);
      if (!active) {
        throw StateError('The device audio session is temporarily unavailable');
      }
    });
    _activationQueue = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }
}
