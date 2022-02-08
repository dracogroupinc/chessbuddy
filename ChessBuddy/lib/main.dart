import 'package:flutter/material.dart';
//import 'package:stockfish/stockfish.dart';
import 'chesstabbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //late Stockfish stockfish;

  @override
  Widget build(BuildContext context) {
    //stockfish = Stockfish();

    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        //home: StockfishServiceWidget(child: ChessTabBar(stockfish: stockfish), stockfish: stockfish),
        home: StockfishServiceWidget(child: ChessTabBar()),

    );

  }

}


class StockfishServiceWidget extends StatefulWidget {
  final ChessTabBar child;
  //late Stockfish stockfish;

  //StockfishServiceWidget({required this.child, required this.stockfish});
  StockfishServiceWidget({required this.child});

  @override
  //_StockfishServiceWidgetState createState() => _StockfishServiceWidgetState(stockfish: stockfish, child: child);
  _StockfishServiceWidgetState createState() => _StockfishServiceWidgetState(child: child);
}

class _StockfishServiceWidgetState extends State<StockfishServiceWidget>
    with WidgetsBindingObserver {
  final ChessTabBar child;
  //late Stockfish stockfish;

  //_StockfishServiceWidgetState({required this.stockfish, required this.child});
  _StockfishServiceWidgetState({required this.child});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    try {
      child.disposeStockfish();
    } catch (error) {

    }

    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        try {
          //child.disposeStockfish();
        } catch (error) {
        }
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  Future<bool> didPopRoute() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}