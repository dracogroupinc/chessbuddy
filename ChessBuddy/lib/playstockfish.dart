import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'dart:math';

import 'package:stockfish/stockfish.dart';
import 'dart:async';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'chesstabbar.dart';

class PlayStockfish extends StatefulWidget {
  late WithTabBarState parent;

  late _PlayStockfishState child;
  bool childIsNull = true;

  PlayStockfish({required this.parent});

  void disposeStockfish() {
    if (!childIsNull){
      child.disposeStockfish();
    }

  }

  void setLanguageIndex(int index) {
    if (!childIsNull){
      child.setLanguageIndex(index);
    }
    /*
    try {
      child.setLanguageIndex(index);
    } catch (error) {
    }
*/
  }


  void setThinkingTimeIndex(int index) {
    if (!childIsNull){
      child.setThinkingTimeIndex(index);
    }

  }

  @override
  _PlayStockfishState createState() {
    child = _PlayStockfishState(parent: parent);

    childIsNull = false;

    return child;
  }
}

class _PlayStockfishState extends State<PlayStockfish>  { //with WidgetsBindingObserver{
  late WithTabBarState parent;
  int languageIndex = 0;

  var _androidAppRetain = MethodChannel("android_app_retain");

  late Stockfish stockfish;
  late StreamSubscription<String> streamSubscription;

  bool bIsFirstLoad = true;

  int whitePawnVal = 1, whiteRookVal = 2, whiteKnightVal = 3,
      whiteBishopVal = 4, whiteQueenVal = 5, whiteKingVal = 6;
  int blackPawnVal = 7, blackRookVal = 8, blackKnightVal = 9,
      blackBishopVal = 10, blackQueenVal = 11, blackKingVal = 12;

  double buttonWidthA = 0;
  double buttonHeightA = 0;
  double buttonWidthB = 0;
  double buttonHeightB = 0;
  double buttonWidthC = 0;
  double buttonHeightC = 0;

  double newGameTop = 0;
  double newGameLeft = 0;
  double stepBackTop = 0;
  double stepBackLeft = 0;
  double showHintTop = 0;
  double showHintLeft = 0;
  double rotateBoardTop = 0;
  double rotateBoardLeft = 0;
  double blackIDTop = 0;
  double blackIDLeft = 0;
  double whiteIDTop = 0;
  double whiteIDLeft = 0;
  double stockfishTimeTop = 0;
  double stockfishTimeLeft = 0;

  List<int> indexMap = List.filled(64, 0);
  List<int> pieceValuesOnBoard = List.filled(64, 0);
  List<int> UIPieceIndexOnBoard = List.filled(64, -1);

  List<List<int>> PVOnBoardHistory = List.generate(300, (i) => List.filled(64, 0), growable: false);
  List<List<int>> UIPIndexOnBoardHistory = List.generate(300, (i) => List.filled(64, -1), growable: false);

  List<int> WhiteQueenPromotion = [32, 33, 34, 35, 36];
  int numWhiteQueenPromotion = 0;
  List<int> BlackQueenPromotion = [37, 38, 39, 40, 41];
  int numBlackQueenPromotion = 0;

  List<int> nextMovetargets = List.filled(32, 0);
  int nunNextMovetargets = 0;

  List<int> pvOnBoardAttackCheck = List.filled(64, 0);
  List<int> nextAttackTargets = List.filled(32, 0);
  int nunNextAttackTargets = 0;

  bool bStartingNewGame = false;

  bool bIsFirstSelect = true;
  int firstSelRow = 0;
  int firstSelCol = 0;
  int secondSelRow = 0;
  int secondSelCol = 0;

  int transFirstRow = 0;
  int transFirstCol = 0;
  int transSecondRow = 0;
  int transSecondCol = 0;

  List<String> columnNames = ["a","b","c","d","e","f","g","h"];
  List<String> rowNames = ["1", "2", "3", "4", "5", "6", "7", "8"];

  /*
  List<String> stockfishCommands = ['go movetime 1000',
                                    'go movetime 2000',
                                    'go movetime 3000',
                                    'go movetime 4000',
                                    'go movetime 5000',
                                    'go movetime 6000'];
  List<String> stockfishThinkingTimeStrings =
                            ['Stockfish Thinking Time: 1 Second',
                             'Stockfish Thinking Time: 2 Seconds',
                             'Stockfish Thinking Time: 3 Seconds',
                             'Stockfish Thinking Time: 4 Seconds',
                             'Stockfish Thinking Time: 5 Seconds',
                             'Stockfish Thinking Time: 6 Seconds'];
  */
  List<String> stockfishCommands = [
    'go movetime 2000',
    'go movetime 3000',
    'go movetime 5000',];
  List<String> stockfishThinkingTimeStrings =
  [
    'Stockfish Thinking Time: 2 Seconds',
    'Stockfish Thinking Time: 3 Seconds',
    'Stockfish Thinking Time: 5 Seconds',
    ];
  int stockfishThinkingTimeIndex = 1;
  String stringButtAITime = 'Stockfish Thinking Time: 3 Seconds';

  //int languageIndex = 0;
  int numLanguages = 8;
  var ThinkingTimeStringsML = List.generate(8, (i) => List.filled(3, "", growable: false), growable: true);

  List<String> newGameStringsML = List.filled(8, '');
  String stringNewGame = 'New Game';

  List<String> rotateBoardStringsML = List.filled(8, '');
  String stringRotateBoard = 'Rotate Board';

  List<String> showHintStringsML = List.filled(8, '');
  String stringShowHint = 'Show Hint';

  List<String> moveBackStringsML = List.filled(8, '');
  String stringMoveBack = 'Step Back';

  List<String> movesList = List.filled(300, '');
  int numMoves = 0;
  int maxNumMoves = 290;

  bool bStockfishBusy = false;
  bool bIsWhiteMove = true;
  bool bWhiteOnBottom = true;
  bool bWhitePlayerIsHuman = true;
  bool bBlackPlayerIsHuman = false;

  bool bIsShowingHint = false;
  bool bStepBackWaiting = false;

  bool bRook0Moved = false;
  bool bRook7Moved = false;
  bool bRook56Moved = false;
  bool bRook63Moved = false;
  bool bWhiteKingMoved = false;
  bool bBlackKingMoved = false;

  int EnPassantIdx = -1;

  double invisibleLeft = -1000.0;

  double stockfishBusyTop = 0;
  double stockfishBusyLeft = -1000.0;
  double humanBusyTop = 0;
  double humanBusyLeft = -1000.0;

  double IndicatorYTop = 0;
  double IndicatorYBottom = 0;
  double IndicatorXHuman = 0;
  double IndicatorXStockfish = 0;

  List<String> whitePlayerNames = ["White: Me","White: Stockfish 14.1"];
  List<String> blackPlayerNames = ["Black: Me","Black: Stockfish 14.1"];
  String topPlayerName = 'Black: Stockfish 14.1';
  String bottomPlayerName = 'White: Me';

  List<String> whitePlayerIDs = ["White: Me","White: Stockfish"];
  List<String> blackPlayerIDs = ["Black: Me","Black: Stockfish"];
  String stringPlayerWhiteID = 'White: Me';
  String stringPlayerBlackID = 'Black: Stockfish';

  List<String> whiteStringsML = List.filled(8, '');
  List<String> blackStringsML = List.filled(8, '');
  List<String> humanStringsML = List.filled(8, '');

  Color WhiteIDColor = Colors.white;
  Color BlackIDColor = Colors.white;

  Color StockfishColor = Colors.white;
  Color HumanColor = Colors.white;

  Color TopPlayerColor = Colors.white;
  Color BottomPlayerColor = Colors.white;


  bool bRedrawArrow = false;
  double arrowX1 = 10;
  double arrowY1 = 10;
  double arrowX2 = 200;
  double arrowY2 = 200;

  bool bRedrawHint = false;
  double hintX1 = 10;
  double hintY1 = 10;
  double hintX2 = 200;
  double hintY2 = 200;

  double screenWidth = Get.width;
  double screenHeight = Get.height;

  String boardSquareColor1 = "#d0dde3";
  String boardSquareColor2 = "#799cb0";

  String boardSquareColor3 = "#ead2b2";
  String boardSquareColor4 = "#af8563";

  String boardSquareSelectColor = "#00a8f3";

  late Color sc1, sc2, sc3, sc4, sc5, sc6, sc7, sc8, sc9, sc10,
      sc11, sc12, sc13, sc14, sc15, sc16, sc17, sc18, sc19, sc20,
      sc21, sc22, sc23, sc24, sc25, sc26, sc27, sc28, sc29, sc30,
      sc31, sc32, sc33, sc34, sc35, sc36, sc37, sc38, sc39, sc40,
      sc41, sc42, sc43, sc44, sc45, sc46, sc47, sc48, sc49, sc50,
      sc51, sc52, sc53, sc54, sc55, sc56, sc57, sc58, sc59, sc60,
      sc61, sc62, sc63, sc64;
  List squareColorList = [];

  late int squareWH;
  double xStart = 10;
  double yStart = 30;

  late Container target1, target2, target3, target4, target5, target6, target7, target8, target9, target10,
            target11, target12, target13, target14, target15, target16, target17, target18, target19, target20,
            target21, target22, target23, target24, target25, target26, target27, target28, target29, target30,
            target31, target32;
  List<Container> targetsList = [];
  late Positioned targetPos1, targetPos2, targetPos3, targetPos4, targetPos5, targetPos6, targetPos7, targetPos8,
             targetPos9, targetPos10, targetPos11, targetPos12, targetPos13, targetPos14, targetPos15, targetPos16,
             targetPos17, targetPos18, targetPos19, targetPos20, targetPos21, targetPos22, targetPos23, targetPos24,
             targetPos25, targetPos26, targetPos27, targetPos28, targetPos29, targetPos30, targetPos31, targetPos32;
  List<Positioned> targetPosList = [];
  double targetTop1= 0.0, targetTop2= 0.0, targetTop3= 0.0, targetTop4= 0.0,
      targetTop5= 0.0, targetTop6= 0.0, targetTop7= 0.0, targetTop8= 0.0,
      targetTop9= 0.0, targetTop10= 0.0, targetTop11= 0.0, targetTop12= 0.0,
      targetTop13= 0.0, targetTop14= 0.0, targetTop15= 0.0, targetTop16= 0.0,
      targetTop17= 0.0, targetTop18= 0.0, targetTop19= 0.0, targetTop20= 0.0,
      targetTop21= 0.0, targetTop22= 0.0, targetTop23= 0.0, targetTop24= 0.0,
      targetTop25= 0.0, targetTop26= 0.0, targetTop27= 0.0, targetTop28= 0.0,
      targetTop29= 0.0, targetTop30= 0.0, targetTop31= 0.0, targetTop32= 0.0;
  double targetLeft1= -1000.0, targetLeft2= -1000.0, targetLeft3= -1000.0, targetLeft4= -1000.0,
      targetLeft5= -1000.0, targetLeft6= -1000.0, targetLeft7= -1000.0, targetLeft8= -1000.0,
      targetLeft9= -1000.0, targetLeft10= -1000.0, targetLeft11= -1000.0, targetLeft12= -1000.0,
      targetLeft13= -1000.0, targetLeft14= -1000.0, targetLeft15= -1000.0, targetLeft16= -1000.0,
      targetLeft17= -1000.0, targetLeft18= -1000.0, targetLeft19= -1000.0, targetLeft20= -1000.0,
      targetLeft21= -1000.0, targetLeft22= -1000.0, targetLeft23= -1000.0, targetLeft24= -1000.0,
      targetLeft25= -1000.0, targetLeft26= -1000.0, targetLeft27= -1000.0, targetLeft28= -1000.0,
      targetLeft29= -1000.0, targetLeft30= -1000.0, targetLeft31= -1000.0, targetLeft32= -1000.0;

  late Container sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, sw10,
            sw11, sw12, sw13, sw14, sw15, sw16, sw17, sw18, sw19, sw20,
            sw21, sw22, sw23, sw24, sw25, sw26, sw27, sw28, sw29, sw30,
            sw31, sw32, sw33, sw34, sw35, sw36, sw37, sw38, sw39, sw40,
            sw41, sw42, sw43, sw44, sw45, sw46, sw47, sw48, sw49, sw50,
            sw51, sw52, sw53, sw54, sw55, sw56, sw57, sw58, sw59, sw60,
            sw61, sw62, sw63, sw64, swSelect;
  List<Container> squareWidgetList = [];

  late Container piece1, piece2, piece3, piece4, piece5, piece6, piece7, piece8,
            piece9, piece10, piece11, piece12, piece13, piece14, piece15, piece16,
            piece17, piece18, piece19, piece20, piece21, piece22, piece23, piece24,
            piece25, piece26, piece27, piece28, piece29, piece30, piece31, piece32,
            piece33, piece34, piece35, piece36, piece37, piece38, piece39, piece40,
            piece41,piece42;
  List<Container> pieceList = [];

  late Positioned piecePos1, piecePos2, piecePos3, piecePos4, piecePos5, piecePos6, piecePos7, piecePos8,
             piecePos9, piecePos10, piecePos11, piecePos12, piecePos13, piecePos14, piecePos15, piecePos16,
             piecePos17, piecePos18, piecePos19, piecePos20, piecePos21, piecePos22, piecePos23, piecePos24,
             piecePos25, piecePos26, piecePos27, piecePos28, piecePos29, piecePos30, piecePos31, piecePos32,
             piecePos33, piecePos34, piecePos35, piecePos36, piecePos37, piecePos38, piecePos39, piecePos40,
             piecePos41,piecePos42;
  List<Positioned> piecePosList = [];

  double piecePositioneTop1= 0.0, piecePositioneTop2= 0.0, piecePositioneTop3= 0.0, piecePositioneTop4= 0.0,
      piecePositioneTop5= 0.0, piecePositioneTop6= 0.0, piecePositioneTop7= 0.0, piecePositioneTop8= 0.0,
      piecePositioneTop9= 0.0, piecePositioneTop10= 0.0, piecePositioneTop11= 0.0, piecePositioneTop12= 0.0,
      piecePositioneTop13= 0.0, piecePositioneTop14= 0.0, piecePositioneTop15= 0.0, piecePositioneTop16= 0.0,
      piecePositioneTop17= 0.0, piecePositioneTop18= 0.0, piecePositioneTop19= 0.0, piecePositioneTop20= 0.0,
      piecePositioneTop21= 0.0, piecePositioneTop22= 0.0, piecePositioneTop23= 0.0, piecePositioneTop24= 0.0,
      piecePositioneTop25= 0.0, piecePositioneTop26= 0.0, piecePositioneTop27= 0.0, piecePositioneTop28= 0.0,
      piecePositioneTop29= 0.0, piecePositioneTop30= 0.0, piecePositioneTop31= 0.0, piecePositioneTop32= 0.0,
      piecePositioneTop33= 0.0, piecePositioneTop34= 0.0, piecePositioneTop35= 0.0, piecePositioneTop36= 0.0,
      piecePositioneTop37= 0.0, piecePositioneTop38= 0.0, piecePositioneTop39= 0.0, piecePositioneTop40= 0.0,
      piecePositioneTop41= 0.0, piecePositioneTop42= 0.0;

  double piecePositioneLeft1= 0.0, piecePositioneLeft2= 0.0, piecePositioneLeft3= 0.0, piecePositioneLeft4= 0.0,
      piecePositioneLeft5= 0.0, piecePositioneLeft6= 0.0, piecePositioneLeft7= 0.0, piecePositioneLeft8= 0.0,
      piecePositioneLeft9= 0.0, piecePositioneLeft10= 0.0, piecePositioneLeft11= 0.0, piecePositioneLeft12= 0.0,
      piecePositioneLeft13= 0.0, piecePositioneLeft14= 0.0, piecePositioneLeft15= 0.0, piecePositioneLeft16= 0.0,
      piecePositioneLeft17= 0.0, piecePositioneLeft18= 0.0, piecePositioneLeft19= 0.0, piecePositioneLeft20= 0.0,
      piecePositioneLeft21= 0.0, piecePositioneLeft22= 0.0, piecePositioneLeft23= 0.0, piecePositioneLeft24= 0.0,
      piecePositioneLeft25= 0.0, piecePositioneLeft26= 0.0, piecePositioneLeft27= 0.0, piecePositioneLeft28= 0.0,
      piecePositioneLeft29= 0.0, piecePositioneLeft30= 0.0, piecePositioneLeft31= 0.0, piecePositioneLeft32= 0.0,
      piecePositioneLeft33= -1000.0, piecePositioneLeft34= -1000.0,
      piecePositioneLeft35= -1000.0, piecePositioneLeft36= -1000.0,
      piecePositioneLeft37= -1000.0, piecePositioneLeft38= -1000.0,
      piecePositioneLeft39= -1000.0, piecePositioneLeft40= -1000.0,
      piecePositioneLeft41= -1000.0, piecePositioneLeft42= -1000.0;

  late Positioned pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9, pos10,
      pos11, pos12, pos13, pos14, pos15, pos16, pos17, pos18, pos19, pos20,
      pos21, pos22, pos23, pos24, pos25, pos26, pos27, pos28, pos29, pos30,
      pos31, pos32, pos33, pos34, pos35, pos36, pos37, pos38, pos39, pos40,
      pos41, pos42, pos43, pos44, pos45, pos46, pos47, pos48, pos49, pos50,
      pos51, pos52, pos53, pos54, pos55, pos56, pos57, pos58, pos59, pos60,
      pos61, pos62, pos63, pos64, posSelect;
  List<Positioned> squareList = [];

