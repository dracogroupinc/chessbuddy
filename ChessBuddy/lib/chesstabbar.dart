import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'playstockfish.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChessTabBar extends StatefulWidget {
  late WithTabBarState child;

  ChessTabBar({Key? key}) : super(key: key);

  void disposeStockfish() {
    //child.disposeStockfish();
  }

  @override
  WithTabBarState createState()  {
    child = WithTabBarState();
    return child;
  }
}

class WithTabBarState extends State<ChessTabBar> {
  int _selectedIndex = 0;
  int _languageIndex = 0;

  late PlayStockfish playStockfish;
  late SettingsPage settingsPage;
  late List<Widget> _pages;
  int _thinkingtimeindex = 1;

  int getThinkingTimeIndex() {
    return _thinkingtimeindex;
  }

  int getSelectedIndex() {
    return _selectedIndex;
  }

  int getLanguageIndex() {
    return _languageIndex;
  }

  void setFirstTab(){
    setState(() {
      _selectedIndex = 0;
    });
  }

  void setThinkingTimeIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _thinkingtimeindex = index;
    prefs.setInt('thinkingtimeindex', _thinkingtimeindex);
  }

  void setLanguageIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _languageIndex = index;
    prefs.setInt('languageIndex', _languageIndex);

    // update UI and help-page
    playStockfish.setLanguageIndex(_languageIndex);
  }

  void loadThinkingTimeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _thinkingtimeindex = (prefs.getInt('thinkingtimeindex') ?? 1);
    playStockfish.setThinkingTimeIndex(_thinkingtimeindex);

    _languageIndex = (prefs.getInt('languageIndex') ?? 0);
    playStockfish.setLanguageIndex(_languageIndex);
  }

  void disposeStockfish() {
    //playStockfish.disposeStockfish();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    //loadThinkingTimeIndex();
  }

  @override
  Widget build(BuildContext context) {

    playStockfish = PlayStockfish(parent: this);
    settingsPage = SettingsPage(parent: this);

    loadThinkingTimeIndex();

    _pages = <Widget>[
      playStockfish,
      settingsPage,
      HelpPage(),

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
            icon: Icon(Icons.settings),
            label: 'Setting',
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

class HelpPage extends StatelessWidget {
  const HelpPage();

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
                    //Tab(
                    //  text: 'Settings',
                    //),

                  Tab(
                    text: 'Tips',
                  ),


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

class SettingsPage extends StatefulWidget {
  late WithTabBarState parent;
  late _SettingsPageState child;

  SettingsPage({required this.parent});

  /*
  @override
  _SettingsPageState createState() => _SettingsPageState();

   */
  @override
  _SettingsPageState createState() {
    child = _SettingsPageState(parent: parent);

    return child;
  }
}

class _SettingsPageState extends State<SettingsPage> {
  late WithTabBarState parent;

  List _languages =
  ["English", "Spanish", "Indonesian", "Filipino",
    "Russian", "Vietnamese", "French", "Portuguese",
    "Turkish", "Italian", "Greek", "Korean",
    "Japanese", "Bangla", "Arabic", "Persian"];


  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentLanguage = "English";

  _SettingsPageState({required this.parent});

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    //_currentCity = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = []; //List();
    for (String city in _languages) {
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city,
            style: TextStyle(color: Colors.blue,
              fontSize: 20,),)
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    int idx = parent.getLanguageIndex();

    if (idx >= 0 && idx < _languages.length) {
      _currentLanguage = _languages[idx];
    }

    return new Container(
      color: Color(int.parse("#cbccfe".substring(1, 7), radix: 16) + 0xFF000000),
      child: new Center(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Please choose display language: ",
                style: TextStyle(color: Colors.black,
                  fontSize: 20,),),
              new Container(
                padding: new EdgeInsets.all(16.0),
              ),
              new DropdownButton(
                value: _currentLanguage,
                items: _dropDownMenuItems,
                dropdownColor: Color(int.parse("#1b415f".substring(1, 7), radix: 16) + 0xFF000000),
                onChanged: changedDropDownItem,
              )
            ],
          )
      ),
    );
  }

  void changedDropDownItem(String? selectedLanguage) {
    setState(() {
      _currentLanguage = selectedLanguage as String;
    });

    int index = 0;

    for (int i = 0; i < _languages.length; i++) {
      if (_currentLanguage == _languages[i]){
        index = i;
        break;
      }
    }

    parent.setLanguageIndex(index);
  }

}

