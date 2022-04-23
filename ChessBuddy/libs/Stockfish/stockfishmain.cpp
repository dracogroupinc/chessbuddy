/*
  Stockfish, a UCI chess playing engine derived from Glaurung 2.1
  Copyright (C) 2004-2021 The Stockfish developers (see AUTHORS file)

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
//#include <string>
//#include <cstring>

#include "bitboard.h"
#include "endgame.h"
#include "position.h"
#include "psqt.h"
#include "search.h"
#include "syzygy/tbprobe.h"
#include "thread.h"
#include "tt.h"
#include "uci.h"

typedef void (*StockfishCallback)(void* context); // Callback function pointer type
StockfishCallback callback_;

extern "C" int stockfishmain(int argc, char* argv[], StockfishCallback callback);
extern "C" char *getStockfishData();
extern "C" void oneStockfishCommand(char *pLine, char *gLine);

using namespace Stockfish;

static char stockfishBestMove[99];
static int stockfishBestMoveReady = 0;

static int num = 0;

/*
int main(int argc, char* argv[]) {


  std::cout << Stockfish::engine_info() << std::endl;

  CommandLine::init(argc, argv);
  UCI::init(Options);
  Tune::init();
  PSQT::init();
  Bitboards::init();
  Position::init();
  Bitbases::init();
  Endgames::init();
  Threads.set(size_t(Options["Threads"]));
  Search::clear(); // After threads are up
  Eval::NNUE::init();

  UCI::loop(argc, argv);

  Threads.set(0);

  return 0;
}


int is_stockfish_running()
{
    return 0;
}
*/

void updateStockfishBestMove(std::string bm)
{
    strcpy(stockfishBestMove, bm.c_str());
    //std::sprintf(stockfishBestMove, "%s", bm);
    stockfishBestMoveReady = 1;
}

void oneStockfishCommand(char *pLine, char *gLine)
{
    stockfishBestMoveReady = 0;
    UCI::oneCommand(pLine, gLine);
}

char *getStockfishData()
{
/*
    std::string str = "abc";
    str.append(std::to_string(num));
    strcpy(stockfishData, str.c_str());
    */
    //std::string::append(std::to_string(num), stockfishData);
    //std::strcat(stockfishData, std::to_string(num));
    //char num_char[99 + sizeof(char)];

    if (stockfishBestMoveReady == 1){
        stockfishBestMoveReady = 0;
        Search::clear();
    }
    else{
        std::sprintf(stockfishBestMove, "%d", 0);

        //strcpy(stockfishData, "abc1");

        //num++;
    }

    //callback_(stockfishData);

    return stockfishBestMove;
}


//extern "C" __attribute__((visibility("default"))) __attribute__((used)) int stockfishmain(int argc, char* argv[]) {
int stockfishmain(int argc, char* argv[], StockfishCallback callback) {
  //std::cout << engine_info() << std::endl;
  callback_  = callback;

  CommandLine::init(argc, argv);
  UCI::init(Options);
  Tune::init();
  PSQT::init();
  Bitboards::init();
  Position::init();
  Bitbases::init();
  Endgames::init();
  Threads.set(size_t(Options["Threads"]));
  Search::clear(); // After threads are up
  Eval::NNUE::init();

  //UCI::loop2(argc, argv);

  //Threads.set(0);

  return 0;
}