  double
      squarePositioneTop1= 0.0, squarePositioneTop2= 0.0, squarePositioneTop3= 0.0, squarePositioneTop4= 0.0,
      squarePositioneTop5= 0.0, squarePositioneTop6= 0.0, squarePositioneTop7= 0.0, squarePositioneTop8= 0.0,
      squarePositioneTop9= 0.0, squarePositioneTop10= 0.0, squarePositioneTop11= 0.0, squarePositioneTop12= 0.0,
      squarePositioneTop13= 0.0, squarePositioneTop14= 0.0, squarePositioneTop15= 0.0, squarePositioneTop16= 0.0,
      squarePositioneTop17= 0.0, squarePositioneTop18= 0.0, squarePositioneTop19= 0.0, squarePositioneTop20= 0.0,
      squarePositioneTop21= 0.0, squarePositioneTop22= 0.0, squarePositioneTop23= 0.0, squarePositioneTop24= 0.0,
      squarePositioneTop25= 0.0, squarePositioneTop26= 0.0, squarePositioneTop27= 0.0, squarePositioneTop28= 0.0,
      squarePositioneTop29= 0.0, squarePositioneTop30= 0.0, squarePositioneTop31= 0.0, squarePositioneTop32= 0.0,
      squarePositioneTop33= 0.0, squarePositioneTop34= 0.0, squarePositioneTop35= 0.0, squarePositioneTop36= 0.0,
      squarePositioneTop37= 0.0, squarePositioneTop38= 0.0, squarePositioneTop39= 0.0, squarePositioneTop40= 0.0,
      squarePositioneTop41= 0.0, squarePositioneTop42= 0.0, squarePositioneTop43= 0.0, squarePositioneTop44= 0.0,
      squarePositioneTop45= 0.0, squarePositioneTop46= 0.0, squarePositioneTop47= 0.0, squarePositioneTop48= 0.0,
      squarePositioneTop49= 0.0, squarePositioneTop50= 0.0, squarePositioneTop51= 0.0, squarePositioneTop52= 0.0,
      squarePositioneTop53= 0.0, squarePositioneTop54= 0.0, squarePositioneTop55= 0.0, squarePositioneTop56= 0.0,
      squarePositioneTop57= 0.0, squarePositioneTop58= 0.0, squarePositioneTop59= 0.0, squarePositioneTop60= 0.0,
      squarePositioneTop61= 0.0, squarePositioneTop62= 0.0, squarePositioneTop63= 0.0, squarePositioneTop64= 0.0;

  double
      squarePositioneLeft1= 0.0, squarePositioneLeft2= 0.0, squarePositioneLeft3= 0.0, squarePositioneLeft4= 0.0,
      squarePositioneLeft5= 0.0, squarePositioneLeft6= 0.0, squarePositioneLeft7= 0.0, squarePositioneLeft8= 0.0,
      squarePositioneLeft9= 0.0, squarePositioneLeft10= 0.0, squarePositioneLeft11= 0.0, squarePositioneLeft12= 0.0,
      squarePositioneLeft13= 0.0, squarePositioneLeft14= 0.0, squarePositioneLeft15= 0.0, squarePositioneLeft16= 0.0,
      squarePositioneLeft17= 0.0, squarePositioneLeft18= 0.0, squarePositioneLeft19= 0.0, squarePositioneLeft20= 0.0,
      squarePositioneLeft21= 0.0, squarePositioneLeft22= 0.0, squarePositioneLeft23= 0.0, squarePositioneLeft24= 0.0,
      squarePositioneLeft25= 0.0, squarePositioneLeft26= 0.0, squarePositioneLeft27= 0.0, squarePositioneLeft28= 0.0,
      squarePositioneLeft29= 0.0, squarePositioneLeft30= 0.0, squarePositioneLeft31= 0.0, squarePositioneLeft32= 0.0,
      squarePositioneLeft33= 0.0, squarePositioneLeft34= 0.0, squarePositioneLeft35= 0.0, squarePositioneLeft36= 0.0,
      squarePositioneLeft37= 0.0, squarePositioneLeft38= 0.0, squarePositioneLeft39= 0.0, squarePositioneLeft40= 0.0,
      squarePositioneLeft41= 0.0, squarePositioneLeft42= 0.0, squarePositioneLeft43= 0.0, squarePositioneLeft44= 0.0,
      squarePositioneLeft45= 0.0, squarePositioneLeft46= 0.0, squarePositioneLeft47= 0.0, squarePositioneLeft48= 0.0,
      squarePositioneLeft49= 0.0, squarePositioneLeft50= 0.0, squarePositioneLeft51= 0.0, squarePositioneLeft52= 0.0,
      squarePositioneLeft53= 0.0, squarePositioneLeft54= 0.0, squarePositioneLeft55= 0.0, squarePositioneLeft56= 0.0,
      squarePositioneLeft57= 0.0, squarePositioneLeft58= 0.0, squarePositioneLeft59= 0.0, squarePositioneLeft60= 0.0,
      squarePositioneLeft61= 0.0, squarePositioneLeft62= 0.0, squarePositioneLeft63= 0.0, squarePositioneLeft64= 0.0;

  List<double> squarePositioneTop = List.filled(64, 0.0);
  List<double> squarePositioneLeft = List.filled(64, -1000.0);

  double selPositionTop = 0.0;
  double selPositionLeft = -1000.0;

  late Container containerButtAITime;

  _PlayStockfishState({required this.parent});

  void disposeStockfish() {
    try {
      stockfish.dispose();
    } catch (error) {

    }
  }


  void setLanguageIndex(int index) {
    if (languageIndex != index){
      languageIndex = index;

      updateDisplayLabels();
    }


    //languageIndex = index;
    //updateDisplayLabels();
  }

  void updateDisplayLabels() {
    setState(() {
      stringButtAITime = ThinkingTimeStringsML[languageIndex][stockfishThinkingTimeIndex];
      stringNewGame = newGameStringsML[languageIndex];
      stringRotateBoard = rotateBoardStringsML[languageIndex];
      stringShowHint = showHintStringsML[languageIndex];
      stringMoveBack = moveBackStringsML[languageIndex];

    });

    whitePlayerNames[0] = whiteStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    whitePlayerNames[1] = whiteStringsML[languageIndex] + ': Stockfish 14.1';

    blackPlayerNames[0] = blackStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    blackPlayerNames[1] = blackStringsML[languageIndex] + ': Stockfish 14.1';

    UpdatePlayerWhiteID();
    UpdatePlayerBlackID();

    //redisplayNames();
  }

  void setThinkingTimeIndex(int index) {
    stockfishThinkingTimeIndex = index;

    setState(() {
      stringButtAITime = ThinkingTimeStringsML[languageIndex][stockfishThinkingTimeIndex];
      stringNewGame = newGameStringsML[languageIndex];
      stringRotateBoard = rotateBoardStringsML[languageIndex];
      stringShowHint = showHintStringsML[languageIndex];
      stringMoveBack = moveBackStringsML[languageIndex];

      //UpdatePlayerWhiteID();
      //UpdatePlayerBlackID();
    });
  }

  Future<void> waitUntilReady() async {
    int numSeconds = 3;

    try {
      while (numSeconds > 0 && stockfish.state.value != StockfishState.ready) {
        await Future.delayed(Duration(seconds: 1));

        numSeconds--;
      }
    } catch (error) {

    }

  }

  Future<void> StockfishExit() async {
    await Future.delayed(Duration(seconds: 1));
    exit(0);
  }

  Future<void> LoadStockfish() async {
    stockfish = Stockfish();

    await waitUntilReady();

    streamSubscription = stockfish.stdout.listen((value) {
      if (value.startsWith('bestmove')) {
        final split = value.split(' ');
        //final Map<int, String> values = {
        //  for (int i = 0; i < split.length; i++)
        //    i: split[i]
        //};
        if (split.length >= 2) {
          //textfielsController.text = split[1];
          AINextMove(split[1]);
        }
      }
    });

  }

  Future<void> ReloadStockfish() async {
    /*
    if (bIsFirstLoad){
      bIsFirstLoad = false;

      final stockfishNew = Stockfish();

      setState(() {
        stockfish = stockfishNew;

      });

      await waitUntilReady();


      setState(() {
        streamSubscription = stockfish.stdout.listen((value) {
          if (value.startsWith('bestmove')) {
            final split = value.split(' ');
            //final Map<int, String> values = {
            //  for (int i = 0; i < split.length; i++)
            //    i: split[i]
            //};
            if (split.length >= 2) {
              //textfielsController.text = split[1];
              AINextMove(split[1]);
            }
          }
        });


      });

      return;
    }

     */

    if (stockfish.state.value == StockfishState.disposed){
      /*
      final stockfishNew = Stockfish();

      setState(() {
        stockfish = stockfishNew;

      });
      *
       */
      stockfish = Stockfish();

      await waitUntilReady();

      streamSubscription = stockfish.stdout.listen((value) {
        if (value.startsWith('bestmove')) {
          final split = value.split(' ');
          //final Map<int, String> values = {
          //  for (int i = 0; i < split.length; i++)
          //    i: split[i]
          //};
          if (split.length >= 2) {
            //textfielsController.text = split[1];
            AINextMove(split[1]);
          }
        }
      });
/*
      setState(() {
        streamSubscription = stockfish.stdout.listen((value) {
          if (value.startsWith('bestmove')) {
            final split = value.split(' ');
            //final Map<int, String> values = {
            //  for (int i = 0; i < split.length; i++)
            //    i: split[i]
            //};
            if (split.length >= 2) {
              //textfielsController.text = split[1];
              AINextMove(split[1]);
            }
          }
        });


      });

 */

    }

  }

  void UpdateBusyIndicators() {
    DisplayHint(false, 0, 0, 0, 0);

    if (bIsWhiteMove){
      if (bWhiteOnBottom){
        if (bWhitePlayerIsHuman){
          setState(() {
            humanBusyTop = IndicatorYBottom;
            humanBusyLeft = IndicatorXHuman;

            stockfishBusyLeft = invisibleLeft;
          });
        }
        else{
          setState(() {
            stockfishBusyTop = IndicatorYBottom;
            stockfishBusyLeft = IndicatorXStockfish;

            humanBusyLeft = invisibleLeft;
          });
        }
      }
      else{
        if (bWhitePlayerIsHuman){
          setState(() {
            humanBusyTop = IndicatorYTop;
            humanBusyLeft = IndicatorXHuman;

            stockfishBusyLeft = invisibleLeft;
          });
        }
        else{
          setState(() {
            stockfishBusyTop = IndicatorYTop;
            stockfishBusyLeft = IndicatorXStockfish;

            humanBusyLeft = invisibleLeft;
          });
        }
      }
    }
    else{
      if (bWhiteOnBottom){
        if (bBlackPlayerIsHuman){
          setState(() {
            humanBusyTop = IndicatorYTop;
            humanBusyLeft = IndicatorXHuman;

            stockfishBusyLeft = invisibleLeft;
          });
        }
        else{
          setState(() {
            stockfishBusyTop = IndicatorYTop;
            stockfishBusyLeft = IndicatorXStockfish;

            humanBusyLeft = invisibleLeft;
          });
        }
      }
      else{
        if (bBlackPlayerIsHuman){
          setState(() {
            humanBusyTop = IndicatorYBottom;
            humanBusyLeft = IndicatorXHuman;

            stockfishBusyLeft = invisibleLeft;
          });
        }
        else{
          setState(() {
            stockfishBusyTop = IndicatorYBottom;
            stockfishBusyLeft = IndicatorXStockfish;

            humanBusyLeft = invisibleLeft;
          });
        }
      }
    }
  }

  void PlayNextMove(){
    UpdateBusyIndicators();

    if ((bIsWhiteMove && !bWhitePlayerIsHuman) ||
        (!bIsWhiteMove && !bBlackPlayerIsHuman)){
      StartAINextMove();
    }
  }

  void stockfishThinkingTimeClick(){
    if (stockfishThinkingTimeIndex == 2){
      stockfishThinkingTimeIndex = 0;
    }
    else{
      stockfishThinkingTimeIndex++;
    }

    setState(() {
      stringButtAITime = ThinkingTimeStringsML[languageIndex][stockfishThinkingTimeIndex];
      stringNewGame = newGameStringsML[languageIndex];
      stringRotateBoard = rotateBoardStringsML[languageIndex];
      stringShowHint = showHintStringsML[languageIndex];
      stringMoveBack = moveBackStringsML[languageIndex];

      //UpdatePlayerWhiteID();
      //UpdatePlayerBlackID();
    });

    parent.setThinkingTimeIndex(stockfishThinkingTimeIndex);
  }

  void rotateBoardClick(){
    bWhiteOnBottom = !bWhiteOnBottom;

    showMoveTargets(false);
    setSelectPosition(0, invisibleLeft);

    bIsFirstSelect = true;
    RestoreMovingArrow();

    redisplayPieces();

    redisplayNames();

    UpdatePlayerColors();

    UpdateBusyIndicators();
  }

  void redisplayNames(){
    if (bWhitePlayerIsHuman){
      setState(() {
        if (bWhiteOnBottom){
          bottomPlayerName  = whitePlayerNames[0];
        }
        else{
          topPlayerName  = whitePlayerNames[0];
        }
      });

    }
    else{
      setState(() {
        if (bWhiteOnBottom){
          bottomPlayerName  = whitePlayerNames[1];
        }
        else{
          topPlayerName  = whitePlayerNames[1];
        }
      });
    }


    if (bBlackPlayerIsHuman){
      setState(() {
        if (bWhiteOnBottom){
          topPlayerName  = blackPlayerNames[0];
        }
        else{
          bottomPlayerName  = blackPlayerNames[0];
        }
      });

    }
    else{
      setState(() {
        if (bWhiteOnBottom){
          topPlayerName  = blackPlayerNames[1];
        }
        else{
          bottomPlayerName  = blackPlayerNames[1];
        }
      });
    }
  }

