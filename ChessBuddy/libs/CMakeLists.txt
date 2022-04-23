cmake_minimum_required(VERSION 3.10)
#cmake_minimum_required(VERSION 3.4.1)
project(api LANGUAGES CXX C)

set (CMAKE_CXX_STANDARD 17)
#set (CMAKE_CXX_STANDARD 11)

add_library(stockfish
  STATIC
  ./Stockfish/benchmark.cpp
  ./Stockfish/bitbase.cpp
  ./Stockfish/bitboard.cpp
  ./Stockfish/endgame.cpp
  ./Stockfish/evaluate.cpp
  ./Stockfish/main.cpp
  ./Stockfish/stockfishmain.cpp
  ./Stockfish/material.cpp
  ./Stockfish/misc.cpp
  ./Stockfish/movegen.cpp
  ./Stockfish/movepick.cpp
  ./Stockfish/pawns.cpp
  ./Stockfish/position.cpp
  ./Stockfish/psqt.cpp
  ./Stockfish/search.cpp
  ./Stockfish/thread.cpp
  ./Stockfish/timeman.cpp
  ./Stockfish/tt.cpp
  ./Stockfish/tune.cpp
  ./Stockfish/uci.cpp
  ./Stockfish/ucioption.cpp
  ./Stockfish/nnue/evaluate_nnue.cpp
  ./Stockfish/nnue/features/half_ka_v2_hm.cpp
  ./Stockfish/syzygy/tbprobe.cpp
)


target_include_directories(stockfish 
    PRIVATE
    ./Stockfish/incbin
	./Stockfish/nnue
	./Stockfish/nnue/features
	./Stockfish/nnue/layers
	./Stockfish/syzygy
    ./Stockfish/
)

add_library(api
  SHARED
  ./api.cpp
  exports.def
)

target_include_directories(api 
    PRIVATE
	./Stockfish/incbin
	./Stockfish/nnue
	./Stockfish/nnue/features
	./Stockfish/nnue/layers
	./Stockfish/syzygy
    ./Stockfish/
)

target_link_libraries(api PRIVATE stockfish)
