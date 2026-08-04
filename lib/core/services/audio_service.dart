/// Audio contract for the future real asset-backed implementation.
abstract interface class AudioService {
  Future<void> play(String id, double volume);
  Future<void> pause(String id);
  Future<void> setVolume(String id, double volume);
  Future<void> stopAll();
}

/// Safe functional mock: maintains UI state without requiring audio files.
class MockAudioService implements AudioService {
  @override
  Future<void> pause(String id) async {}

  @override
  Future<void> play(String id, double volume) async {}

  @override
  Future<void> setVolume(String id, double volume) async {}

  @override
  Future<void> stopAll() async {}
}