  void UpdatePlayerWhiteID(){
    if (bWhitePlayerIsHuman){
      setState(() {
        stringPlayerWhiteID = whiteStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];

        WhiteIDColor = HumanColor;

        if (bWhiteOnBottom){
          bottomPlayerName  = whitePlayerNames[0];
          BottomPlayerColor = HumanColor;
        }
        else{
          topPlayerName  = whitePlayerNames[0];
          TopPlayerColor = HumanColor;
        }
      });

    }
    else{
      setState(() {
        stringPlayerWhiteID = whiteStringsML[languageIndex] + ': Stockfish';
        WhiteIDColor = StockfishColor;

        if (bWhiteOnBottom){
          bottomPlayerName  = whitePlayerNames[1];
          BottomPlayerColor = StockfishColor;
        }
        else{
          topPlayerName  = whitePlayerNames[1];
          TopPlayerColor = StockfishColor;
        }
      });
    }
  }


  void playerWhiteIDClick(){
    bWhitePlayerIsHuman = !bWhitePlayerIsHuman;

    UpdatePlayerWhiteID();

    if (!bStockfishBusy){
      PlayNextMove();
    }
  }

  void playerBlackIDClick(){
    bBlackPlayerIsHuman = !bBlackPlayerIsHuman;

    UpdatePlayerBlackID();

    if (!bStockfishBusy){
      PlayNextMove();
    }
  }

  void UpdatePlayerBlackID(){
    if (bBlackPlayerIsHuman){
      setState(() {
        stringPlayerBlackID = blackStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
        BlackIDColor = HumanColor;

        if (bWhiteOnBottom){
          topPlayerName  = blackPlayerNames[0];
          TopPlayerColor = HumanColor;
        }
        else{
          bottomPlayerName  = blackPlayerNames[0];
          BottomPlayerColor = HumanColor;
        }
      });

    }
    else{
      setState(() {
        stringPlayerBlackID = blackStringsML[languageIndex] + ': Stockfish';
        BlackIDColor = StockfishColor;

        if (bWhiteOnBottom){
          topPlayerName  = blackPlayerNames[1];
          TopPlayerColor = StockfishColor;
        }
        else{
          bottomPlayerName  = blackPlayerNames[1];
          BottomPlayerColor = StockfishColor;
        }
      });
    }
  }

  void UpdatePlayerColors(){
    if (bWhitePlayerIsHuman){
      setState(() {
        WhiteIDColor = HumanColor;

        if (bWhiteOnBottom){
          BottomPlayerColor = HumanColor;
        }
        else{
          TopPlayerColor = HumanColor;
        }
      });

    }
    else{
      setState(() {
        WhiteIDColor = StockfishColor;

        if (bWhiteOnBottom){
          BottomPlayerColor = StockfishColor;
        }
        else{
          TopPlayerColor = StockfishColor;
        }
      });
    }

    if (bBlackPlayerIsHuman){
      setState(() {
        BlackIDColor = HumanColor;

        if (bWhiteOnBottom){
          TopPlayerColor = HumanColor;
        }
        else{
          BottomPlayerColor = HumanColor;
        }
      });

    }
    else{
      setState(() {
        BlackIDColor = StockfishColor;

        if (bWhiteOnBottom){
          TopPlayerColor = StockfishColor;
        }
        else{
          BottomPlayerColor = StockfishColor;
        }
      });
    }
  }

  void showHintClick(){
    DisplayHint(false, 0, 0, 0, 0);

    if (bIsWhiteMove){
      if (bWhitePlayerIsHuman){
        bIsShowingHint = true;

        StartAINextMove();
      }
    }
    else{
      if (bBlackPlayerIsHuman){
        bIsShowingHint = true;

        StartAINextMove();
      }
    }
  }

  void stepBackClick(){
    int i;

    if (bStockfishBusy){
      bStepBackWaiting = true;
      return;
    }

    DoStepBack();
  }


  void DoStepBack(){
    int i;

    if (numMoves <= 1){
      return;
    }

    bWhitePlayerIsHuman = true;
    bBlackPlayerIsHuman = true;
    redisplayNames();

    numMoves = numMoves - 1;

    ClearAllPieces();

    for (i=0; i<64; i++){
      pieceValuesOnBoard[i] = 0;
      UIPieceIndexOnBoard[i] = -1;
    }

    for (i=0; i<64; i++){
      pieceValuesOnBoard[i] = PVOnBoardHistory[numMoves - 1][i];
      UIPieceIndexOnBoard[i] = UIPIndexOnBoardHistory[numMoves - 1][i];
    }

    bRedrawArrow = false;
    redisplayPieces();

    showMoveTargets(false);
    setSelectPosition(0, invisibleLeft);

    bIsFirstSelect = true;
    RestoreMovingArrow();

    bIsWhiteMove = !bIsWhiteMove;
    UpdateBusyIndicators();

    UpdatePlayerWhiteID();
    UpdatePlayerBlackID();
    UpdatePlayerColors();

    UpdateKingRookMoved();
  }

  void UpdateKingRookMoved(){
    int col, row, idx, i, col2, row2, idx2;

    bRook0Moved = false;
    bRook7Moved = false;
    bRook56Moved = false;
    bRook63Moved = false;
    bWhiteKingMoved = false;
    bBlackKingMoved = false;

    for (i=0; i<numMoves; i++){
      col = columnIndex(movesList[i][0]);
      row = rowIndex(movesList[i][1]);

      idx = row*8 + col;

      if (idx == 0){
        bRook0Moved = true;
      }
      if (idx == 7){
        bRook7Moved = true;
      }
      if (idx == 56){
        bRook56Moved = true;
      }
      if (idx == 63){
        bRook63Moved = true;
      }
      if (idx == 4){
        bWhiteKingMoved = true;
      }
      if (idx == 60){
        bBlackKingMoved = true;
      }
    }

    EnPassantIdx = -1;

    col = columnIndex(movesList[numMoves - 1][0]);
    row = rowIndex(movesList[numMoves - 1][1]);
    idx = row*8 + col;

    col2 = columnIndex(movesList[numMoves - 1][2]);
    row2 = rowIndex(movesList[numMoves - 1][3]);
    idx2 = row2*8 + col2;

    if (pieceValuesOnBoard[idx2] == whitePawnVal){
      if (idx2 == (idx + 16)){
        EnPassantIdx = idx + 8;
      }
    }

    if (pieceValuesOnBoard[idx2] == blackPawnVal){
      if (idx2 == (idx - 16)){
        EnPassantIdx = idx - 8;
      }
    }
  }

  void RestoreMovingArrow(){
    if (numMoves <= 0){
      return;
    }

    int col1 = columnIndex(movesList[numMoves - 1][0]);
    int row1 = rowIndex(movesList[numMoves - 1][1]);
    int col2 = columnIndex(movesList[numMoves - 1][2]);
    int row2 = rowIndex(movesList[numMoves - 1][3]);

    int newIdx1 = row1*8 + col1;
    int newIdx2 = row2*8 + col2;

    if (bWhiteOnBottom){
      newIdx1 = 63 - newIdx1;
      newIdx2 = 63 - newIdx2;
    }

    int rowA = (newIdx1/8).floor();
    int colA = newIdx1 - rowA*8;

    int rowB = (newIdx2/8).floor();
    int colB = newIdx2 - rowB*8;

    colA = 7 - colA;
    colB = 7 - colB;

    DisplayMovingArrow(true, colA, rowA, colB, rowB);
  }

  void DisplayMovingArrow(bool show, int colA, int rowA, int colB, int rowB) {
    setState(() {
      bRedrawArrow = show;

      transFirstCol = colA;
      transFirstRow = rowA;
      transSecondCol = colB;
      transSecondRow = rowB;

      if (show){
        arrowX1 = xStart + (colA + 0.5)*squareWH;
        arrowY1 = yStart + (rowA + 0.5)*squareWH;
        arrowX2 = xStart + (colB + 0.5)*squareWH;
        arrowY2 = yStart + (rowB + 0.5)*squareWH;
      }

    });
  }

  void ClearAllPieces(){
    List<int> uipIdxOnBoard = List.filled(32, 0);
    int numPV = 0;
    int i, pv;

    for (i=0; i<64; i++){
      pv = pieceValuesOnBoard[i];

      if (pv != 0) {
        uipIdxOnBoard[numPV] = UIPieceIndexOnBoard[i];

        numPV++;
      }
    }

    setState(() {
      for (i=0; i<numPV; i++){
        setPiecePosition(uipIdxOnBoard[i], 0, invisibleLeft);
      }
    });
  }

  void newGameClick(){
    setState(() {
      if (bStockfishBusy) {
        bStartingNewGame = true;
      }

      numMoves = 0;

      bWhiteOnBottom = true;
      bWhitePlayerIsHuman = true;
      bBlackPlayerIsHuman = false;

      bIsWhiteMove = true;

      bIsFirstSelect = true;
      numWhiteQueenPromotion = 0;
      numBlackQueenPromotion = 0;

      bRedrawArrow = false;
      bRedrawHint = false;

      bStepBackWaiting = false;

      bRook0Moved = false;
      bRook7Moved = false;
      bRook56Moved = false;
      bRook63Moved = false;
      bWhiteKingMoved = false;
      bBlackKingMoved = false;
    });

    InitPieces();

    UpdatePlayerWhiteID();
    UpdatePlayerBlackID();

    redisplayPieces();

    redisplayNames();

    UpdateBusyIndicators();
  }

  void InitPieces(){
    int i = 0;

    for (i=0; i<64; i++){
      pieceValuesOnBoard[i] = 0;
    }

    SetIndexMap();
  }

  void ShowHideMovingArrow(bool show){
    setState(() {
      bRedrawArrow = show;

      if (show){
        arrowX1 = xStart + (transFirstCol + 0.5)*squareWH;
        arrowY1 = yStart + (transFirstRow + 0.5)*squareWH;
        arrowX2 = xStart + (transSecondCol + 0.5)*squareWH;
        arrowY2 = yStart + (transSecondRow + 0.5)*squareWH;
      }

    });
  }

  void transFirstSelSecondSel(){
    int newIdx1 = firstSelRow*8 + firstSelCol;
    int newIdx2 = secondSelRow*8 + secondSelCol;

    if (bWhiteOnBottom){
      newIdx1 = 63 - newIdx1;
      newIdx2 = 63 - newIdx2;
    }

    transFirstRow = (newIdx1/8).floor();
    transFirstCol = newIdx1 - transFirstRow*8;

    transSecondRow = (newIdx2/8).floor();
    transSecondCol = newIdx2 - transSecondRow*8;

    transFirstCol = 7 - transFirstCol;
    transSecondCol = 7 - transSecondCol;
  }

  void getValidMoveTargetsWhitePawn(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row, rowNext;

    row = (idx/8).floor();

    nextIdx = idx + 8;
    if (nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (pv1 == 0){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    if (idx < 16){
      pv1 = pieceValuesOnBoard[idx + 8];
      pv2 = pieceValuesOnBoard[idx + 16];

      if (pv1 == 0 && pv2 == 0){
        nextMovetargets[nunNextMovetargets] = idx + 16;
        nunNextMovetargets++;
      }
    }

    nextIdx = idx + 8 + 1;
    if (nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];
      rowNext = (nextIdx/8).floor();

      if (pv1 >= 7 && pv1 <= 12 && rowNext == (row + 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }

      if (pv1 == 0 && nextIdx == EnPassantIdx && rowNext == (row + 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    nextIdx = idx + 8 - 1;
    if (nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];
      rowNext = (nextIdx/8).floor();

      if (pv1 >= 7 && pv1 <= 12 && rowNext == (row + 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }

      if (pv1 == 0 && nextIdx == EnPassantIdx && rowNext == (row + 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }
  }


  void getValidMoveTargetsWhiteRook(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsWhiteKnight(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    row1 = row + 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }
  }

  void getValidMoveTargetsWhiteBishop(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsWhiteQueen(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    // Bishop moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    // Rook moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsWhiteKing(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    row1 = row + 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    // castling
    if (idx == 4){
      if (pieceValuesOnBoard[5] == 0 &&
          pieceValuesOnBoard[6] == 0 &&
          !bRook7Moved && !bWhiteKingMoved){
        //4,5,6 not under attack
        //rook-7 and king not moved
        if(!attackedByBlack(4, pieceValuesOnBoard) &&
            !attackedByBlack(5, pieceValuesOnBoard) &&
            !attackedByBlack(6, pieceValuesOnBoard)){
          nextMovetargets[nunNextMovetargets] = 6;
          nunNextMovetargets++;
        }
      }

      if (pieceValuesOnBoard[3] == 0 &&
          pieceValuesOnBoard[2] == 0 &&
          pieceValuesOnBoard[1] == 0 &&
          !bRook0Moved && !bWhiteKingMoved){
        //4,3,2,1 not under attack
        //rook-0 and king not moved
        if(!attackedByBlack(4, pieceValuesOnBoard) &&
            !attackedByBlack(3, pieceValuesOnBoard) &&
            !attackedByBlack(2, pieceValuesOnBoard) &&
            !attackedByBlack(1, pieceValuesOnBoard)){
          nextMovetargets[nunNextMovetargets] = 2;
          nunNextMovetargets++;
        }

      }
    }
  }

  void getValidMoveTargetsBlackPawn(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row, rowNext;

    row = (idx/8).floor();

    nextIdx = idx - 8;
    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (pv1 == 0){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    if (idx >= 48 && idx <= 55){
      pv1 = pieceValuesOnBoard[idx - 8];
      pv2 = pieceValuesOnBoard[idx - 16];

      if (pv1 == 0 && pv2 == 0){
        nextMovetargets[nunNextMovetargets] = idx - 16;
        nunNextMovetargets++;
      }
    }

    nextIdx = idx - 8 + 1;
    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];
      rowNext = (nextIdx/8).floor();

      if (pv1 >= 1 && pv1 <= 6 && rowNext == (row - 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }

      if (pv1 == 0 && nextIdx == EnPassantIdx && rowNext == (row - 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    nextIdx = idx - 8 - 1;
    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];
      rowNext = (nextIdx/8).floor();

      if (pv1 >= 1 && pv1 <= 6 && rowNext == (row - 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }

      if (pv1 == 0 && nextIdx == EnPassantIdx && rowNext == (row - 1)){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }
  }

  void getValidMoveTargetsBlackRook(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsBlackKnight(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    row1 = row + 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row + 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }

    row1 = row - 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextMovetargets[nunNextMovetargets] = nextIdx;
        nunNextMovetargets++;
      }
    }
  }

  void getValidMoveTargetsBlackBishop(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsBlackQueen(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    int i;

    // Bishop moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    // Rook moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pieceValuesOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextMovetargets[nunNextMovetargets] = nextIdx;
            nunNextMovetargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }
  }

  void getValidMoveTargetsBlackKing(int idx) {
    nunNextMovetargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (idx/8).floor();
    int col = idx - row*8;

    row1 = row + 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pieceValuesOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextMovetargets[nunNextMovetargets] = nextIdx;
          nunNextMovetargets++;
        }
      }
    }

    // castling
    if (idx == 60){
      if (pieceValuesOnBoard[61] == 0 &&
          pieceValuesOnBoard[62] == 0 &&
          !bRook63Moved && !bBlackKingMoved){
        if(!attackedByWhite(60, pieceValuesOnBoard) &&
            !attackedByWhite(61, pieceValuesOnBoard) &&
            !attackedByWhite(62, pieceValuesOnBoard)){
          nextMovetargets[nunNextMovetargets] = 62;
          nunNextMovetargets++;
        }
      }

      if (pieceValuesOnBoard[59] == 0 &&
          pieceValuesOnBoard[58] == 0 &&
          pieceValuesOnBoard[57] == 0 &&
          !bRook56Moved && !bBlackKingMoved){
        if(!attackedByWhite(60, pieceValuesOnBoard) &&
            !attackedByWhite(59, pieceValuesOnBoard) &&
            !attackedByWhite(58, pieceValuesOnBoard) &&
            !attackedByWhite(57, pieceValuesOnBoard)){
          nextMovetargets[nunNextMovetargets] = 58;
          nunNextMovetargets++;
        }

      }
    }
  }

  bool attackedByBlackPawn(int pawnIdx, int targetIdx, List<int> pvOnBoard) {
    int idx, row;

    int rowTarget = (targetIdx/8).floor();

    idx = pawnIdx - 8 + 1;
    row = (idx/8).floor();

    if (idx == targetIdx && row == rowTarget){
      return true;
    }

    idx = pawnIdx - 8 - 1;
    row = (idx/8).floor();

    if (idx == targetIdx && row == rowTarget){
      return true;
    }

    return false;
  }

  bool attackedByBlackKing(int kingIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (kingIdx/8).floor();
    int col = kingIdx - row*8;

    row1 = row + 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    for (int i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByBlackQueen(int queenIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (queenIdx/8).floor();
    int col = queenIdx - row*8;

    int i;

    // Bishop moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    // Rook moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByBlackBishop(int bishopIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (bishopIdx/8).floor();
    int col = bishopIdx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByBlackKnight(int knightIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (knightIdx/8).floor();
    int col = knightIdx - row*8;

    row1 = row + 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 1 && pv1 <= 6))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    for (int i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByBlackRook(int rookIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (rookIdx/8).floor();
    int col = rookIdx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 1 && pv1 <= 6)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }


  bool attackedByWhitePawn(int pawnIdx, int targetIdx, List<int> pvOnBoard) {
    int idx, row;

    int rowTarget = (targetIdx/8).floor();

    idx = pawnIdx + 8 + 1;
    row = (idx/8).floor();

    if (idx == targetIdx && row == rowTarget){
      return true;
    }

    idx = pawnIdx + 8 - 1;
    row = (idx/8).floor();

    if (idx == targetIdx && row == rowTarget){
      return true;
    }

    return false;
  }

  bool attackedByWhiteRook(int rookIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (rookIdx/8).floor();
    int col = rookIdx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByWhiteKnight(int knightIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (knightIdx/8).floor();
    int col = knightIdx - row*8;

    row1 = row + 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 2;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 2;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row + 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 1;
    col1 = col - 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    row1 = row - 1;
    col1 = col + 2;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if ((col1 >= 0 && col1 <= 7) && (pv1 == 0 || (pv1 >= 7 && pv1 <= 12))){
        nextAttackTargets[nunNextAttackTargets] = nextIdx;
        nunNextAttackTargets++;
      }
    }

    for (int i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByWhiteBishop(int bishopIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (bishopIdx/8).floor();
    int col = bishopIdx - row*8;

    int i;

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByWhiteQueen(int queenIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (queenIdx/8).floor();
    int col = queenIdx - row*8;

    int i;

    // Bishop moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    // Rook moves
    //
    for (i=1; i<8; i++){
      row1 = row + i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row - i;
      col1 = col;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col + i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=1; i<8; i++){
      row1 = row;
      col1 = col - i;
      nextIdx = 8*row1 + col1;

      if (nextIdx >= 0 && nextIdx < 64){
        pv1 = pvOnBoard[nextIdx];

        if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
          if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
            nextAttackTargets[nunNextAttackTargets] = nextIdx;
            nunNextAttackTargets++;

            if (pv1 != 0){
              break;
            }
          }
          else{
            break;
          }
        }
      }
      else{
        break;
      }
    }

    for (i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  bool attackedByWhiteKing(int kingIdx, int targetIdx, List<int> pvOnBoard) {
    nunNextAttackTargets = 0;
    int nextIdx = 0;
    int pv1 = 0, pv2 = 0;
    int row1 = 0, col1 = 0;

    int row = (kingIdx/8).floor();
    int col = kingIdx - row*8;

    row1 = row + 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row;
    col1 = col + 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row;
    col1 = col - 1;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row + 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    row1 = row - 1;
    col1 = col;
    nextIdx = 8*row1 + col1;

    if (nextIdx >= 0 && nextIdx < 64){
      pv1 = pvOnBoard[nextIdx];

      if (col1 >= 0 && col1 <= 7 && row1 >= 0 && row1 <= 7) {
        if (pv1 == 0 || (pv1 >= 7 && pv1 <= 12)){
          nextAttackTargets[nunNextAttackTargets] = nextIdx;
          nunNextAttackTargets++;
        }
      }
    }

    for (int i=0; i<nunNextAttackTargets; i++){
      if (nextAttackTargets[i] == targetIdx){
        return true;
      }
    }

    return false;
  }

  void veirfyMoveTargets(int idx){
    int i, j, k;
    List<int> newMoveTargets = List.filled(32, 0);
    int num = 0, kingIdx = 0;
    bool bIsWhite = false;

    if (pieceValuesOnBoard[idx] >= 1 && pieceValuesOnBoard[idx] <= 6){
      bIsWhite = true;
    }

    for (i=0; i<nunNextMovetargets; i++){
      for (j=0; j<64; j++){
        pvOnBoardAttackCheck[j] = pieceValuesOnBoard[j];
      }

      pvOnBoardAttackCheck[idx] = 0;
      pvOnBoardAttackCheck[nextMovetargets[i]] = pieceValuesOnBoard[idx];

      if (bIsWhite){
        for (k=0; k<64; k++){
          if (pvOnBoardAttackCheck[k] == 6){
            kingIdx = k;
          }
        }
      }
      else{
        for (k=0; k<64; k++){
          if (pvOnBoardAttackCheck[k] == 12){
            kingIdx = k;
          }
        }
      }

      if (bIsWhite){
        if (!attackedByBlack(kingIdx, pvOnBoardAttackCheck)){
          newMoveTargets[num] = nextMovetargets[i];
          num++;
        }
      }
      else{
        if (!attackedByWhite(kingIdx, pvOnBoardAttackCheck)){
          newMoveTargets[num] = nextMovetargets[i];
          num++;
        }
      }
    }

    nunNextMovetargets = num;
    for (i=0; i<num; i++){
      nextMovetargets[i] = newMoveTargets[i];
    }
  }

  bool attackedByWhite(int targetIdx, List<int> pvOnBoard){
    int i, pv;
    bool attacked = false;

    for (i=0; i<64; i++){
      pv = pvOnBoard[i];

      switch(pv) {
        case 1: {
          attacked = attackedByWhitePawn(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 2: {
          attacked = attackedByWhiteRook(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 3: {
          attacked = attackedByWhiteKnight(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 4: {
          attacked = attackedByWhiteBishop(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 5: {
          attacked = attackedByWhiteQueen(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 6: {
          attacked = attackedByWhiteKing(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        default: {
        }
        break;
      }
    }

    return false;
  }

  bool attackedByBlack(int targetIdx, List<int> pvOnBoard){
    int i, pv;
    bool attacked = false;

    for (i=0; i<64; i++){
      pv = pvOnBoard[i];

      switch(pv) {
        case 7: {
          attacked = attackedByBlackPawn(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 8: {
          attacked = attackedByBlackRook(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 9: {
          attacked = attackedByBlackKnight(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 10: {
          attacked = attackedByBlackBishop(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 11: {
          attacked = attackedByBlackQueen(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        case 12: {
          attacked = attackedByBlackKing(i, targetIdx, pvOnBoard);
          if (attacked){
            return attacked;
          }
        }
        break;

        default: {
        }
        break;
      }
    }

    return false;
  }

  void getValidMoveTargets(int idx, int pv){
    nunNextMovetargets = 0;

    if (bIsWhiteMove) {
      switch(pv) {
        case 1: {
          getValidMoveTargetsWhitePawn(idx);
        }
        break;

        case 2: {
          getValidMoveTargetsWhiteRook(idx);
        }
        break;

        case 3: {
          getValidMoveTargetsWhiteKnight(idx);
        }
        break;

        case 4: {
          getValidMoveTargetsWhiteBishop(idx);
        }
        break;

        case 5: {
          getValidMoveTargetsWhiteQueen(idx);
        }
        break;

        case 6: {
          getValidMoveTargetsWhiteKing(idx);
        }
        break;

        default: {
        }
        break;
      }
    }
    else{
      switch(pv) {
        case 7: {
          getValidMoveTargetsBlackPawn(idx);
        }
        break;

        case 8: {
          getValidMoveTargetsBlackRook(idx);
        }
        break;

        case 9: {
          getValidMoveTargetsBlackKnight(idx);
        }
        break;

        case 10: {
          getValidMoveTargetsBlackBishop(idx);
        }
        break;

        case 11: {
          getValidMoveTargetsBlackQueen(idx);
        }
        break;

        case 12: {
          getValidMoveTargetsBlackKing(idx);
        }
        break;


        default: {

        }
        break;
      }
    }

    veirfyMoveTargets(idx);
  }

  void showMoveTargets(bool show){
    if (show){
      for (int i=0; i<nunNextMovetargets; i++){
        int idx = nextMovetargets[i];

        if (bWhiteOnBottom){
          idx = 63 - idx;
        }

        int row = (idx/8).floor();
        int col = idx - row*8;

        col = 7 - col;

        setTargetPosition(i, yStart + (row*squareWH).toDouble(), xStart + (col*squareWH).toDouble());
      }
    }
    else{
      setState(() {
          targetLeft1 = invisibleLeft;
          targetLeft2 = invisibleLeft;
          targetLeft3 = invisibleLeft;
          targetLeft4 = invisibleLeft;
          targetLeft5 = invisibleLeft;
          targetLeft6 = invisibleLeft;
          targetLeft7 = invisibleLeft;
          targetLeft8 = invisibleLeft;
          targetLeft9 = invisibleLeft;
          targetLeft10 = invisibleLeft;
          targetLeft11 = invisibleLeft;
          targetLeft12 = invisibleLeft;
          targetLeft13 = invisibleLeft;
          targetLeft14 = invisibleLeft;
          targetLeft15 = invisibleLeft;
          targetLeft16 = invisibleLeft;
          targetLeft17 = invisibleLeft;
          targetLeft18 = invisibleLeft;
          targetLeft19 = invisibleLeft;
          targetLeft20 = invisibleLeft;
          targetLeft21 = invisibleLeft;
          targetLeft22 = invisibleLeft;
          targetLeft23 = invisibleLeft;
          targetLeft24 = invisibleLeft;
          targetLeft25 = invisibleLeft;
          targetLeft26 = invisibleLeft;
          targetLeft27 = invisibleLeft;
          targetLeft28 = invisibleLeft;
          targetLeft29 = invisibleLeft;
          targetLeft30 = invisibleLeft;
          targetLeft31 = invisibleLeft;
          targetLeft32 = invisibleLeft;

      });
    }
  }

  void setTargetPosition(int idx, double top, double left){
    setState(() {
      switch(idx) {
        case 0: {
          targetTop1 = top;
          targetLeft1 = left;
        }
        break;

        case 1: {
          targetTop2 = top;
          targetLeft2 = left;
        }
        break;

        case 2: {
          targetTop3 = top;
          targetLeft3 = left;
        }
        break;

        case 3: {
          targetTop4 = top;
          targetLeft4 = left;
        }
        break;

        case 4: {
          targetTop5 = top;
          targetLeft5 = left;
        }
        break;

        case 5: {
          targetTop6 = top;
          targetLeft6 = left;
        }
        break;

        case 6: {
          targetTop7 = top;
          targetLeft7 = left;
        }
        break;

        case 7: {
          targetTop8 = top;
          targetLeft8 = left;
        }
        break;

        case 8: {
          targetTop9 = top;
          targetLeft9 = left;
        }
        break;

        case 9: {
          targetTop10 = top;
          targetLeft10 = left;
        }
        break;

        case 10: {
          targetTop11 = top;
          targetLeft11 = left;
        }
        break;

        case 11: {
          targetTop12 = top;
          targetLeft12 = left;
        }
        break;

        case 12: {
          targetTop13 = top;
          targetLeft13 = left;
        }
        break;

        case 13: {
          targetTop14 = top;
          targetLeft14 = left;
        }
        break;

        case 14: {
          targetTop15 = top;
          targetLeft15 = left;
        }
        break;

        case 15: {
          targetTop16 = top;
          targetLeft16 = left;
        }
        break;

        case 16: {
          targetTop17 = top;
          targetLeft17 = left;
        }
        break;

        case 17: {
          targetTop18 = top;
          targetLeft18 = left;
        }
        break;

        case 18: {
          targetTop19 = top;
          targetLeft19 = left;
        }
        break;

        case 19: {
          targetTop20 = top;
          targetLeft20 = left;
        }
        break;

        case 20: {
          targetTop21 = top;
          targetLeft21 = left;
        }
        break;

        case 21: {
          targetTop22 = top;
          targetLeft22 = left;
        }
        break;

        case 22: {
          targetTop23 = top;
          targetLeft23 = left;
        }
        break;

        case 23: {
          targetTop24 = top;
          targetLeft24 = left;
        }
        break;

        case 24: {
          targetTop25 = top;
          targetLeft25 = left;
        }
        break;

        case 25: {
          targetTop26 = top;
          targetLeft26 = left;
        }
        break;

        case 26: {
          targetTop27 = top;
          targetLeft27 = left;
        }
        break;

        case 27: {
          targetTop28 = top;
          targetLeft28 = left;
        }
        break;

        case 28: {
          targetTop29 = top;
          targetLeft29 = left;
        }
        break;

        case 29: {
          targetTop30 = top;
          targetLeft30 = left;
        }
        break;

        case 30: {
          targetTop31 = top;
          targetLeft31 = left;
        }
        break;

        case 31: {
          targetTop32 = top;
          targetLeft32 = left;
        }
        break;

        default: {
          //statements;
        }
        break;
      }
    });
  }

  void TapOnBoard(TapUpDetails details){
    if (numMoves > maxNumMoves){
      return;
    }

    bStartingNewGame = false;

    DisplayHint(false, 0, 0, 0, 0);

    var x = details.localPosition.dx - xStart; //globalPosition
    var y = details.localPosition.dy - yStart;

    int row0 = (y/squareWH).floor();
    int row = 7 - row0;
    int col = (x/squareWH).floor();

    int idx = 8*row + col;

    if (!bWhiteOnBottom){
      idx = 63 - idx;
    }

    setState(() {
      if (row >=0 && row <=7 && col >=0 && col <=7){
        int pv = pieceValuesOnBoard[idx];

        if (bIsFirstSelect){
          if (bIsWhiteMove){
            if (pv >=1 && pv <=6){
              getValidMoveTargets(idx, pv);
              if (nunNextMovetargets > 0){
                showMoveTargets(true);
              }
              else{
                return;
              }

            }
            else{
              return;
            }
          }
          else{
            if (pv >=7 && pv <=12){
              getValidMoveTargets(idx, pv);
              if (nunNextMovetargets > 0){
                showMoveTargets(true);
              }
              else{
                return;
              }
            }
            else{
              return;
            }
          }

          if (bWhiteOnBottom){
            firstSelRow = row;
            firstSelCol = col;
          }
          else{
            firstSelRow = (idx/8).floor();
            firstSelCol = idx - firstSelRow*8;
          }

          setSelectPosition(yStart + (row0*squareWH).toDouble(), xStart + (col*squareWH).toDouble());

          bIsFirstSelect = false;
        }
        else{
          if (bIsWhiteMove){
            if (pv >=1 && pv <=6){
              showMoveTargets(false);

              getValidMoveTargets(idx, pv);
              if (nunNextMovetargets > 0){
                showMoveTargets(true);

                if (bWhiteOnBottom){
                  firstSelRow = row;
                  firstSelCol = col;
                }
                else{
                  firstSelRow = (idx/8).floor();
                  firstSelCol = idx - firstSelRow*8;
                }

                setSelectPosition(yStart + (row0*squareWH).toDouble(), xStart + (col*squareWH).toDouble());
              }
              else{
                setSelectPosition(0, invisibleLeft);
                bIsFirstSelect = true;
              }

              return;
            }
            else{
              if (!IsMoveTarget(idx)){
                return;
              }
            }

          }
          else{
            if (pv >=7 && pv <=12){
              showMoveTargets(false);

              getValidMoveTargets(idx, pv);
              if (nunNextMovetargets > 0){
                showMoveTargets(true);

                if (bWhiteOnBottom){
                  firstSelRow = row;
                  firstSelCol = col;
                }
                else{
                  firstSelRow = (idx/8).floor();
                  firstSelCol = idx - firstSelRow*8;
                }

                setSelectPosition(yStart + (row0*squareWH).toDouble(), xStart + (col*squareWH).toDouble());
              }
              else{
                setSelectPosition(0, invisibleLeft);
                bIsFirstSelect = true;
              }

              return;
            }
            else{
              if (!IsMoveTarget(idx)){
                return;
              }
            }
          }

          setSelectPosition(0, invisibleLeft);
          showMoveTargets(false);

          if (bWhiteOnBottom){
            secondSelRow = row;
            secondSelCol = col;
          }
          else{
            secondSelRow = (idx/8).floor();
            secondSelCol = idx - secondSelRow*8;
          }

          bIsFirstSelect = true;

          transFirstSelSecondSel();

          String promo = MoveOnePiece();

          String move = columnNames[firstSelCol] + rowNames[firstSelRow] +
                        columnNames[secondSelCol] + rowNames[secondSelRow] + promo;

          RecordOneMove(move);

          PlayNextMove();
        }

      }

    });

  }

  bool IsMoveTarget(int idx){
    for (int i=0; i<nunNextMovetargets; i++){
      if (idx == nextMovetargets[i]){
        return true;
      }
    }
    return false;
  }

  void setSelectPosition(double top, double left){
    setState(() {
      selPositionTop = top;
      selPositionLeft = left;
    });
  }

  /// Construct a color from a hex code string, of the format #RRGGBB.
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  int rowIndex(String rname)
  {
    int idx = -1;

    if (rname == '1')
    {
      idx = 0;
      return idx;
    }
    if (rname == '2')
    {
      idx = 1;
      return idx;
    }
    if (rname == '3')
    {
      idx = 2;
      return idx;
    }
    if (rname == '4')
    {
      idx = 3;
      return idx;
    }
    if (rname == '5')
    {
      idx = 4;
      return idx;
    }
    if (rname == '6')
    {
      idx = 5;
      return idx;
    }
    if (rname == '7')
    {
      idx = 6;
      return idx;
    }
    if (rname == '8')
    {
      idx = 7;
      return idx;
    }

    return idx;
  }

  int columnIndex(String cname)
  {
    int idx = -1;

    if (cname == 'a')
    {
      idx = 0;
      return idx;
    }
    if (cname == 'b')
    {
      idx = 1;
      return idx;
    }
    if (cname == 'c')
    {
      idx = 2;
      return idx;
    }
    if (cname == 'd')
    {
      idx = 3;
      return idx;
    }
    if (cname == 'e')
    {
      idx = 4;
      return idx;
    }
    if (cname == 'f')
    {
      idx = 5;
      return idx;
    }
    if (cname == 'g')
    {
      idx = 6;
      return idx;
    }
    if (cname == 'h')
    {
      idx = 7;
      return idx;
    }

    return idx;
  }


  void redisplayPieces(){
    List<int> boardIdx = List.filled(32, 0);
    List<int> pvOnBoard = List.filled(32, 0);
    List<int> uipIdxOnBoard = List.filled(32, 0);
    int numPV = 0;
    int i = 0, newIdx = 0;

    for (i=0; i<64; i++){
      int pv = pieceValuesOnBoard[i];

      if (pv != 0) {
        boardIdx[numPV] = i;
        pvOnBoard[numPV] = pv;
        uipIdxOnBoard[numPV] = UIPieceIndexOnBoard[i];

        numPV++;
      }
    }

    setState(() {
      for (i=0; i<numPV; i++){
        newIdx = boardIdx[i];
        if (!bWhiteOnBottom){
          newIdx = 63 - newIdx;
        }

        int row = (newIdx/8).floor();
        int col = newIdx - row*8;

        int row2 = 7 - row;

        setPiecePosition(uipIdxOnBoard[i], yStart + row2 * squareWH,
            xStart + col * squareWH);
      }
    });

    ShowHideMovingArrow(bRedrawArrow);

    DisplayHint(false, 0, 0, 0, 0);
  }

  String MoveOnePiece(){
    String promotion = '';
    int rowB1 = 7 - firstSelRow;
    int rowB2 = 7 - secondSelRow;

    int idx1 = 8*firstSelRow + firstSelCol;
    int idx2 = 8*secondSelRow + secondSelCol;

    int idxUI1 = 8*rowB1 + firstSelCol;
    int idxUI2 = 8*rowB2 + secondSelCol;

    int pv1 = pieceValuesOnBoard[idx1];
    int pv2 = pieceValuesOnBoard[idx2];

    EnPassantIdx = -1;

    if (pv1 != 0){
      int uipIdx = UIPieceIndexOnBoard[idx1];

      if (uipIdx != -1){
        if (idx1 == 0 && pv1 == whiteRookVal){
          bRook0Moved = true;
        }
        if (idx1 == 7 && pv1 == whiteRookVal){
          bRook7Moved = true;
        }
        if (idx1 == 56 && pv1 == blackRookVal){
          bRook56Moved = true;
        }
        if (idx1 == 63 && pv1 == blackRookVal){
          bRook63Moved = true;
        }
        if (idx1 == 4 && pv1 == whiteKingVal){
          bWhiteKingMoved = true;
        }
        if (idx1 == 60 && pv1 == blackKingVal){
          bBlackKingMoved = true;
        }

        if (pv1 == whitePawnVal){
          if (idx2 == (idx1 + 16)){
            EnPassantIdx = idx1 + 8;
          }
        }

        if (pv1 == blackPawnVal){
          if (idx2 == (idx1 - 16)){
            EnPassantIdx = idx1 - 8;
          }
        }

        setState(() {
          setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + transSecondCol*squareWH);

          if (pv2 != 0){
            uipIdx = UIPieceIndexOnBoard[idx2];

            setPiecePosition(uipIdx, 0, invisibleLeft);
          }

          UIPieceIndexOnBoard[idx2] = UIPieceIndexOnBoard[idx1];
          UIPieceIndexOnBoard[idx1] = -1;

          pieceValuesOnBoard[idx2] = pieceValuesOnBoard[idx1];
          pieceValuesOnBoard[idx1] = 0;

          //pawn promotion
          if (pv1 == whitePawnVal && idx2 >= 56 && idx2 <= 63){
            //white queen
            pieceValuesOnBoard[idx2] = whiteQueenVal;
            setPiecePosition(UIPieceIndexOnBoard[idx2], 0, invisibleLeft);
            UIPieceIndexOnBoard[idx2] = WhiteQueenPromotion[numWhiteQueenPromotion];
            setPiecePosition(WhiteQueenPromotion[numWhiteQueenPromotion], yStart + transSecondRow*squareWH, xStart + transSecondCol*squareWH);
            numWhiteQueenPromotion++;

            promotion = 'q';
          }
          if (pv1 == blackPawnVal && idx2 >= 0 && idx2 <= 7){
            //black queen
            pieceValuesOnBoard[idx2] = blackQueenVal;
            setPiecePosition(UIPieceIndexOnBoard[idx2], 0, invisibleLeft);
            UIPieceIndexOnBoard[idx2] = BlackQueenPromotion[numBlackQueenPromotion];
            setPiecePosition(BlackQueenPromotion[numBlackQueenPromotion], yStart + transSecondRow*squareWH, xStart + transSecondCol*squareWH);
            numBlackQueenPromotion++;

            promotion = 'q';
          }

          if (pv1 == whitePawnVal && pv2 == 0){
            if (idx2 == (idx1 + 8 - 1)){
              pieceValuesOnBoard[idx1 - 1] = 0;
              setPiecePosition(UIPieceIndexOnBoard[idx1 - 1], 0, invisibleLeft);
              UIPieceIndexOnBoard[idx1 - 1] = -1;
            }

            if (idx2 == (idx1 + 8 + 1)){
              pieceValuesOnBoard[idx1 + 1] = 0;
              setPiecePosition(UIPieceIndexOnBoard[idx1 + 1], 0, invisibleLeft);
              UIPieceIndexOnBoard[idx1 + 1] = -1;
            }
          }

          if (pv1 == blackPawnVal && pv2 == 0) {
            if (idx2 == (idx1 - 8 - 1)){
              pieceValuesOnBoard[idx1 - 1] = 0;
              setPiecePosition(UIPieceIndexOnBoard[idx1 - 1], 0, invisibleLeft);
              UIPieceIndexOnBoard[idx1 - 1] = -1;
            }

            if (idx2 == (idx1 - 8 + 1)){
              pieceValuesOnBoard[idx1 + 1] = 0;
              setPiecePosition(UIPieceIndexOnBoard[idx1 + 1], 0, invisibleLeft);
              UIPieceIndexOnBoard[idx1 + 1] = -1;
            }
          }

          //castling
          if (pv1 == whiteKingVal && idx1 == 4){
            if (idx2 == 6){
              pieceValuesOnBoard[5] = pieceValuesOnBoard[7];
              pieceValuesOnBoard[7] = 0;

              uipIdx = UIPieceIndexOnBoard[7];

              if (bWhiteOnBottom){
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol - 1)*squareWH);
              }
              else{
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol + 1)*squareWH);
              }

              UIPieceIndexOnBoard[5] = UIPieceIndexOnBoard[7];
              UIPieceIndexOnBoard[7] = -1;
            }

            if (idx2 == 2){
              pieceValuesOnBoard[3] = pieceValuesOnBoard[0];
              pieceValuesOnBoard[0] = 0;

              uipIdx = UIPieceIndexOnBoard[0];

              if (bWhiteOnBottom){
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol + 1)*squareWH);
              }
              else{
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol - 1)*squareWH);
              }

              UIPieceIndexOnBoard[3] = UIPieceIndexOnBoard[0];
              UIPieceIndexOnBoard[0] = -1;
            }
          }

          if (pv1 == blackKingVal && idx1 == 60){
            if (idx2 == 62){
              pieceValuesOnBoard[61] = pieceValuesOnBoard[63];
              pieceValuesOnBoard[63] = 0;

              uipIdx = UIPieceIndexOnBoard[63];

              if (bWhiteOnBottom){
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol - 1)*squareWH);
              }
              else{
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol + 1)*squareWH);
              }

              UIPieceIndexOnBoard[61] = UIPieceIndexOnBoard[63];
              UIPieceIndexOnBoard[63] = -1;
            }

            if (idx2 == 58){
              pieceValuesOnBoard[59] = pieceValuesOnBoard[56];
              pieceValuesOnBoard[56] = 0;

              uipIdx = UIPieceIndexOnBoard[56];

              if (bWhiteOnBottom){
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol + 1)*squareWH);
              }
              else{
                setPiecePosition(uipIdx, yStart + transSecondRow*squareWH, xStart + (transSecondCol - 1)*squareWH);
              }

              UIPieceIndexOnBoard[59] = UIPieceIndexOnBoard[56];
              UIPieceIndexOnBoard[56] = -1;
            }
          }
        });
      }
    }

    ShowHideMovingArrow(true);

    return promotion;
  }


  void setPiecePosition(int idx, double top, double left){
    setState(() {
      switch(idx) {
        case 0: {
          piecePositioneTop1 = top;
          piecePositioneLeft1 = left;
        }
        break;

        case 1: {
          piecePositioneTop2 = top;
          piecePositioneLeft2 = left;
        }
        break;

        case 2: {
          piecePositioneTop3 = top;
          piecePositioneLeft3 = left;
        }
        break;

        case 3: {
          piecePositioneTop4 = top;
          piecePositioneLeft4 = left;
        }
        break;

        case 4: {
          piecePositioneTop5 = top;
          piecePositioneLeft5 = left;
        }
        break;

        case 5: {
          piecePositioneTop6 = top;
          piecePositioneLeft6 = left;
        }
        break;

        case 6: {
          piecePositioneTop7 = top;
          piecePositioneLeft7 = left;
        }
        break;

        case 7: {
          piecePositioneTop8 = top;
          piecePositioneLeft8 = left;
        }
        break;

        case 8: {
          piecePositioneTop9 = top;
          piecePositioneLeft9 = left;
        }
        break;

        case 9: {
          piecePositioneTop10 = top;
          piecePositioneLeft10 = left;
        }
        break;

        case 10: {
          piecePositioneTop11 = top;
          piecePositioneLeft11 = left;
        }
        break;

        case 11: {
          piecePositioneTop12 = top;
          piecePositioneLeft12 = left;
        }
        break;

        case 12: {
          piecePositioneTop13 = top;
          piecePositioneLeft13 = left;
        }
        break;

        case 13: {
          piecePositioneTop14 = top;
          piecePositioneLeft14 = left;
        }
        break;

        case 14: {
          piecePositioneTop15 = top;
          piecePositioneLeft15 = left;
        }
        break;

        case 15: {
          piecePositioneTop16 = top;
          piecePositioneLeft16 = left;
        }
        break;

        case 16: {
          piecePositioneTop17 = top;
          piecePositioneLeft17 = left;
        }
        break;

        case 17: {
          piecePositioneTop18 = top;
          piecePositioneLeft18 = left;
        }
        break;

        case 18: {
          piecePositioneTop19 = top;
          piecePositioneLeft19 = left;
        }
        break;

        case 19: {
          piecePositioneTop20 = top;
          piecePositioneLeft20 = left;
        }
        break;

        case 20: {
          piecePositioneTop21 = top;
          piecePositioneLeft21 = left;
        }
        break;

        case 21: {
          piecePositioneTop22 = top;
          piecePositioneLeft22 = left;
        }
        break;

        case 22: {
          piecePositioneTop23 = top;
          piecePositioneLeft23 = left;
        }
        break;

        case 23: {
          piecePositioneTop24 = top;
          piecePositioneLeft24 = left;
        }
        break;

        case 24: {
          piecePositioneTop25 = top;
          piecePositioneLeft25 = left;
        }
        break;

        case 25: {
          piecePositioneTop26 = top;
          piecePositioneLeft26 = left;
        }
        break;

        case 26: {
          piecePositioneTop27 = top;
          piecePositioneLeft27 = left;
        }
        break;

        case 27: {
          piecePositioneTop28 = top;
          piecePositioneLeft28 = left;
        }
        break;

        case 28: {
          piecePositioneTop29 = top;
          piecePositioneLeft29 = left;
        }
        break;

        case 29: {
          piecePositioneTop30 = top;
          piecePositioneLeft30 = left;
        }
        break;

        case 30: {
          piecePositioneTop31 = top;
          piecePositioneLeft31 = left;
        }
        break;

        case 31: {
          piecePositioneTop32 = top;
          piecePositioneLeft32 = left;
        }
        break;


        case 32: {
          piecePositioneTop33 = top;
          piecePositioneLeft33 = left;
        }
        break;

        case 33: {
          piecePositioneTop34 = top;
          piecePositioneLeft34 = left;
        }
        break;

        case 34: {
          piecePositioneTop35 = top;
          piecePositioneLeft35 = left;
        }
        break;

        case 35: {
          piecePositioneTop36 = top;
          piecePositioneLeft36 = left;
        }
        break;

        case 36: {
          piecePositioneTop37 = top;
          piecePositioneLeft37 = left;
        }
        break;

        case 37: {
          piecePositioneTop38 = top;
          piecePositioneLeft38 = left;
        }
        break;

        case 38: {
          piecePositioneTop39 = top;
          piecePositioneLeft39 = left;
        }
        break;

        case 39: {
          piecePositioneTop40 = top;
          piecePositioneLeft40 = left;
        }
        break;

        case 40: {
          piecePositioneTop41 = top;
          piecePositioneLeft41 = left;
        }
        break;

        case 41: {
          piecePositioneTop42 = top;
          piecePositioneLeft42 = left;
        }
        break;

        default: {

        }
        break;
      }
    });
  }

  void DisplayHint(bool show, int colA, int rowA, int colB, int rowB) {
    setState(() {
      bRedrawHint = show;

      if (show){
        hintX1 = xStart + (colA + 0.5)*squareWH;
        hintY1 = yStart + (rowA + 0.5)*squareWH;
        hintX2 = xStart + (colB + 0.5)*squareWH;
        hintY2 = yStart + (rowB + 0.5)*squareWH;
      }

    });
  }

  void AINextMove(String move) {
    setState(() {
      bStockfishBusy = false;
    });

    if (bStartingNewGame){
      bStartingNewGame = false;

      bIsShowingHint = false;

      return;
    }


    if (bIsShowingHint){
      if (move.length == 4 || move.length == 5){
        int col1 = columnIndex(move[0]);
        int row1 = rowIndex(move[1]);
        int col2 = columnIndex(move[2]);
        int row2 = rowIndex(move[3]);

        int newIdx1 = row1*8 + col1;
        int newIdx2 = row2*8 + col2;

        if (bWhiteOnBottom){
          newIdx1 = 63 - newIdx1;
          newIdx2 = 63 - newIdx2;
        }

        int rowA = (newIdx1/8).floor();
        int colA = newIdx1 - rowA*8;

        int rowB = (newIdx2/8).floor();
        int colB = newIdx2 - rowB*8;

        colA = 7 - colA;
        colB = 7 - colB;

        DisplayHint(true, colA, rowA, colB, rowB);
      }

      bIsShowingHint = false;

      return;
    }

    if (move.length == 4 || move.length == 5){
      firstSelCol = columnIndex(move[0]);
      firstSelRow = rowIndex(move[1]);
      secondSelCol = columnIndex(move[2]);
      secondSelRow = rowIndex(move[3]);

      transFirstSelSecondSel();

      MoveOnePiece();

      RecordOneMove(move);

      if (bStepBackWaiting){
        bStepBackWaiting = false;

        DoStepBack();
      }
      else{
        PlayNextMove();
      }
    }
  }

  void RecordOneMove(String move) {
    movesList[numMoves] = move;

    for (int i=0; i<64; i++){
      PVOnBoardHistory[numMoves][i] = pieceValuesOnBoard[i];
      UIPIndexOnBoardHistory[numMoves][i] = UIPieceIndexOnBoard[i];
    }

    numMoves++;

    bIsWhiteMove = !bIsWhiteMove;
  }

  void StartAINextMove() async {
    if (numMoves > maxNumMoves){
      return;
    }

    //await ReloadStockfish();

    bStockfishBusy = true;

    String command = "position startpos";

    if (numMoves == 0){
      stockfish.stdin = command;
      stockfish.stdin = stockfishCommands[stockfishThinkingTimeIndex];
    }
    else{
      command = "position startpos moves";

      for (int i=0; i<numMoves; i++){
        command += ' ' + movesList[i];
      }

      stockfish.stdin = command;
      stockfish.stdin = stockfishCommands[stockfishThinkingTimeIndex];
    }
  }

  void SetIndexMap() {
    pieceValuesOnBoard[0] = whiteRookVal;
    pieceValuesOnBoard[1] = whiteKnightVal;
    pieceValuesOnBoard[2] = whiteBishopVal;
    pieceValuesOnBoard[3] = whiteQueenVal;
    pieceValuesOnBoard[4] = whiteKingVal;
    pieceValuesOnBoard[5] = whiteBishopVal;
    pieceValuesOnBoard[6] = whiteKnightVal;
    pieceValuesOnBoard[7] = whiteRookVal;

    pieceValuesOnBoard[8] = whitePawnVal;
    pieceValuesOnBoard[9] = whitePawnVal;
    pieceValuesOnBoard[10] = whitePawnVal;
    pieceValuesOnBoard[11] = whitePawnVal;
    pieceValuesOnBoard[12] = whitePawnVal;
    pieceValuesOnBoard[13] = whitePawnVal;
    pieceValuesOnBoard[14] = whitePawnVal;
    pieceValuesOnBoard[15] = whitePawnVal;

    pieceValuesOnBoard[56] = blackRookVal;
    pieceValuesOnBoard[57] = blackKnightVal;
    pieceValuesOnBoard[58] = blackBishopVal;
    pieceValuesOnBoard[59] = blackQueenVal;
    pieceValuesOnBoard[60] = blackKingVal;
    pieceValuesOnBoard[61] = blackBishopVal;
    pieceValuesOnBoard[62] = blackKnightVal;
    pieceValuesOnBoard[63] = blackRookVal;

    pieceValuesOnBoard[48] = blackPawnVal;
    pieceValuesOnBoard[49] = blackPawnVal;
    pieceValuesOnBoard[50] = blackPawnVal;
    pieceValuesOnBoard[51] = blackPawnVal;
    pieceValuesOnBoard[52] = blackPawnVal;
    pieceValuesOnBoard[53] = blackPawnVal;
    pieceValuesOnBoard[54] = blackPawnVal;
    pieceValuesOnBoard[55] = blackPawnVal;


    UIPieceIndexOnBoard[0] = 24;
    UIPieceIndexOnBoard[1] = 25;
    UIPieceIndexOnBoard[2] = 26;
    UIPieceIndexOnBoard[3] = 27;
    UIPieceIndexOnBoard[4] = 28;
    UIPieceIndexOnBoard[5] = 29;
    UIPieceIndexOnBoard[6] = 30;
    UIPieceIndexOnBoard[7] = 31;

    UIPieceIndexOnBoard[8] = 16;
    UIPieceIndexOnBoard[9] = 17;
    UIPieceIndexOnBoard[10] = 18;
    UIPieceIndexOnBoard[11] = 19;
    UIPieceIndexOnBoard[12] = 20;
    UIPieceIndexOnBoard[13] = 21;
    UIPieceIndexOnBoard[14] = 22;
    UIPieceIndexOnBoard[15] = 23;

    UIPieceIndexOnBoard[56] = 0;
    UIPieceIndexOnBoard[57] = 1;
    UIPieceIndexOnBoard[58] = 2;
    UIPieceIndexOnBoard[59] = 3;
    UIPieceIndexOnBoard[60] = 4;
    UIPieceIndexOnBoard[61] = 5;
    UIPieceIndexOnBoard[62] = 6;
    UIPieceIndexOnBoard[63] = 7;

    UIPieceIndexOnBoard[48] = 8;
    UIPieceIndexOnBoard[49] = 9;
    UIPieceIndexOnBoard[50] = 10;
    UIPieceIndexOnBoard[51] = 11;
    UIPieceIndexOnBoard[52] = 12;
    UIPieceIndexOnBoard[53] = 13;
    UIPieceIndexOnBoard[54] = 14;
    UIPieceIndexOnBoard[55] = 15;

  }



  @override
  void initState() {
    super.initState();

    LoadStockfish();

    /*
    stockfish = Stockfish();

    streamSubscription = stockfish.stdout.listen((value) {
      if (value.startsWith('bestmove')) {
        final split = value.split(' ');
        //final Map<int, String> values = {
        //  for (int i = 0; i < split.length; i++)
        //    i: split[i]
        //};
        if (split.length >= 2) {
          //textfielsController.text = split[1];
          AINextMove(split[1]);
        }
      }
    });

     */

    stringButtAITime = ThinkingTimeStringsML[languageIndex][stockfishThinkingTimeIndex];
    stringNewGame = newGameStringsML[languageIndex];
    stringRotateBoard = rotateBoardStringsML[languageIndex];
    stringShowHint = showHintStringsML[languageIndex];
    stringMoveBack = moveBackStringsML[languageIndex];

    whitePlayerNames[0] = whiteStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    whitePlayerNames[1] = whiteStringsML[languageIndex] + ': Stockfish 14.1';

    blackPlayerNames[0] = blackStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    blackPlayerNames[1] = blackStringsML[languageIndex] + ': Stockfish 14.1';

    UpdatePlayerWhiteID();
    UpdatePlayerBlackID();

    //redisplayNames();

    /*
    try {

    } catch (error) {

    }

     */

    SetIndexMap();

    StockfishColor = hexToColor("#feab45");
    BlackIDColor = StockfishColor;
    TopPlayerColor = StockfishColor;

    squareWH = ((screenWidth - 20)/8).floor();

    int squareWH2 = ((screenHeight  - 4.0*34 - 70.0 - 50.0)/10.0).floor();
    if (squareWH2 < squareWH){
      squareWH = squareWH2;
    }
	
    IndicatorYTop = 5;
    IndicatorYBottom = 9.0*squareWH - 5;
    IndicatorXHuman = 140;
    IndicatorXStockfish = 210; //185;

    buttonWidthA = 140.0;
    buttonHeightA = 34.0;
    buttonWidthB = 195.0;
    buttonHeightB = 34.0;
    buttonWidthC = 310.0;
    buttonHeightC = 34.0;

    double buttonGapW = 8; //20
    double buttonGapH = 12;

    buttonGapH = (screenHeight - 10.0*squareWH - 4.0*buttonHeightA - 70.0)/5.0;

    double buttonABW = buttonWidthA + buttonWidthB + buttonGapW;
    double buttonsBLeft = (screenWidth - buttonABW)/2.0;
    double buttonCLeft = (screenWidth - buttonWidthC)/2.0;
    double buttonsALeft = buttonsBLeft + buttonWidthB + buttonGapW;

    double buttonsTop1 = 10.0*squareWH;
    double buttonsTop2 = buttonsTop1 + buttonHeightA + buttonGapH;
    double buttonsTop3 = buttonsTop2 + buttonHeightA + buttonGapH;

    double buttonsTop4 = buttonsTop3 + buttonHeightA + buttonGapH;

    rotateBoardTop = buttonsTop3;
    rotateBoardLeft = buttonsBLeft;
    blackIDTop = buttonsTop2;
    blackIDLeft = buttonsBLeft;
    whiteIDTop = buttonsTop1;
    whiteIDLeft = buttonsBLeft;

    newGameTop = buttonsTop3;
    newGameLeft = buttonsALeft;
    stepBackTop = buttonsTop2;
    stepBackLeft = buttonsALeft;
    showHintTop = buttonsTop1;
    showHintLeft = buttonsALeft;


    stockfishTimeTop = buttonsTop4;
    stockfishTimeLeft = buttonCLeft;

    humanBusyTop = IndicatorYBottom;
    humanBusyLeft = IndicatorXHuman;

    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));

    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));

    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));

    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));

    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));

    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));

    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));

    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));
    squareColorList.add(hexToColor(boardSquareColor2));
    squareColorList.add(hexToColor(boardSquareColor1));

    sw1 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[0]
    );

    sw2 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[1]
    );

    sw3 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[2]
    );

    sw4 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[3]
    );

    sw5 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[4]
    );

    sw6 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[5]
    );

    sw7 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[6]
    );

    sw8 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[7]
    );

    sw9 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[8]//
    );

    sw10 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[9]
    );

    sw11 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[10]
    );

    sw12 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[11]
    );

    sw13 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[12]
    );

    sw14 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[13]
    );

    sw15 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[14]
    );

    sw16 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[15]
    );

    sw17 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[16]
    );

    sw18 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[17]
    );

    sw19 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[18]
    );

    sw20 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[19]
    );

    sw21 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[20]
    );

    sw22 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[21]
    );

    sw23 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[22]
    );

    sw24 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[23]
    );

    sw25 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[24]
    );

    sw26 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[25]
    );

    sw27 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[26]
    );

    sw28 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[27]
    );

    sw29 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[28]
    );

    sw30 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[29]
    );

    sw31 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[30]
    );

    sw32 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[31]
    );

    sw33 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[32]
    );

    sw34 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[33]
    );

    sw35 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[34]
    );

    sw36 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[35]
    );

    sw37 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[36]
    );

    sw38 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[37]
    );

    sw39 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[38]
    );

    sw40 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[39]
    );

    sw41 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[40]
    );

    sw42 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[41]
    );

    sw43 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[42]
    );

    sw44 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[43]
    );

    sw45 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[44]
    );

    sw46 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[45]
    );

    sw47 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[46]
    );

    sw48 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[47]
    );

    sw49 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[48]
    );

    sw50 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[49]
    );

    sw51 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[50]
    );

    sw52 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[51]
    );

    sw53 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[52]
    );

    sw54 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[53]
    );

    sw55 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[54]
    );

    sw56 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[55]
    );



    sw57 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[56]
    );

    sw58 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[57]
    );

    sw59 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[58]
    );

    sw60 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[59]
    );

    sw61 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[60]
    );

    sw62 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[61]
    );

    sw63 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[62]
    );

    sw64 = new Container(
      width: squareWH.toDouble(),
      height: squareWH.toDouble(),
      color: squareColorList[63]
    );

    swSelect = new Container(
        width: squareWH.toDouble(),
        height: squareWH.toDouble(),
        color: hexToColor(boardSquareSelectColor),
    );

    target1 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target2 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target3 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target4 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target5 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target6 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target7 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target8 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target9 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target10 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target11 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target12 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target13 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target14 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target15 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target16 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target17 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target18 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target19 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target20 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target21 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target22 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target23 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target24 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target25 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target26 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target27 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target28 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target29 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target30 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target31 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    target32 = new Container(
      color: Colors.transparent,
      padding:  const EdgeInsets.all(9),
      child: new Image.asset('assets/images/targets.png'),
      alignment: Alignment.center,
    );

    targetsList.add(target1);
    targetsList.add(target2);
    targetsList.add(target3);
    targetsList.add(target4);
    targetsList.add(target5);
    targetsList.add(target6);
    targetsList.add(target7);
    targetsList.add(target8);
    targetsList.add(target9);
    targetsList.add(target10);
    targetsList.add(target11);
    targetsList.add(target12);
    targetsList.add(target13);
    targetsList.add(target14);
    targetsList.add(target15);
    targetsList.add(target16);
    targetsList.add(target17);
    targetsList.add(target18);
    targetsList.add(target19);
    targetsList.add(target20);
    targetsList.add(target21);
    targetsList.add(target22);
    targetsList.add(target23);
    targetsList.add(target24);
    targetsList.add(target25);
    targetsList.add(target26);
    targetsList.add(target27);
    targetsList.add(target28);
    targetsList.add(target29);
    targetsList.add(target30);
    targetsList.add(target31);
    targetsList.add(target32);

    piece1 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/rb9.png'),
      alignment: Alignment.center,
    );
    piece2 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/nb9.png'),
      alignment: Alignment.center,
    );
    piece3 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/bb9.png'),
      alignment: Alignment.center,
    );
    piece4 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );
    piece5 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/kb9.png'),
      alignment: Alignment.center,
    );
    piece6 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/bb9.png'),
      alignment: Alignment.center,
    );
    piece7 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/nb9.png'),
      alignment: Alignment.center,
    );
    piece8 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/rb9.png'),
      alignment: Alignment.center,
    );

    piece9 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece10 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece11 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece12 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece13 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece14 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece15 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );
    piece16 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pb9.png'),
      alignment: Alignment.center,
    );


    piece17 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece18 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece19 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece20 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece21 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece22 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece23 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );
    piece24 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/pw9.png'),
      alignment: Alignment.center,
    );


    piece25 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/rw9.png'),
      alignment: Alignment.center,
    );
    piece26 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/nw9.png'),
      alignment: Alignment.center,
    );
    piece27 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/bw9.png'),
      alignment: Alignment.center,
    );
    piece28 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );
    piece29 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/kw9.png'),
      alignment: Alignment.center,
    );
    piece30 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/bw9.png'),
      alignment: Alignment.center,
    );
    piece31 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/nw9.png'),
      alignment: Alignment.center,
    );
    piece32 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/rw9.png'),
      alignment: Alignment.center,
    );

    piece33 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );
    piece34 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );
    piece35 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );
    piece36 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );
    piece37 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qw9.png'),
      alignment: Alignment.center,
    );

    piece38 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );
    piece39 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );
    piece40 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );
    piece41 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );
    piece42 = new Container(
      color: Colors.transparent,
      child: new Image.asset('assets/images/qb9.png'),
      alignment: Alignment.center,
    );


    pieceList.add(piece1);
    pieceList.add(piece2);
    pieceList.add(piece3);
    pieceList.add(piece4);
    pieceList.add(piece5);
    pieceList.add(piece6);
    pieceList.add(piece7);
    pieceList.add(piece8);

    pieceList.add(piece9);
    pieceList.add(piece10);
    pieceList.add(piece11);
    pieceList.add(piece12);
    pieceList.add(piece13);
    pieceList.add(piece14);
    pieceList.add(piece15);
    pieceList.add(piece16);

    pieceList.add(piece17);
    pieceList.add(piece18);
    pieceList.add(piece19);
    pieceList.add(piece20);
    pieceList.add(piece21);
    pieceList.add(piece22);
    pieceList.add(piece23);
    pieceList.add(piece24);

    pieceList.add(piece25);
    pieceList.add(piece26);
    pieceList.add(piece27);
    pieceList.add(piece28);
    pieceList.add(piece29);
    pieceList.add(piece30);
    pieceList.add(piece31);
    pieceList.add(piece32);


    pieceList.add(piece33);
    pieceList.add(piece34);
    pieceList.add(piece35);
    pieceList.add(piece36);
    pieceList.add(piece37);
    pieceList.add(piece38);
    pieceList.add(piece39);
    pieceList.add(piece40);
    pieceList.add(piece41);
    pieceList.add(piece42);

    squareWidgetList.add(sw1);
    squareWidgetList.add(sw2);
    squareWidgetList.add(sw3);
    squareWidgetList.add(sw4);
    squareWidgetList.add(sw5);
    squareWidgetList.add(sw6);
    squareWidgetList.add(sw7);
    squareWidgetList.add(sw8);
    squareWidgetList.add(sw9);
    squareWidgetList.add(sw10);

    squareWidgetList.add(sw11);
    squareWidgetList.add(sw12);
    squareWidgetList.add(sw13);
    squareWidgetList.add(sw14);
    squareWidgetList.add(sw15);
    squareWidgetList.add(sw16);
    squareWidgetList.add(sw17);
    squareWidgetList.add(sw18);
    squareWidgetList.add(sw19);
    squareWidgetList.add(sw20);

    squareWidgetList.add(sw21);
    squareWidgetList.add(sw22);
    squareWidgetList.add(sw23);
    squareWidgetList.add(sw24);
    squareWidgetList.add(sw25);
    squareWidgetList.add(sw26);
    squareWidgetList.add(sw27);
    squareWidgetList.add(sw28);
    squareWidgetList.add(sw29);
    squareWidgetList.add(sw30);

    squareWidgetList.add(sw31);
    squareWidgetList.add(sw32);
    squareWidgetList.add(sw33);
    squareWidgetList.add(sw34);
    squareWidgetList.add(sw35);
    squareWidgetList.add(sw36);
    squareWidgetList.add(sw37);
    squareWidgetList.add(sw38);
    squareWidgetList.add(sw39);
    squareWidgetList.add(sw40);

    squareWidgetList.add(sw41);
    squareWidgetList.add(sw42);
    squareWidgetList.add(sw43);
    squareWidgetList.add(sw44);
    squareWidgetList.add(sw45);
    squareWidgetList.add(sw46);
    squareWidgetList.add(sw47);
    squareWidgetList.add(sw48);
    squareWidgetList.add(sw49);
    squareWidgetList.add(sw50);

    squareWidgetList.add(sw51);
    squareWidgetList.add(sw52);
    squareWidgetList.add(sw53);
    squareWidgetList.add(sw54);
    squareWidgetList.add(sw55);
    squareWidgetList.add(sw56);
    squareWidgetList.add(sw57);
    squareWidgetList.add(sw58);
    squareWidgetList.add(sw59);
    squareWidgetList.add(sw60);

    squareWidgetList.add(sw61);
    squareWidgetList.add(sw62);
    squareWidgetList.add(sw63);
    squareWidgetList.add(sw64);

    squarePositioneTop1 = yStart;
    squarePositioneLeft1 = xStart;

    squarePositioneTop2 = yStart;
    squarePositioneLeft2 = xStart + squareWH;

    squarePositioneTop3 = yStart;
    squarePositioneLeft3 = xStart + 2*squareWH;

    squarePositioneTop4 = yStart;
    squarePositioneLeft4 = xStart + 3*squareWH;

    squarePositioneTop5 = yStart;
    squarePositioneLeft5 = xStart + 4*squareWH;

    squarePositioneTop6 = yStart;
    squarePositioneLeft6 = xStart + 5*squareWH;

    squarePositioneTop7 = yStart;
    squarePositioneLeft7 = xStart + 6*squareWH;

    squarePositioneTop8 = yStart;
    squarePositioneLeft8 = xStart + 7*squareWH;

    squarePositioneTop9 = yStart + squareWH;
    squarePositioneLeft9 = xStart;

    squarePositioneTop10 = yStart + squareWH;
    squarePositioneLeft10 = xStart + squareWH;

    squarePositioneTop11 = yStart + squareWH;
    squarePositioneLeft11 = xStart + 2*squareWH;

    squarePositioneTop12 = yStart + squareWH;
    squarePositioneLeft12 = xStart + 3*squareWH;

    squarePositioneTop13 = yStart + squareWH;
    squarePositioneLeft13 = xStart + 4*squareWH;


    squarePositioneTop14 = yStart + squareWH;
    squarePositioneLeft14 = xStart + 5*squareWH;

    squarePositioneTop15 = yStart + squareWH;
    squarePositioneLeft15 = xStart + 6*squareWH;

    squarePositioneTop16 = yStart + squareWH;
    squarePositioneLeft16 = xStart + 7*squareWH;

    squarePositioneTop17 = yStart + 2*squareWH;
    squarePositioneLeft17 = xStart;

    squarePositioneTop18 = yStart + 2*squareWH;
    squarePositioneLeft18 = xStart + squareWH;

    squarePositioneTop19 = yStart + 2*squareWH;
    squarePositioneLeft19 = xStart + 2*squareWH;

    squarePositioneTop20 = yStart + 2*squareWH;
    squarePositioneLeft20 = xStart + 3*squareWH;

    squarePositioneTop21 = yStart + 2*squareWH;
    squarePositioneLeft21 = xStart + 4*squareWH;

    squarePositioneTop22 = yStart + 2*squareWH;
    squarePositioneLeft22 = xStart + 5*squareWH;

    squarePositioneTop23 = yStart + 2*squareWH;
    squarePositioneLeft23 = xStart + 6*squareWH;

    squarePositioneTop24 = yStart + 2*squareWH;
    squarePositioneLeft24 = xStart + 7*squareWH;

    squarePositioneTop25 = yStart + 3*squareWH;
    squarePositioneLeft25 = xStart;

    squarePositioneTop26 = yStart + 3*squareWH;
    squarePositioneLeft26 = xStart + squareWH;

    squarePositioneTop27 = yStart + 3*squareWH;
    squarePositioneLeft27 = xStart + 2*squareWH;

    squarePositioneTop28 = yStart + 3*squareWH;
    squarePositioneLeft28 = xStart + 3*squareWH;

    squarePositioneTop29 = yStart + 3*squareWH;
    squarePositioneLeft29 = xStart + 4*squareWH;

    squarePositioneTop30 = yStart + 3*squareWH;
    squarePositioneLeft30 = xStart + 5*squareWH;

    squarePositioneTop31 = yStart + 3*squareWH;
    squarePositioneLeft31 = xStart + 6*squareWH;

    squarePositioneTop32 = yStart + 3*squareWH;
    squarePositioneLeft32 = xStart + 7*squareWH;

    squarePositioneTop33 = yStart + 4*squareWH;
    squarePositioneLeft33 = xStart;

    squarePositioneTop34 = yStart + 4*squareWH;
    squarePositioneLeft34 = xStart + squareWH;

    squarePositioneTop35 = yStart + 4*squareWH;
    squarePositioneLeft35 = xStart + 2*squareWH;

    squarePositioneTop36 = yStart + 4*squareWH;
    squarePositioneLeft36 = xStart + 3*squareWH;

    squarePositioneTop37 = yStart + 4*squareWH;
    squarePositioneLeft37 = xStart + 4*squareWH;

    squarePositioneTop38 = yStart + 4*squareWH;
    squarePositioneLeft38 = xStart + 5*squareWH;

    squarePositioneTop39 = yStart + 4*squareWH;
    squarePositioneLeft39 = xStart + 6*squareWH;

    squarePositioneTop40 = yStart + 4*squareWH;
    squarePositioneLeft40 = xStart + 7*squareWH;

    squarePositioneTop41 = yStart + 5*squareWH;
    squarePositioneLeft41 = xStart;

    squarePositioneTop42 = yStart + 5*squareWH;
    squarePositioneLeft42 = xStart + squareWH;

    squarePositioneTop43 = yStart + 5*squareWH;
    squarePositioneLeft43 = xStart + 2*squareWH;

    squarePositioneTop44 = yStart + 5*squareWH;
    squarePositioneLeft44 = xStart + 3*squareWH;

    squarePositioneTop45 = yStart + 5*squareWH;
    squarePositioneLeft45 = xStart + 4*squareWH;

    squarePositioneTop46 = yStart + 5*squareWH;
    squarePositioneLeft46 = xStart + 5*squareWH;

    squarePositioneTop47 = yStart + 5*squareWH;
    squarePositioneLeft47 = xStart + 6*squareWH;

    squarePositioneTop48 = yStart + 5*squareWH;
    squarePositioneLeft48 = xStart + 7*squareWH;

    squarePositioneTop49 = yStart + 6*squareWH;
    squarePositioneLeft49 = xStart;

    squarePositioneTop50 = yStart + 6*squareWH;
    squarePositioneLeft50 = xStart + squareWH;

    squarePositioneTop51 = yStart + 6*squareWH;
    squarePositioneLeft51 = xStart + 2*squareWH;

    squarePositioneTop52 = yStart + 6*squareWH;
    squarePositioneLeft52 = xStart + 3*squareWH;

    squarePositioneTop53 = yStart + 6*squareWH;
    squarePositioneLeft53 = xStart + 4*squareWH;

    squarePositioneTop54 = yStart + 6*squareWH;
    squarePositioneLeft54 = xStart + 5*squareWH;

    squarePositioneTop55 = yStart + 6*squareWH;
    squarePositioneLeft55 = xStart + 6*squareWH;

    squarePositioneTop56 = yStart + 6*squareWH;
    squarePositioneLeft56 = xStart + 7*squareWH;

    squarePositioneTop57 = yStart + 7*squareWH;
    squarePositioneLeft57 = xStart;

    squarePositioneTop58 = yStart + 7*squareWH;
    squarePositioneLeft58 = xStart + squareWH;

    squarePositioneTop59 = yStart + 7*squareWH;
    squarePositioneLeft59 = xStart + 2*squareWH;

    squarePositioneTop60 = yStart + 7*squareWH;
    squarePositioneLeft60 = xStart + 3*squareWH;

    squarePositioneTop61 = yStart + 7*squareWH;
    squarePositioneLeft61 = xStart + 4*squareWH;

    squarePositioneTop62 = yStart + 7*squareWH;
    squarePositioneLeft62 = xStart + 5*squareWH;

    squarePositioneTop63 = yStart + 7*squareWH;
    squarePositioneLeft63 = xStart + 6*squareWH;

    squarePositioneTop64 = yStart + 7*squareWH;
    squarePositioneLeft64 = xStart + 7*squareWH;

    piecePositioneTop1 = yStart;
    piecePositioneLeft1 = xStart;

    piecePositioneTop2 = yStart;
    piecePositioneLeft2 = xStart + squareWH;

    piecePositioneTop3 = yStart;
    piecePositioneLeft3 = xStart + 2*squareWH;

    piecePositioneTop4 = yStart;
    piecePositioneLeft4 = xStart + 3*squareWH;

    piecePositioneTop5 = yStart;
    piecePositioneLeft5 = xStart + 4*squareWH;

    piecePositioneTop6 = yStart;
    piecePositioneLeft6 = xStart + 5*squareWH;

    piecePositioneTop7 = yStart;
    piecePositioneLeft7 = xStart + 6*squareWH;

    piecePositioneTop8 = yStart;
    piecePositioneLeft8 = xStart + 7*squareWH;

    piecePositioneTop9 = yStart + squareWH;
    piecePositioneLeft9 = xStart;

    piecePositioneTop10 = yStart + squareWH;
    piecePositioneLeft10 = xStart + squareWH;

    piecePositioneTop11 = yStart + squareWH;
    piecePositioneLeft11 = xStart + 2*squareWH;

    piecePositioneTop12 = yStart + squareWH;
    piecePositioneLeft12 = xStart + 3*squareWH;

    piecePositioneTop13 = yStart + squareWH;
    piecePositioneLeft13 = xStart + 4*squareWH;

    piecePositioneTop14 = yStart + squareWH;
    piecePositioneLeft14 = xStart + 5*squareWH;

    piecePositioneTop15 = yStart + squareWH;
    piecePositioneLeft15 = xStart + 6*squareWH;

    piecePositioneTop16 = yStart + squareWH;
    piecePositioneLeft16 = xStart + 7*squareWH;

    piecePositioneTop17 = yStart + 6*squareWH;
    piecePositioneLeft17 = xStart;

    piecePositioneTop18 = yStart + 6*squareWH;
    piecePositioneLeft18 = xStart + squareWH;

    piecePositioneTop19 = yStart + 6*squareWH;
    piecePositioneLeft19 = xStart + 2*squareWH;

    piecePositioneTop20 = yStart + 6*squareWH;
    piecePositioneLeft20 = xStart + 3*squareWH;

    piecePositioneTop21 = yStart + 6*squareWH;
    piecePositioneLeft21 = xStart + 4*squareWH;

    piecePositioneTop22 = yStart + 6*squareWH;
    piecePositioneLeft22 = xStart + 5*squareWH;

    piecePositioneTop23 = yStart + 6*squareWH;
    piecePositioneLeft23 = xStart + 6*squareWH;

    piecePositioneTop24 = yStart + 6*squareWH;
    piecePositioneLeft24 = xStart + 7*squareWH;

    piecePositioneTop25 = yStart + 7*squareWH;
    piecePositioneLeft25 = xStart;

    piecePositioneTop26 = yStart + 7*squareWH;
    piecePositioneLeft26 = xStart + squareWH;

    piecePositioneTop27 = yStart + 7*squareWH;
    piecePositioneLeft27 = xStart + 2*squareWH;

    piecePositioneTop28 = yStart + 7*squareWH;
    piecePositioneLeft28 = xStart + 3*squareWH;

    piecePositioneTop29 = yStart + 7*squareWH;
    piecePositioneLeft29 = xStart + 4*squareWH;

    piecePositioneTop30 = yStart + 7*squareWH;
    piecePositioneLeft30 = xStart + 5*squareWH;

    piecePositioneTop31 = yStart + 7*squareWH;
    piecePositioneLeft31 = xStart + 6*squareWH;

    piecePositioneTop32 = yStart + 7*squareWH;
    piecePositioneLeft32 = xStart + 7*squareWH;
  }

  onWillPop(context) async {
    int idx = parent.getSelectedIndex();
    if (idx != 0)
    {
      parent.setFirstTab();
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Exit the App?'),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      newGameClick();
                      _androidAppRetain.invokeMethod("sendToBackground");

                      //stockfish.dispose();
                      //StockfishExit();
                    },
                    child: const Text('Yes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      //Navigator.pop(context, false);
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    //screenWidth = MediaQuery.of(context).size.width;
    //screenHeight = MediaQuery.of(context).size.height;
    languageIndex = parent.getLanguageIndex();

    ThinkingTimeStringsML[0][0] = 'Stockfish Thinking Time: 2 Seconds';
    ThinkingTimeStringsML[0][1] = 'Stockfish Thinking Time: 3 Seconds';
    ThinkingTimeStringsML[0][2] = 'Stockfish Thinking Time: 5 Seconds';

    ThinkingTimeStringsML[1][0] = 'Stockfish Tiempo: 2 Sobras';
    ThinkingTimeStringsML[1][1] = 'Stockfish Tiempo: 3 Sobras';
    ThinkingTimeStringsML[1][2] = 'Stockfish Tiempo: 5 Sobras';

    ThinkingTimeStringsML[2][0] = 'Stockfish Waktu: 2 Detik';
    ThinkingTimeStringsML[2][1] = 'Stockfish Waktu: 3 Detik';
    ThinkingTimeStringsML[2][2] = 'Stockfish Waktu: 5 Detik';

    ThinkingTimeStringsML[3][0] = 'Stockfish Oras: 2 Segundo';
    ThinkingTimeStringsML[3][1] = 'Stockfish Oras: 3 Segundo';
    ThinkingTimeStringsML[3][2] = 'Stockfish Oras: 5 Segundo';

    ThinkingTimeStringsML[4][0] = 'Stockfish Время: 2 Cекунды';
    ThinkingTimeStringsML[4][1] = 'Stockfish Время: 3 Cекунды';
    ThinkingTimeStringsML[4][2] = 'Stockfish Время: 5 Cекунды';

    ThinkingTimeStringsML[5][0] = 'Stockfish Thời Gian: 2 Giây';
    ThinkingTimeStringsML[5][1] = 'Stockfish Thời Gian: 3 Giây';
    ThinkingTimeStringsML[5][2] = 'Stockfish Thời Gian: 5 Giây';

    ThinkingTimeStringsML[6][0] = 'Stockfish Heure: 2 Secondes';
    ThinkingTimeStringsML[6][1] = 'Stockfish Heure: 3 Secondes';
    ThinkingTimeStringsML[6][2] = 'Stockfish Heure: 5 Secondes';

    ThinkingTimeStringsML[7][0] = 'Stockfish Tempo: 2 Segundos';
    ThinkingTimeStringsML[7][1] = 'Stockfish Tempo: 3 Segundos';
    ThinkingTimeStringsML[7][2] = 'Stockfish Tempo: 5 Segundos';

    stringButtAITime = ThinkingTimeStringsML[languageIndex][stockfishThinkingTimeIndex];

    newGameStringsML[0] = 'New Game';
    newGameStringsML[1] = 'Nuevo';
    newGameStringsML[2] = 'Baru';
    newGameStringsML[3] = 'Bago';
    newGameStringsML[4] = 'Новая';
    newGameStringsML[5] = 'Mới';
    newGameStringsML[6] = 'Nouveau';
    newGameStringsML[7] = 'Novo ';
    stringNewGame = newGameStringsML[languageIndex];

    rotateBoardStringsML[0] = 'Rotate Board';
    rotateBoardStringsML[1] = 'Rotar Tablero';
    rotateBoardStringsML[2] = 'Putar Papan';
    rotateBoardStringsML[3] = 'Paikutin';
    rotateBoardStringsML[4] = 'Вращать';
    rotateBoardStringsML[5] = 'Xoay Bảng';
    rotateBoardStringsML[6] = 'Tourner';
    rotateBoardStringsML[7] = 'Rodar';
    stringRotateBoard = rotateBoardStringsML[languageIndex];

    showHintStringsML[0] = 'Show Hint';
    showHintStringsML[1] = 'Indirecta';
    showHintStringsML[2] = 'Petunjuk';
    showHintStringsML[3] = 'Hint';
    showHintStringsML[4] = 'Подсказка';
    showHintStringsML[5] = 'Kháy';
    showHintStringsML[6] = 'Indice';
    showHintStringsML[7] = 'Dica';
    stringShowHint = showHintStringsML[languageIndex];

    moveBackStringsML[0] = 'Step Back';
    moveBackStringsML[1] = 'Atrás';
    moveBackStringsML[2] = 'Mundur';
    moveBackStringsML[3] = 'Pabalik';
    moveBackStringsML[4] = 'Назад';
    moveBackStringsML[5] = 'Lạc Hậu';
    moveBackStringsML[6] = 'Reculez';
    moveBackStringsML[7] = 'Recuar';
    stringMoveBack = moveBackStringsML[languageIndex];

    whiteStringsML[0] = 'White';
    whiteStringsML[1] = 'Blanco';
    whiteStringsML[2] = 'Putih';
    whiteStringsML[3] = 'Puti';
    whiteStringsML[4] = 'Белый';
    whiteStringsML[5] = 'Trắng';
    whiteStringsML[6] = 'Blanc';
    whiteStringsML[7] = 'Branco';

    blackStringsML[0] = 'Black';
    blackStringsML[1] = 'Negro';
    blackStringsML[2] = 'Hitam';
    blackStringsML[3] = 'Itim';
    blackStringsML[4] = 'Чёрный';
    blackStringsML[5] = 'Đen';
    blackStringsML[6] = 'Noir';
    blackStringsML[7] = 'Preto';

    humanStringsML[0] = 'Me';
    humanStringsML[1] = 'Me';
    humanStringsML[2] = 'Saya';
    humanStringsML[3] = 'Ako';
    humanStringsML[4] = 'Меня';
    humanStringsML[5] = 'Tôi';
    humanStringsML[6] = 'Me';
    humanStringsML[7] = 'Me';

    whitePlayerNames[0] = whiteStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    whitePlayerNames[1] = whiteStringsML[languageIndex] + ': Stockfish 14.1';

    blackPlayerNames[0] = blackStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
    blackPlayerNames[1] = blackStringsML[languageIndex] + ': Stockfish 14.1';

    if (bWhitePlayerIsHuman){
      stringPlayerWhiteID = whiteStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
      WhiteIDColor = HumanColor;

      if (bWhiteOnBottom){
        bottomPlayerName  = whitePlayerNames[0];
        BottomPlayerColor = HumanColor;
      }
      else{
        topPlayerName  = whitePlayerNames[0];
        TopPlayerColor = HumanColor;
      }
    }
    else{
      stringPlayerWhiteID = whiteStringsML[languageIndex] + ': Stockfish';
      WhiteIDColor = StockfishColor;

      if (bWhiteOnBottom){
        bottomPlayerName  = whitePlayerNames[1];
        BottomPlayerColor = StockfishColor;
      }
      else{
        topPlayerName  = whitePlayerNames[1];
        TopPlayerColor = StockfishColor;
      }
    }

    if (bBlackPlayerIsHuman){
      stringPlayerBlackID = blackStringsML[languageIndex] + ': ' + humanStringsML[languageIndex];
      BlackIDColor = HumanColor;

      if (bWhiteOnBottom){
        topPlayerName  = blackPlayerNames[0];
        TopPlayerColor = HumanColor;
      }
      else{
        bottomPlayerName  = blackPlayerNames[0];
        BottomPlayerColor = HumanColor;
      }
    }
    else{
      stringPlayerBlackID = blackStringsML[languageIndex] + ': Stockfish';
      BlackIDColor = StockfishColor;

      if (bWhiteOnBottom){
        topPlayerName  = blackPlayerNames[1];
        TopPlayerColor = StockfishColor;
      }
      else{
        bottomPlayerName  = blackPlayerNames[1];
        BottomPlayerColor = StockfishColor;
      }
    }

    piecePos1 = new Positioned(
      top: piecePositioneTop1,
      left: piecePositioneLeft1,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[0],
    );

    piecePos2 = new Positioned(
      top: piecePositioneTop2,
      left: piecePositioneLeft2,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[1],
    );

    piecePos3 = new Positioned(
      top: piecePositioneTop3,
      left: piecePositioneLeft3,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[2],
    );

    piecePos4 = new Positioned(
      top: piecePositioneTop4,
      left: piecePositioneLeft4,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[3],
    );

    piecePos5 = new Positioned(
      top: piecePositioneTop5,
      left: piecePositioneLeft5,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[4],
    );

    piecePos6 = new Positioned(
      top: piecePositioneTop6,
      left: piecePositioneLeft6,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[5],
    );

    piecePos7 = new Positioned(
      top: piecePositioneTop7,
      left: piecePositioneLeft7,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[6],
    );

    piecePos8 = new Positioned(
      top: piecePositioneTop8,
      left: piecePositioneLeft8,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[7],
    );

    piecePos9 = new Positioned(
      top: piecePositioneTop9,
      left: piecePositioneLeft9,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[8],
    );

    piecePos10 = new Positioned(
      top: piecePositioneTop10,
      left: piecePositioneLeft10,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[9],
    );

    piecePos11 = new Positioned(
      top: piecePositioneTop11,
      left: piecePositioneLeft11,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[10],
    );

    piecePos12 = new Positioned(
      top: piecePositioneTop12,
      left: piecePositioneLeft12,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[11],
    );

    piecePos13 = new Positioned(
      top: piecePositioneTop13,
      left: piecePositioneLeft13,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[12],
    );

    piecePos14 = new Positioned(
      top: piecePositioneTop14,
      left: piecePositioneLeft14,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[13],
    );

    piecePos15 = new Positioned(
      top: piecePositioneTop15,
      left: piecePositioneLeft15,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[14],
    );

    piecePos16 = new Positioned(
      top: piecePositioneTop16,
      left: piecePositioneLeft16,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[15],
    );

    piecePos17 = new Positioned(
      top: piecePositioneTop17,
      left: piecePositioneLeft17,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[16],
    );

    piecePos18 = new Positioned(
      top: piecePositioneTop18,
      left: piecePositioneLeft18,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[17],
    );

    piecePos19 = new Positioned(
      top: piecePositioneTop19,
      left: piecePositioneLeft19,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[18],
    );

    piecePos20 = new Positioned(
      top: piecePositioneTop20,
      left: piecePositioneLeft20,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[19],
    );

    piecePos21 = new Positioned(
      top: piecePositioneTop21,
      left: piecePositioneLeft21,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[20],
    );

    piecePos22 = new Positioned(
      top: piecePositioneTop22,
      left: piecePositioneLeft22,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[21],
    );

    piecePos23 = new Positioned(
      top: piecePositioneTop23,
      left: piecePositioneLeft23,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[22],
    );

    piecePos24 = new Positioned(
      top: piecePositioneTop24,
      left: piecePositioneLeft24,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[23],
    );

    piecePos25 = new Positioned(
      top: piecePositioneTop25,
      left: piecePositioneLeft25,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[24],
    );

    piecePos26 = new Positioned(
      top: piecePositioneTop26,
      left: piecePositioneLeft26,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[25],
    );

    piecePos27 = new Positioned(
      top: piecePositioneTop27,
      left: piecePositioneLeft27,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[26],
    );

    piecePos28 = new Positioned(
      top: piecePositioneTop28,
      left: piecePositioneLeft28,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[27],
    );

    piecePos29 = new Positioned(
      top: piecePositioneTop29,
      left: piecePositioneLeft29,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[28],
    );

    piecePos30 = new Positioned(
      top: piecePositioneTop30,
      left: piecePositioneLeft30,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[29],
    );

    piecePos31 = new Positioned(
      top: piecePositioneTop31,
      left: piecePositioneLeft31,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[30],
    );

    piecePos32 = new Positioned(
      top: piecePositioneTop32,
      left: piecePositioneLeft32,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[31],
    );


    piecePos33 = new Positioned(
      top: piecePositioneTop33,
      left: piecePositioneLeft33,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[32],
    );

    piecePos34 = new Positioned(
      top: piecePositioneTop34,
      left: piecePositioneLeft34,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[33],
    );

    piecePos35 = new Positioned(
      top: piecePositioneTop35,
      left: piecePositioneLeft35,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[34],
    );

    piecePos36 = new Positioned(
      top: piecePositioneTop36,
      left: piecePositioneLeft36,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[35],
    );

    piecePos37 = new Positioned(
      top: piecePositioneTop37,
      left: piecePositioneLeft37,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[36],
    );

    piecePos38 = new Positioned(
      top: piecePositioneTop38,
      left: piecePositioneLeft38,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[37],
    );

    piecePos39 = new Positioned(
      top: piecePositioneTop39,
      left: piecePositioneLeft39,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[38],
    );

    piecePos40 = new Positioned(
      top: piecePositioneTop40,
      left: piecePositioneLeft40,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[39],
    );

    piecePos41 = new Positioned(
      top: piecePositioneTop41,
      left: piecePositioneLeft41,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[40],
    );

    piecePos42 = new Positioned(
      top: piecePositioneTop42,
      left: piecePositioneLeft42,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: pieceList[41],
    );


    posSelect = new Positioned(
      top: selPositionTop,
      left: selPositionLeft,
      height:squareWH.toDouble(),
      width: squareWH.toDouble(),
      child: swSelect,
    );

    return WillPopScope(
        onWillPop: () => onWillPop(context),

    child:  Scaffold(
    //return Scaffold(
      backgroundColor: hexToColor("#cbccfe"),
      body: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),

        Container(
          width: Get.width,
          height: Get.height - 90,

          child:
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (TapUpDetails details) => TapOnBoard(details),
              child:

          Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                width: Get.width,
                height: squareWH*8.0 + 70,
                color: hexToColor("#845fc2"),
              ),

              new Positioned(
                top: squarePositioneTop1,
                left: squarePositioneLeft1,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[0],
              ),
              new Positioned(
                top: squarePositioneTop2,
                left: squarePositioneLeft2,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[1],
              ),

              new Positioned(
                top: squarePositioneTop3,
                left: squarePositioneLeft3,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[2],
              ),

              new Positioned(
                top: squarePositioneTop4,
                left: squarePositioneLeft4,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[3],
              ),

              new Positioned(
                top: squarePositioneTop5,
                left: squarePositioneLeft5,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[4],
              ),

              new Positioned(
                top: squarePositioneTop6,
                left: squarePositioneLeft6,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[5],
              ),

              new Positioned(
                top: squarePositioneTop7,
                left: squarePositioneLeft7,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[6],
              ),

              new Positioned(
                top: squarePositioneTop8,
                left: squarePositioneLeft8,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[7],
              ),

              new Positioned(
                top: squarePositioneTop9,
                left: squarePositioneLeft9,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[8],
              ),

              new Positioned(
                top: squarePositioneTop10,
                left: squarePositioneLeft10,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[9],
              ),

              new Positioned(
                top: squarePositioneTop11,
                left: squarePositioneLeft11,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[10],
              ),

              new Positioned(
                top: squarePositioneTop12,
                left: squarePositioneLeft12,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[11],
              ),

              new Positioned(
                top: squarePositioneTop13,
                left: squarePositioneLeft13,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[12],
              ),

              new Positioned(
                top: squarePositioneTop14,
                left: squarePositioneLeft14,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[13],
              ),

              new Positioned(
                top: squarePositioneTop15,
                left: squarePositioneLeft15,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[14],
              ),

              new Positioned(
                top: squarePositioneTop16,
                left: squarePositioneLeft16,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[15],
              ),

              new Positioned(
                top: squarePositioneTop17,
                left: squarePositioneLeft17,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[16],
              ),

              new Positioned(
                top: squarePositioneTop18,
                left: squarePositioneLeft18,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[17],
              ),

              new Positioned(
                top: squarePositioneTop19,
                left: squarePositioneLeft19,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[18],
              ),

              new Positioned(
                top: squarePositioneTop20,
                left: squarePositioneLeft20,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[19],
              ),

              new Positioned(
                top: squarePositioneTop21,
                left: squarePositioneLeft21,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[20],
              ),

              new Positioned(
                top: squarePositioneTop22,
                left: squarePositioneLeft22,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[21],
              ),

              new Positioned(
                top: squarePositioneTop23,
                left: squarePositioneLeft23,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[22],
              ),

              new Positioned(
                top: squarePositioneTop24,
                left: squarePositioneLeft24,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[23],
              ),

              new Positioned(
                top: squarePositioneTop25,
                left: squarePositioneLeft25,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[24],
              ),

              new Positioned(
                top: squarePositioneTop26,
                left: squarePositioneLeft26,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[25],
              ),

              new Positioned(
                top: squarePositioneTop27,
                left: squarePositioneLeft27,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[26],
              ),

              new Positioned(
                top: squarePositioneTop28,
                left: squarePositioneLeft28,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[27],
              ),

              new Positioned(
                top: squarePositioneTop29,
                left: squarePositioneLeft29,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[28],
              ),

              new Positioned(
                top: squarePositioneTop30,
                left: squarePositioneLeft30,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[29],
              ),

              new Positioned(
                top: squarePositioneTop31,
                left: squarePositioneLeft31,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[30],
              ),

              new Positioned(
                top: squarePositioneTop32,
                left: squarePositioneLeft32,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[31],
              ),

              new Positioned(
                top: squarePositioneTop33,
                left: squarePositioneLeft33,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[32],
              ),

              new Positioned(
                top: squarePositioneTop34,
                left: squarePositioneLeft34,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[33],
              ),

              new Positioned(
                top: squarePositioneTop35,
                left: squarePositioneLeft35,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[34],
              ),

              new Positioned(
                top: squarePositioneTop36,
                left: squarePositioneLeft36,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[35],
              ),

              new Positioned(
                top: squarePositioneTop37,
                left: squarePositioneLeft37,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[36],
              ),

              new Positioned(
                top: squarePositioneTop38,
                left: squarePositioneLeft38,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[37],
              ),

              new Positioned(
                top: squarePositioneTop39,
                left: squarePositioneLeft39,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[38],
              ),

              new Positioned(
                top: squarePositioneTop40,
                left: squarePositioneLeft40,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[39],
              ),

              new Positioned(
                top: squarePositioneTop41,
                left: squarePositioneLeft41,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[40],
              ),

              new Positioned(
                top: squarePositioneTop42,
                left: squarePositioneLeft42,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[41],
              ),

              new Positioned(
                top: squarePositioneTop43,
                left: squarePositioneLeft43,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[42],
              ),

              new Positioned(
                top: squarePositioneTop44,
                left: squarePositioneLeft44,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[43],
              ),

              new Positioned(
                top: squarePositioneTop45,
                left: squarePositioneLeft45,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[44],
              ),

              new Positioned(
                top: squarePositioneTop46,
                left: squarePositioneLeft46,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[45],
              ),

              new Positioned(
                top: squarePositioneTop47,
                left: squarePositioneLeft47,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[46],
              ),

              new Positioned(
                top: squarePositioneTop48,
                left: squarePositioneLeft48,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[47],
              ),

              new Positioned(
                top: squarePositioneTop49,
                left: squarePositioneLeft49,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[48],
              ),

              new Positioned(
                top: squarePositioneTop50,
                left: squarePositioneLeft50,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[49],
              ),

              new Positioned(
                top: squarePositioneTop51,
                left: squarePositioneLeft51,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[50],
              ),

              new Positioned(
                top: squarePositioneTop52,
                left: squarePositioneLeft52,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[51],
              ),

              new Positioned(
                top: squarePositioneTop53,
                left: squarePositioneLeft53,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[52],
              ),

              new Positioned(
                top: squarePositioneTop54,
                left: squarePositioneLeft54,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[53],
              ),

              new Positioned(
                top: squarePositioneTop55,
                left: squarePositioneLeft55,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[54],
              ),

              new Positioned(
                top: squarePositioneTop56,
                left: squarePositioneLeft56,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[55],
              ),

              new Positioned(
                top: squarePositioneTop57,
                left: squarePositioneLeft57,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[56],
              ),

              new Positioned(
                top: squarePositioneTop58,
                left: squarePositioneLeft58,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[57],
              ),

              new Positioned(
                top: squarePositioneTop59,
                left: squarePositioneLeft59,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[58],
              ),

              new Positioned(
                top: squarePositioneTop60,
                left: squarePositioneLeft60,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[59],
              ),

              new Positioned(
                top: squarePositioneTop61,
                left: squarePositioneLeft61,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[60],
              ),

              new Positioned(
                top: squarePositioneTop62,
                left: squarePositioneLeft62,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[61],
              ),

              new Positioned(
                top: squarePositioneTop63,
                left: squarePositioneLeft63,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[62],
              ),

              new Positioned(
                top: squarePositioneTop64,
                left: squarePositioneLeft64,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: squareWidgetList[63],
              ),

              posSelect,

              piecePos1,
              piecePos2,
              piecePos3,
              piecePos4,
              piecePos5,
              piecePos6,
              piecePos7,
              piecePos8,
              piecePos9,
              piecePos10,
              piecePos11,
              piecePos12,
              piecePos13,
              piecePos14,
              piecePos15,
              piecePos16,
              piecePos17,
              piecePos18,
              piecePos19,
              piecePos20,
              piecePos21,
              piecePos22,
              piecePos23,
              piecePos24,
              piecePos25,
              piecePos26,
              piecePos27,
              piecePos28,
              piecePos29,
              piecePos30,
              piecePos31,
              piecePos32,

              piecePos33,
              piecePos34,
              piecePos35,
              piecePos36,
              piecePos37,
              piecePos38,
              piecePos39,
              piecePos40,
              piecePos41,
              piecePos42,

              new Positioned(
                top: targetTop1,
                left: targetLeft1,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[0],
              ),
              new Positioned(
                top: targetTop2,
                left: targetLeft2,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[1],
              ),
              new Positioned(
                top: targetTop3,
                left: targetLeft3,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[2],
              ),
              new Positioned(
                top: targetTop4,
                left: targetLeft4,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[3],
              ),
              new Positioned(
                top: targetTop5,
                left: targetLeft5,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[4],
              ),
              new Positioned(
                top: targetTop6,
                left: targetLeft6,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[5],
              ),
              new Positioned(
                top: targetTop7,
                left: targetLeft7,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[6],
              ),
              new Positioned(
                top: targetTop8,
                left: targetLeft8,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[7],
              ),
              new Positioned(
                top: targetTop9,
                left: targetLeft9,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[8],
              ),
              new Positioned(
                top: targetTop10,
                left: targetLeft10,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[9],
              ),
              new Positioned(
                top: targetTop11,
                left: targetLeft11,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[10],
              ),
              new Positioned(
                top: targetTop12,
                left: targetLeft12,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[11],
              ),
              new Positioned(
                top: targetTop13,
                left: targetLeft13,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[12],
              ),
              new Positioned(
                top: targetTop14,
                left: targetLeft14,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[13],
              ),
              new Positioned(
                top: targetTop15,
                left: targetLeft15,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[14],
              ),
              new Positioned(
                top: targetTop16,
                left: targetLeft16,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[15],
              ),
              new Positioned(
                top: targetTop17,
                left: targetLeft17,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[16],
              ),
              new Positioned(
                top: targetTop18,
                left: targetLeft18,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[17],
              ),
              new Positioned(
                top: targetTop19,
                left: targetLeft19,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[18],
              ),
              new Positioned(
                top: targetTop20,
                left: targetLeft20,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[19],
              ),
              new Positioned(
                top: targetTop21,
                left: targetLeft21,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[20],
              ),
              new Positioned(
                top: targetTop22,
                left: targetLeft22,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[21],
              ),
              new Positioned(
                top: targetTop23,
                left: targetLeft23,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[22],
              ),
              new Positioned(
                top: targetTop24,
                left: targetLeft24,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[23],
              ),
              new Positioned(
                top: targetTop25,
                left: targetLeft25,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[24],
              ),
              new Positioned(
                top: targetTop26,
                left: targetLeft26,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[25],
              ),
              new Positioned(
                top: targetTop27,
                left: targetLeft27,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[26],
              ),
              new Positioned(
                top: targetTop28,
                left: targetLeft28,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[27],
              ),
              new Positioned(
                top: targetTop29,
                left: targetLeft29,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[28],
              ),
              new Positioned(
                top: targetTop30,
                left: targetLeft30,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[29],
              ),
              new Positioned(
                top: targetTop31,
                left: targetLeft31,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[30],
              ),
              new Positioned(
                top: targetTop32,
                left: targetLeft32,
                height:squareWH.toDouble(),
                width: squareWH.toDouble(),
                child: targetsList[31],
              ),


              Container(
                width: Get.width,
                height: Get.width,
                child: CustomPaint(
                  size: Size(Get.width,Get.width),
                  painter: ArrowCustomPainter(bRedrawArrow, arrowX1, arrowY1, arrowX2, arrowY2),
                ),
              ),


              Container(
                width: Get.width,
                height: Get.width,
                child: CustomPaint(
                  size: Size(Get.width,Get.width),
                  painter: HintCustomPainter(bRedrawHint, hintX1, hintY1, hintX2, hintY2),
                ),
              ),

              Positioned(
                top: stockfishTimeTop,
                left: stockfishTimeLeft,
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
                        stockfishThinkingTimeClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringButtAITime,
                            style: TextStyle(color: Colors.white,
                              fontSize: 14,),
                          ),

                        ],
                      ),
                    )
                ),
              ),


              Positioned(
                top: whiteIDTop,
                left: whiteIDLeft,
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
                          playerWhiteIDClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.sports_volleyball, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringPlayerWhiteID,
                            style: TextStyle(color: WhiteIDColor,
                              fontSize: 14,),

                          ),
                      ]
                    )
                ),
              ),
              ),


              Positioned(
                top: blackIDTop,
                left: blackIDLeft,
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
                        playerBlackIDClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.sports_basketball, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringPlayerBlackID,
                               style: TextStyle(color: BlackIDColor,
                                fontSize: 14,
                               ),
                          ),

                        ],
                      ),
                    )
                ),
              ),


              Positioned(
                top: rotateBoardTop,
                left: rotateBoardLeft,
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
                        rotateBoardClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        //margin: const EdgeInsets.only(left: 0.0),
                        children: [
                          Icon(Icons.autorenew, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringRotateBoard,
                            style: TextStyle(color: Colors.white,
                              fontSize: 14,
                            ),
                          ),

                        ],
                      ),
                    )
                ),
              ),


              Positioned(
                top: showHintTop,
                left: showHintLeft,
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
                        showHintClick();
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.flare, color: Colors.white,),
                            SizedBox(width: 5),
                            Text(stringShowHint,
                              style: TextStyle(color: Colors.white,
                                fontSize: 14,),
                            ),
                          ]
                      )
                  ),
                ),
              ),

              Positioned(
                top: stepBackTop,
                left: stepBackLeft,
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
                        stepBackClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.replay, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringMoveBack,
                            style: TextStyle(color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              ),



              Positioned(
                top: newGameTop,
                left: newGameLeft,
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
                        newGameClick();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.space_dashboard_sharp, color: Colors.white,),
                          SizedBox(width: 5),
                          Text(stringNewGame,
                            style: TextStyle(color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              ),

              Positioned(
                top: 0,
                left: 10,
                height:30,
                width: 190,
                child: Container(
                  width: 190,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text(topPlayerName,
                        style: TextStyle(color: TopPlayerColor,
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 9.0*squareWH - 10.0,
                left: 10,
                height:30,
                width: 190,
                child: Container(

                  width: 190,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text(bottomPlayerName,
                        style: TextStyle(color: BottomPlayerColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                ),
              ),

              Positioned(
                top: stockfishBusyTop,
                left: stockfishBusyLeft,
                height:20,
                width: 80,
                child: Container(
                    decoration: BoxDecoration(
                        color: hexToColor(boardSquareSelectColor),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    width: 80,
                    height: 20,

                    //child: SpinKitFadingCircle(color: Colors.white)
                    child: SpinKitThreeBounce(color: Colors.white)
                ),
              ),

              Positioned(
                top: humanBusyTop,
                left: humanBusyLeft,
                height:20,
                width: 24,
                child: Container(
                    decoration: BoxDecoration(
                        color: hexToColor(boardSquareSelectColor),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    width: 24,
                    height: 20,

                    child: SpinKitDoubleBounce(color: Colors.white) //SpinKitHourGlass SpinKitFadingCircle SpinKitDualRing
                    //child: SpinKitSpinningCircle(color: Colors.white)
                ),
              ),
          ],
        ),
          )
        ),


        ],
      )
      ),
    )
    );

  }
}

