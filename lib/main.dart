import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flushbar/flushbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube_player/youtube_player.dart';

import 'commands.dart';
import 'permissions.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Videogator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cc = CommandController();
  SpeechToText _speech = SpeechToText();
  // FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _transcription = '';
  VideoPlayerController _videoController;
  // String _source = "8Yx3klr2bXk";
  String _source = "s59UjW8ZcRY";

  @override
  void initState() {
    askForPermissions();
    _speech.initialize(onStatus: (status) {
      print('[Speech Status]: $status');
    }, onError: (error) {
      print('[Speech Error]: ${error.toString()}');
    });

    cc.stream.listen((cmd) {
      if (cmd.id.isEmpty) {
        return;
      }
      if (cmd.id.contains('stop') || cmd.id.contains('pause')) {
        info('Video Paused');
        _videoController.pause();
      } else if (cmd.id.contains('play') ||
          cmd.id.contains('start') ||
          cmd.id.contains('go')) {
        info('Video Started');
        _videoController.play();
      } else if (cmd.id.contains('go backwards 10 seconds')) {
        info('Backward 5s');
        seek(Duration(seconds: -5));
      } else if (cmd.id.contains('forward')) {
        info('Forward 10s');
        forward();
      } else if (cmd.id.contains('back')) {
        info('Backward 10s');
        back();
      } else {
        error('Unrecognized Command', cmd.id);
      }
    });
    super.initState();
  }

  void info(String message) {
    Flushbar(
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      leftBarIndicatorColor: Colors.blue[300],
      // flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(seconds: 2),
      animationDuration: Duration(seconds: 0),
      margin: EdgeInsets.fromLTRB(8, 8, 8, 60),
      borderRadius: 8,
    ).show(context);
    // _tts.speak('$title. $message');
    // FlushbarHelper.createInformation(
    //   title: title,
    //   message: message,
    // ).show(context);
  }

  void error(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.red[300],
      ),
      leftBarIndicatorColor: Colors.red[300],
      // flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(seconds: 2),
      animationDuration: Duration(seconds: 0),
      margin: EdgeInsets.fromLTRB(8, 8, 8, 60),
      borderRadius: 8,
    ).show(context);
    // _tts.speak('$title. $message');
    // FlushbarHelper.createError(
    //   title: title,
    //   message: message,
    // ).show(context);
  }

  void seek(Duration timeDelta) {
    print('[seek delta] ' + timeDelta.inSeconds.toString());
    setState(() {
      _videoController.seekTo(_videoController.value.position + timeDelta);
    });
  }

  void onResultHandler(SpeechRecognitionResult result) {
    setState(() {
      _transcription = result.recognizedWords;
      if (result.finalResult) {
        _isListening = false;
        cc.sink.add(transformToCommand(_transcription));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height - 50,
                  child: YoutubePlayer(
                    context: context,
                    source: _source,
                    quality: YoutubeQuality.HD,
                    // aspectRatio: 16 / 9,
                    autoPlay: false,
                    // loop: false,
                    reactToOrientationChange: false,
                    startFullScreen: false,
                    controlsActiveBackgroundOverlay: true,
                    controlsTimeOut: Duration(seconds: 2),
                    playerMode: YoutubePlayerMode.DEFAULT,
                    callbackController: (controller) {
                      _videoController = controller;
                    },
                    onError: (error) {
                      print(error);
                    },
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     IconButton(
            //       icon: Icon(Icons.arrow_back),
            //       onPressed: () => back(),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.arrow_forward),
            //       onPressed: () => forward(),
            //     )
            //   ],
            // ),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
                  child: SizedBox(
                    height: 20.0,
                    width: 30.0,
                    child: SpinKitWave(
                      color: _isListening ? Colors.red : Colors.transparent,
                      size: 20.0,
                    ),
                  ),
                ),
                Text(_transcription),
                Spacer(),
                FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.search),
                  onPressed: () => _displayDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    child: Icon(_isListening ? Icons.cancel : Icons.mic),
                    onPressed: () {
                      if (!_isListening) {
                        _speech.listen(onResult: onResultHandler);
                      }
                      setState(() {
                        _isListening = !_isListening;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController _textFieldController = TextEditingController();

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Youtube Video / URL"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  print('OK');
                  setState(() {
                    _source = _textFieldController.text;
                    _textFieldController.clear();
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  print('CANCEL');
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void forward() => seek(Duration(seconds: 10));

  void back() => seek(Duration(seconds: -10));
}
