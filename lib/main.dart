import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<String> list = [];
  var player = AudioPlayer();
  final playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [
      // AudioSource.uri(Uri.parse('https://example.com/track1.mp3')),
      // AudioSource.uri(Uri.parse('https://example.com/track2.mp3')),
      // AudioSource.uri(Uri.parse('https://example.com/track3.mp3')),
    ],
  );

  TextEditingController _controller = TextEditingController();
  int _currentPlayIndex = 0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSp();
    init();
    player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.ready:
          print("aaaaa  ");
          setState(() {
            _currentPlayIndex = player.currentIndex ?? 0;
          });
          break;
      }
    });
  }

  Future<void> initSp() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> init() async {
    await player.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
    list = prefs.getStringList('play_list') ?? [];
    list.forEach((element) {
      playlist.add(AudioSource.uri(Uri.parse(element)));
    });
  }

  void _add(String url) async{
    playlist.add(AudioSource.uri(Uri.parse(url)));
    list.add(url);
    _controller.text = "";
    await prefs.setStringList('play_list', list);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 360,
              child: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      player.play();
                    },
                    child: const Text(
                      "播放",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      player.pause();
                    },
                    child: const Text(
                      "暂停",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      list.clear();
                      playlist.clear();
                      setState(() {});
                    },
                    child: const Text(
                      "清空列表",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.text = "";
                      setState(() {});
                    },
                    child: const Text(
                      "清空输入框",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    player.seek(Duration.zero, index: index);
                  },
                  child: Row(
                    children: [
                      Text(
                        "$index",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: Text(
                          "${list[index]}",
                          style: TextStyle(
                              color: index == _currentPlayIndex
                                  ? Colors.green
                                  : Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: list.length,
            )),
            TextField(
              controller: _controller,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.text.isNotEmpty) {
            _add(_controller.text);
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
