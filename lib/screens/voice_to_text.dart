import 'package:flutter/material.dart';
import 'package:home_automation/services/mqtt_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextPage extends StatefulWidget {
  SpeechToTextPage({Key? key, required this.mqttService}) : super(key: key);

  final MQTTService mqttService;

  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  var turnOnWords = ["turn on", "fan on", "switch on", "cool"];
  var turnOffWords = ["turn off", "switch off", "fan off"];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _startListening();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      print(_lastWords);
    });

    if (turnOnWords.contains(_lastWords.toLowerCase())) {
      widget.mqttService.publish("1");
    }

    if (turnOffWords.contains(_lastWords.toLowerCase())) {
      widget.mqttService.publish("0");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recognized command:',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Text('$_lastWords'),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            _speechEnabled
                ? 'Tap the microphone to start listening...'
                : 'Speech not available',
          ),
        ),
        FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed:
              _speechToText.isNotListening ? _startListening : _stopListening,
          child: Icon(
            _speechToText.isListening ? Icons.mic : Icons.mic_off,
            color: Colors.white,
          ),
        ),
        IconButton(
            color: Colors.white,
            onPressed:
                _speechToText.isNotListening ? _startListening : _stopListening,
            icon: Icon(
              _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
              color: Colors.white,
            ))
      ],
    );
  }
}
