import 'package:record/record.dart';


class AudioService {
static final record = AudioRecorder();

  /// start record
 static Future<void> startRecording(String filePath) async {
    if (await record.hasPermission()) {
      // Start recording to file
      await record.start(const RecordConfig(), path: filePath);
    }
    else{
      print('Permisson denied');
    }
  }

  ///stop record
  Future<void> stopRecording() async {
    await record.stop();
  }
}