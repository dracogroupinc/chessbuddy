cmake_minimum_required(VERSION 3.4.1)

file(GLOB_RECURSE cppPaths "../ios/Stockfish/src/*.cpp")
add_library(
  stockfish
  SHARED
  ../ios/FlutterStockfish/ffi.cpp
  ${cppPaths}
)

#add_library( libDDSFuncs SHARED IMPORTED )
#set_target_properties(libDDSFuncs PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libDDSFuncs.so)

file(DOWNLOAD https://tests.stockfishchess.org/api/nn/nn-ac07bd334b62.nnue ${CMAKE_BINARY_DIR}/nn-ac07bd334b62.nnue)
