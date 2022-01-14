import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'playstockfish.dart';

class ChessTabBar extends StatefulWidget {
  const ChessTabBar({Key? key}) : super(key: key);

  @override
  _WithTabBarState createState() => _WithTabBarState();
}

class _WithTabBarState extends State<ChessTabBar> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    PlayStockfish(),
    CallsPage(),

    Center(
      child: Icon(
        Icons.camera,
        size: 150,
      ),
    ),

    Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
            labelText: 'Find contact',
            labelStyle: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: _pages,
        index: _selectedIndex,
      ),
      bottomNavigationBar: SizedBox(
          height: 50,
          child: BottomNavigationBar(
        iconSize: 20, selectedFontSize: 14.0, unselectedFontSize: 14.0,
        backgroundColor: Color(int.parse("#845fc2".substring(1, 7), radix: 16) + 0xFF000000),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_small_sharp),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      )
      )

    );
  }
}

class CallsPage extends StatelessWidget {
  const CallsPage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ColoredBox(
                color: Color(int.parse("#845fc2".substring(1, 7), radix: 16) + 0xFF000000),
                child: TabBar(

                  tabs: [
                    Tab(
                      text: 'UI Buttons',
                    ),
                    Tab(
                      text: 'Tips',
                    ),
                    /*
                  Tab(
                    text: 'Outgoing',
                  ),

                   */
                  ],
                ),
              ),
              /*
              TabBar(

                tabs: [
                  Tab(
                    text: 'UI Buttons',
                  ),
                  Tab(
                    text: 'Tips',
                  ),
                  /*
                  Tab(
                    text: 'Outgoing',
                  ),

                   */
                ],
              )

               */
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UIPage(),
            TipsPage(),
            //OutgoingPage(),

          ],
        ),
      ),
    );
  }
}

class IncomingPage extends StatefulWidget {
  @override
  _IncomingPageState createState() => _IncomingPageState();
}

class _IncomingPageState extends State<IncomingPage>
    with AutomaticKeepAliveClientMixin<IncomingPage> {
  int count = 10;

  void clear() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call_received, size: 350),
            // Text('Total incoming calls: $count',
            //     style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: clear,
      //   child: Icon(Icons.clear_all),
      // ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class OutgoingPage extends StatefulWidget {
  @override
  _OutgoingPageState createState() => _OutgoingPageState();
}

class _OutgoingPageState extends State<OutgoingPage>
    with AutomaticKeepAliveClientMixin<OutgoingPage> {
  final items = List<String>.generate(10000, (i) => "Call $i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //child: Icon(Icons.call_made_outlined, size: 350),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${items[index]}'),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MissedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.call_missed_outgoing, size: 350);
  }
}


