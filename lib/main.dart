import 'package:flutter/material.dart';
import 'package:novel_text_searcher/manager.dart';
import 'package:novel_text_searcher/model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novel Searcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements NovelManagerDelegate {
  List<String> novels= [];
  final novelManager = NovelManager();
  final searchInputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    novelManager.delegate = this;
    novelManager.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchInputController,
          onSubmitted: (text){
            novels.clear();
            novelManager.search(text);
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: novels.map((e) => ListTile(
            subtitle: Text(e),
          )).toList(),
        )
      ),
    );
  }

  @override
  void onOnceSearchFinish(Novel novel, List<String> results) {
    // TODO: implement onOnceSearchFinish
    print("${results.length} results.length");
    setState(() {
      novels.addAll(results);
    });
  }
}