class ArrowCustomPainter extends CustomPainter {
  final bool _bRedrawArrow;
  final double _x1, _y1, _x2, _y2;

  ArrowCustomPainter(this._bRedrawArrow, this._x1, this._y1, this._x2, this._y2);

  Color hexToColor(String code, double opacity) {
    Color c = Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    return c.withOpacity(opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_bRedrawArrow) {
      final paintArrowPolygon = new Paint()
        ..color = hexToColor("#67c5e9", 0.6)
        ..style = PaintingStyle.stroke
        ..style = PaintingStyle.fill
        ..strokeWidth = 1.0;

      double angle1 = getAngle(_x2, _y2, _x1, _y1);
      List<double> xy0 = projectPoint(_x2, _y2, angle1, 25.0);
      List<double> xy0B = projectPoint(_x2, _y2, angle1, 16.0);
      List<double> xy0C = projectPoint(xy0B[0], xy0B[1], angle1 + pi/2.0, 4.0);
      List<double> xy0D = projectPoint(xy0B[0], xy0B[1], angle1 - pi/2.0, 4.0);

      List<double> xyE = projectPoint(_x1, _y1, angle1 + pi/2.0, 4.0);
      List<double> xyF = projectPoint(_x1, _y1, angle1 - pi/2.0, 4.0);

      List<double> xy1 = rotatePoint(xy0[0], xy0[1], _x2, _y2, pi*0.2);
      List<double> xy2 = rotatePoint(xy0[0], xy0[1], _x2, _y2, -pi*0.2);

      Path pathPolygon = Path();
      pathPolygon.moveTo(_x1, _y1);
      pathPolygon.lineTo(xyE[0], xyE[1]);
      pathPolygon.lineTo(xy0C[0], xy0C[1]);
      pathPolygon.lineTo(xy1[0], xy1[1]);
      pathPolygon.lineTo(_x2, _y2);
      pathPolygon.lineTo(xy2[0], xy2[1]);
      pathPolygon.lineTo(xy0D[0], xy0D[1]);
      pathPolygon.lineTo(xyF[0], xyF[1]);
      pathPolygon.lineTo(_x1, _y1);

      canvas.drawPath(pathPolygon, paintArrowPolygon);

    }
  }