class UIPage extends StatelessWidget {
  double buttonWidthA = 137.0;
  double buttonHeightA = 34.0;
  double buttonWidthB = 173.0;
  double buttonHeightB = 34.0;
  double buttonWidthC = 310.0;
  double buttonHeightC = 34.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            color: Color(int.parse("#cbccfe".substring(1, 7), radix: 16) + 0xFF000000),
            height: 800.0,
            alignment: Alignment.center,
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[

                Positioned(
                  top: 10,
                  left: 10,
                  height:buttonHeightC,
                  width: buttonWidthC,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      width: buttonWidthC,
                      height: buttonHeightC,
                      margin: const EdgeInsets.only(left: 0.0),

                      child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.access_time, color: Colors.white,),
                            SizedBox(width: 5),
                            Text('Stockfish Thinking Time: 3 Seconds',
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,),
                            ),

                          ],
                        ),
                      )
                  ),
                ),

                new Positioned(
                  top: 50,
                  left: 20,
                  height:200,
                  width: buttonWidthC - 10,
                  child: const Text("Tapping on this button to change how many seconds the Stockfish engine takes on one move. It's between 1-5 seconds.\n\nThe engine is stronger with longer working time.\n\nFrom our test, the engine has about 2600Elo with 3 seconds working time and about 3000Elo with 5 seconds working time.\n\nThe official 3800+Elo of Stockfish can only be achieved on much more powerful computer." ,
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),


                Positioned(
                  top: 260,
                  left: 10,
                  height:buttonHeightB,
                  width: buttonWidthB,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    width: buttonWidthB,
                    height: buttonHeightB,
                    margin: const EdgeInsets.only(left: 0.0),
                    child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.sports_volleyball, color: Colors.white,),
                              SizedBox(width: 5),
                              Text('White: Human',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 14,),

                              ),
                            ]
                        )
                    ),
                  ),
                ),

                new Positioned(
                  top: 300,
                  left: 20,
                  height:60,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping on this button to set player with white pieces as Human or Stockfish-Engine.',
                    style: TextStyle(color: Colors.black87,
                      fontSize: 14,)),
                ),


                Positioned(
                  top: 350,
                  left: 10,
                  height:buttonHeightB,
                  width: buttonWidthB,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      width: buttonWidthB,
                      height: buttonHeightB,
                      margin: const EdgeInsets.only(left: 0.0),
                      child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.sports_basketball, color: Colors.white,),
                            SizedBox(width: 5),
                            Text('Black: Stockfish',
                              style: TextStyle(color: Color(int.parse("#feab45".substring(1, 7), radix: 16) + 0xFF000000),
                                fontSize: 14,
                              ),
                            ),

                          ],
                        ),
                      )
                  ),
                ),


                new Positioned(
                  top: 390,
                  left: 20,
                  height:60,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping on this button to set player with black pieces as Human or Stockfish-Engine.',
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),

                Positioned(
                  top: 440,
                  left: 10,
                  height:buttonHeightB,
                  width: buttonWidthB,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      width: buttonWidthB,
                      height: buttonHeightB,
                      margin: const EdgeInsets.only(left: 0.0),
                      child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          //margin: const EdgeInsets.only(left: 0.0),
                          children: [
                            Icon(Icons.autorenew, color: Colors.white,),
                            SizedBox(width: 5),
                            Text('Rotate Board',
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,
                              ),
                            ),

                          ],
                        ),
                      )
                  ),
                ),


                new Positioned(
                  top: 480,
                  left: 20,
                  height:40,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping to rotate chess board.',
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),

                Positioned(
                  top: 515,
                  left: 10,
                  height:buttonHeightA,
                  width: buttonWidthA,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    width: buttonWidthA,
                    height: buttonHeightA,
                    margin: const EdgeInsets.only(left: 0.0),
                    child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.flare, color: Colors.white,),
                              SizedBox(width: 5),
                              Text('Show Hint',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 14,),
                              ),
                            ]
                        )
                    ),
                  ),
                ),

                new Positioned(
                  top: 555,
                  left: 20,
                  height:40,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping to display Hint from Stockfish engine.',
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),

                Positioned(
                  top: 590,
                  left: 10,
                  height:buttonHeightA,
                  width: buttonWidthA,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      width: buttonWidthA,
                      height: buttonHeightA,
                      margin: const EdgeInsets.only(left: 0.0),
                      child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.replay, color: Colors.white,),
                            SizedBox(width: 5),
                            Text('Step Back',
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),

                new Positioned(
                  top: 630,
                  left: 20,
                  height:40,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping to move one step backward.',
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),


                Positioned(
                  top: 665,
                  left: 10,
                  height:buttonHeightA,
                  width: buttonWidthA,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      width: buttonWidthA,
                      height: buttonHeightA,
                      margin: const EdgeInsets.only(left: 0.0),
                      child: MaterialButton(
                        splashColor: Colors.greenAccent,
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.space_dashboard_sharp, color: Colors.white,),
                            SizedBox(width: 5),
                            Text('New Game',
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),

                new Positioned(
                  top: 705,
                  left: 20,
                  height:40,
                  width: buttonWidthC - 10,
                  child: const Text('Tapping to start a new game.',
                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),
              ]),
          ),

        ],
      ),
    );
  }
}


class TipsPage extends StatelessWidget {
  double buttonWidthA = 137.0;
  double buttonHeightA = 34.0;
  double buttonWidthB = 173.0;
  double buttonHeightB = 34.0;
  double buttonWidthC = 310.0;
  double buttonHeightC = 34.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            color: Color(int.parse("#cbccfe".substring(1, 7), radix: 16) + 0xFF000000),
            height: 1000,
            alignment: Alignment.center,
            child: Stack(
                fit: StackFit.loose,
                children: <Widget>[

                  new Positioned(
                    top: 10,
                    left: 10,
                    height:1000,
                    width: buttonWidthC,
                    child: const Text(
                        "(A) Run against other apps\n\n"
                        "1. Run this app on one device and run other app on second device(Phone or PC).\n\n"
                        "2. Let's say you play white on other app, then on this app you set White as 'Stockfish' and Black as 'Human'.\n\n"
                        "3. If you play black on other app, then on this app you set Black as 'Stockfish' and White as 'Human'.\n\n"
                        "4. Rotate chess board on this app if necessary.\n\n"
                        "5. After your opponent makes a move on other app, make the same move for Human on this app.\n\n"
                        "6. After Stockfish makes a move on this app, make the same move for yourself on other app.\n\n"
                        "7. Keep transferring moves between two apps until you beat your opponent on other app:)\n\n"
                        "8. In our tests, with 5 seconds working time, this app beats apps such as 'Droidfish', 'Play Magnus' and 'Genius'.\n\n"
                        "9. If you play your friend online and try to surprise him or her with Stockfish, set working time no more than 3 seconds to not slow down the game.\n\n\n"
                        "(B) Watch online games with Stockfish\n\n"
                        "1. Start a new game on this app.\n\n"
                        "2. Set both white and black players as 'Human'.\n\n"
                        "3. Set working time to '5 seconds'.\n\n"
                        "4. Repeat every move of online game on this app.\n\n"
                        "5. At each step, use 'Show Hint' to see Stockfish's suggestion and compare online game player's move with Stockfish's move.\n\n\n"
						"(C) Start a game with a certain opening\n\n"
						"1. Start a new game.\n\n"
						"2. Set both players as 'Human'.\n\n"
						"3. Make a few moves, e.g. Queen's Gambit opening.\n\n"
						"4. Set one or both players as 'Stockfish'.\n\n"
						"5. Enjoy Stockfish's following moves.\n\n",
                        style: TextStyle(color: Colors.black87,
                          fontSize: 14,)),
                  ),


                ]),
          ),

        ],
      ),
    );
  }
}