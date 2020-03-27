import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ttsservice extends BackgroundAudioTask {
  FlutterTts flutterTts = FlutterTts();

  @override
  Future<void> onStart() async {
    _speak();
  }

  Future _speak() async {
    var result = await flutterTts.speak('''
        // Your custom dart code to start audio playback.
        // NOTE: The background audio task will shut down
        // as soon as this async function completes.''');
    print(result);
  }

  @override
  void onStop() {
    print('stop');
    // Your custom dart code to stop audio playback.
  }

  @override
  void onPlay() {
    print('onPlay');
    // Your custom dart code to resume audio playback.
  }

  @override
  void onPause() {
    print('onPause');
    // Your custom dart code to pause audio playback.
  }

  @override
  void onClick(MediaButton button) {
    print(button.index);
    // Your custom dart code to handle a media button click.
  }
}