  /// Rotate a point around a center.
  List<double> rotatePoint(
      double x, double y, double cx, double cy, double angle) {
    final s = sin(angle);
    final c = cos(angle);
    final px = x - cx;
    final py = y - cy;

    final nx = px * c - py * s;
    final ny = px * s + py * c;

    return [nx + cx, ny + cy];
  }

  /// Get the distance between two points.
  double getDistance(double x0, double y0, double x1, double y1) =>
      sqrt(pow(y1 - y0, 2) + pow(x1 - x0, 2));

  /// Get an angle (radians) between two points.
  double getAngle(double x0, double y0, double x1, double y1) =>
      atan2(y1 - y0, x1 - x0);

  /// Move a point in an angle by a distance.
  List<double> projectPoint(
      double x0, double y0, double angle, double distance) =>
      [cos(angle) * distance + x0, sin(angle) * distance + y0];


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class HintCustomPainter extends CustomPainter {
  final bool _bRedrawHint;
  final double _x1, _y1, _x2, _y2;

  HintCustomPainter(this._bRedrawHint, this._x1, this._y1, this._x2, this._y2);

  Color hexToColor(String code, double opacity) {
    Color c = Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    return c.withOpacity(opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_bRedrawHint) {
      final paintArrowPolygon = new Paint()
        ..color = hexToColor("#4aa652", 0.8)
        ..style = PaintingStyle.stroke
        ..style = PaintingStyle.fill
        ..strokeWidth = 1.0;

      double angle1 = getAngle(_x2, _y2, _x1, _y1);
      List<double> xy0 = projectPoint(_x2, _y2, angle1, 25.0);
      List<double> xy0B = projectPoint(_x2, _y2, angle1, 16.0);
      List<double> xy0C = projectPoint(xy0B[0], xy0B[1], angle1 + pi/2.0, 4.0);
      List<double> xy0D = projectPoint(xy0B[0], xy0B[1], angle1 - pi/2.0, 4.0);

      List<double> xyE = projectPoint(_x1, _y1, angle1 + pi/2.0, 4.0);
      List<double> xyF = projectPoint(_x1, _y1, angle1 - pi/2.0, 4.0);

      List<double> xy1 = rotatePoint(xy0[0], xy0[1], _x2, _y2, pi*0.2);
      List<double> xy2 = rotatePoint(xy0[0], xy0[1], _x2, _y2, -pi*0.2);

      Path pathPolygon = Path();
      pathPolygon.moveTo(_x1, _y1);
      pathPolygon.lineTo(xyE[0], xyE[1]);
      pathPolygon.lineTo(xy0C[0], xy0C[1]);
      pathPolygon.lineTo(xy1[0], xy1[1]);
      pathPolygon.lineTo(_x2, _y2);
      pathPolygon.lineTo(xy2[0], xy2[1]);
      pathPolygon.lineTo(xy0D[0], xy0D[1]);
      pathPolygon.lineTo(xyF[0], xyF[1]);
      pathPolygon.lineTo(_x1, _y1);

      canvas.drawPath(pathPolygon, paintArrowPolygon);

    }
  }

  /// Rotate a point around a center.
  List<double> rotatePoint(
      double x, double y, double cx, double cy, double angle) {
    final s = sin(angle);
    final c = cos(angle);
    final px = x - cx;
    final py = y - cy;

    final nx = px * c - py * s;
    final ny = px * s + py * c;

    return [nx + cx, ny + cy];
  }

  /// Get the distance between two points.
  double getDistance(double x0, double y0, double x1, double y1) =>
      sqrt(pow(y1 - y0, 2) + pow(x1 - x0, 2));

  /// Get an angle (radians) between two points.
  double getAngle(double x0, double y0, double x1, double y1) =>
      atan2(y1 - y0, x1 - x0);

  /// Move a point in an angle by a distance.
  List<double> projectPoint(
      double x0, double y0, double angle, double distance) =>
      [cos(angle) * distance + x0, sin(angle) * distance + y0];


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
