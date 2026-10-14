import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  String selectedReciter = 'الشيخ ميثم التمار';

  AudioPlayer get player => _player;

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void setSpeed(double speed) {
    _player.setSpeed(speed);
  }
}
