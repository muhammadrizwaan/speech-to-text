import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textSpeech = "Press the button to start speaking";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void onListening() async{
    if(!_isListening){
      bool available = await _speech.initialize(
        onStatus: (value)=> print("onStatus $value"),
        onError: (value)=> print("onError $value"),
      );
      if(available){
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (value) => setState(() {
            _textSpeech = value.recognizedWords;
          }),

        );
      }
    }
    else{
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              color: Colors.black12,
              child: Text(
                _textSpeech,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTapDown: (detail) async{
                if(!_isListening){
                  var available = await _speech.initialize();
                  if(available){
                    setState(() {
                      _isListening = true;
                      _speech.listen(
                        onResult: (result){
                          setState(() {
                            _textSpeech = result.recognizedWords;
                            _isListening = false;
                          });
                        }
                      );
                    });
                  }
                }

              },
              onTapUp: (detail){
                setState(() {
                  _isListening = false;
                });
                _speech.stop();
              },
              child: AvatarGlow(
                animate: _isListening,
                // glowColor:Colors.green,
                glowColor:_isListening? Colors.green: Colors.transparent,
                endRadius: 80,
                duration: const Duration(microseconds: 2000),
                repeatPauseDuration: const Duration(microseconds: 100),
                repeat: _isListening,
                showTwoGlows: _isListening,
                child: Icon(_isListening? Icons.mic: Icons.mic_none),
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
