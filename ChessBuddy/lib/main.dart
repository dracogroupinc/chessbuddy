import 'package:flutter/material.dart';
import 'chesstabbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool bQuited = false;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        home: ChessTabBar(),

    );

  }

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    //WidgetsBinding.instance!.addObserver(this);
  }

  /*
  //WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance!.addObserver(this);



  @override
  void dispose() {
    if (!bQuited){
      //stockfish.stdin = 'quit';
      //sleep(const Duration(milliseconds:500));
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {

    }
  }

   */

}