/*
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
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


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.call_missed_outgoing, size: 350);
  }
}
*/

/*
class SettingsWidget extends StatefulWidget {
  SettingsWidget({Key key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {

  List _cities =
  ["Cluj-Napoca", "Bucuresti", "Timisoara", "Brasov", "Constanta"];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCity;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCity = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _cities) {
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city)
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new Center(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Please choose your city: "),
              new Container(
                padding: new EdgeInsets.all(16.0),
              ),
              new DropdownButton(
                value: _currentCity,
                items: _dropDownMenuItems,
                onChanged: changedDropDownItem,
              )
            ],
          )
      ),
    );
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
    });
  }

 */

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
            height: 900.0,
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

                /*
                new Positioned(
                  top: 740,
                  left: 20,
                  height:50,
                  width: buttonWidthC,
                  child: const Text(
                      "Known issue:\n\n"
                      "When this app is 'force' closed, sometimes it will not restart properly.\n\n"
                      "The app will resume running after device is turned off.\n\n",

                      style: TextStyle(color: Colors.black87,
                        fontSize: 14,)),
                ),

                 */
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
            height: 1700,
            alignment: Alignment.center,
            child: Stack(
                fit: StackFit.loose,
                children: <Widget>[

                  new Positioned(
                    top: 10,
                    left: 10,
                    height:1700,
                    width: buttonWidthC,
                    child: const Text(
                        "(A) Known issue\n\n"
                        "When this app is 'force' closed, sometimes it will not restart properly.\n\n"
                        "The app will resume working after device is turned-off / turned-on.\n\n\n"
                        "(B) Run against other apps\n\n"
                        "1. Run this app on one device and run other app on second device(Phone or PC).\n\n"
                        "2. Let's say you play white on other app, then on this app you set White as 'Stockfish' and Black as 'Human'.\n\n"
                        "3. If you play black on other app, then on this app you set Black as 'Stockfish' and White as 'Human'.\n\n"
                        "4. Rotate chess board on this app if necessary.\n\n"
                        "5. After your opponent makes a move on other app, make the same move for Human on this app.\n\n"
                        "6. After Stockfish makes a move on this app, make the same move for yourself on other app.\n\n"
                        "7. Keep transferring moves between two apps until you beat your opponent on other app:)\n\n"
                        "8. In our tests, with 5 seconds working time, this app beats apps such as 'Droidfish', 'Play Magnus' and 'Genius'.\n\n"
                        "9. If you play your friend online and try to surprise him or her with Stockfish, set working time no more than 3 seconds to not slow down the game.\n\n\n"
                        "(C) Watch online games with Stockfish\n\n"
                        "1. Start a new game on this app.\n\n"
                        "2. Set both white and black players as 'Human'.\n\n"
                        "3. Set working time to '5 seconds'.\n\n"
                        "4. Repeat every move of online game on this app.\n\n"
                        "5. At each step, use 'Show Hint' to see Stockfish's suggestion and compare online game player's move with Stockfish's move.\n\n\n"
						"(D) Start a game with a certain opening\n\n"
						"1. Start a new game.\n\n"
						"2. Set both players as 'Human'.\n\n"
						"3. Make a few moves, e.g. Queen's Gambit opening.\n\n"
						"4. Set one or both players as 'Stockfish'.\n\n"
						"5. Enjoy Stockfish's following moves.\n\n\n"
            "(E) This app is an open source project. The source files are located at:\n\n"
            "https://github.com/dracogroupinc/chessbuddy/tree/master\n\n",
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