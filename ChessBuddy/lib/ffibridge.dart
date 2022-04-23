import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

class FFIBridge {
  /*
  Future<DynamicLibrary> _getAndroidDynamicLibrary(String libraryName) async {
    try {
      return DynamicLibrary.open(libraryName);
    } catch (_) {
      try {
        final String? nativeLibraryDirectory = await _getNativeLibraryDirectory();

        return DynamicLibrary.open('$nativeLibraryDirectory/$libraryName');
      } catch (_) {
        try {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final String packageName = packageInfo.packageName;

          return DynamicLibrary.open('/data/data/$packageName/lib/$libraryName');
        } catch (_) {
          rethrow;
        }
      }
    }
  }
  */
  static bool initialize() {
    try {
      /*
      nativeApiLib = Platform.isMacOS || Platform.isIOS
          ? DynamicLibrary.process() // macos and ios
          : (DynamicLibrary.open(Platform.isWindows // windows
          ? 'api.dll'
          : 'libapi.so')); // android and linux

       */
      //nativeApiLib = DynamicLibrary.open('libapi.so');
      nativeApiLib = DynamicLibrary.open('libapi.so');
    } catch (error) {
      sleep(Duration(seconds:2));

      nativeApiLib = DynamicLibrary.open('libapi.so');
      /*
      nativeApiLib = Platform.isMacOS || Platform.isIOS
          ? DynamicLibrary.process() // macos and ios
          : (DynamicLibrary.open(Platform.isWindows // windows
          ? 'api.dll'
          : 'libapi.so')); // and

       */
    }


    if (nativeApiLib == null){
      sleep(Duration(seconds:2));

      nativeApiLib = DynamicLibrary.open('libapi.so');
      /*
      nativeApiLib = Platform.isMacOS || Platform.isIOS
          ? DynamicLibrary.process() // macos and ios
          : (DynamicLibrary.open(Platform.isWindows // windows
          ? 'api.dll'
          : 'libapi.so'));

       */
    }
    //final _add = nativeApiLib
    //    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add');
    //add = _add.asFunction<int Function(int, int)>();

    //final _cap = nativeApiLib.lookup<
    //    NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('capitalize');
    //_capitalize = _cap.asFunction<Pointer<Utf8> Function(Pointer<Utf8>)>();

    final _initApp =
        nativeApiLib.lookup<NativeFunction<Void Function()>>('initApp');
    initApp = _initApp.asFunction<void Function()>();

    final _restartApp =
        nativeApiLib.lookup<NativeFunction<Void Function()>>('restartApp');
    restartApp = _restartApp.asFunction<void Function()>();

    //final _getSB = nativeApiLib
    //    .lookup<NativeFunction<Pointer<Utf8> Function()>>('getScreenBuffer');
    //_getScreenBuffer = _getSB.asFunction<Pointer<Utf8> Function()>();


    final _getSR = nativeApiLib
        .lookup<NativeFunction<Pointer<Utf8> Function()>>('getStockfishResult');
    _getStockfishResult = _getSR.asFunction<Pointer<Utf8> Function()>();

    //final _pk = nativeApiLib
    //    .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('pushString');
    //_pushKey = _pk.asFunction<void Function(Pointer<Utf8>)>();


    final _oneC = nativeApiLib
        .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>('oneCommand');
    _oneCommand = _oneC.asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

    //final _whatThing = nativeApiLib
    //    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('whatThing');
    //whatThing = _whatThing.asFunction<int Function(int, int)>();

    return true;
  }

  static bool initialize2() {
    nativeApiLib = Platform.isMacOS || Platform.isIOS
        ? DynamicLibrary.process() // macos and ios
        : (DynamicLibrary.open(Platform.isWindows // windows
        ? 'api.dll'
        : 'libapi.so')); // android and linux


    //final _add = nativeApiLib
    //    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add');
    //add = _add.asFunction<int Function(int, int)>();

    //final _cap = nativeApiLib.lookup<
    //    NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('capitalize');
    //_capitalize = _cap.asFunction<Pointer<Utf8> Function(Pointer<Utf8>)>();

    final _initApp =
    nativeApiLib.lookup<NativeFunction<Void Function()>>('initApp');
    initApp = _initApp.asFunction<void Function()>();

    final _restartApp =
    nativeApiLib.lookup<NativeFunction<Void Function()>>('restartApp');
    restartApp = _restartApp.asFunction<void Function()>();

    //final _getSB = nativeApiLib
    //    .lookup<NativeFunction<Pointer<Utf8> Function()>>('getScreenBuffer');
    //_getScreenBuffer = _getSB.asFunction<Pointer<Utf8> Function()>();


    final _getSR = nativeApiLib
        .lookup<NativeFunction<Pointer<Utf8> Function()>>('getStockfishResult');
    _getStockfishResult = _getSR.asFunction<Pointer<Utf8> Function()>();

    //final _pk = nativeApiLib
    //    .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('pushString');
    //_pushKey = _pk.asFunction<void Function(Pointer<Utf8>)>();


    final _oneC = nativeApiLib
        .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>('oneCommand');
    _oneCommand = _oneC.asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

    //final _whatThing = nativeApiLib
    //    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('whatThing');
    //whatThing = _whatThing.asFunction<int Function(int, int)>();

    return true;
  }

  static late DynamicLibrary nativeApiLib;
  //static late Function add;
  //static late Function _capitalize;
  static late Function initApp;
  static late Function restartApp;
  //static late Function _getScreenBuffer;
  //static late Function _pushKey;
  //static late Function whatThing;
  static late Function _getStockfishResult;
  static late Function _oneCommand;

  /*
  static String capitalize(String str) {
    final _str = str.toNativeUtf8();
    Pointer<Utf8> res = _capitalize(_str);
    calloc.free(_str);
    return res.toDartString();
  }

  static void pushKey(String str) {
    final _str = str.toNativeUtf8();
    _pushKey(_str);
    calloc.free(_str);
  }

  static String getScreenBuffer() {
    Pointer<Utf8> res = _getScreenBuffer();
    return res.toDartString();
  }

   */

  static String getStockfishBestMove() {
    Pointer<Utf8> res = _getStockfishResult();
    return res.toDartString();
  }

  static void oneUCICommand(String pLine, String gLine) {
    final _strP = pLine.toNativeUtf8();
    final _strG = gLine.toNativeUtf8();

    _oneCommand(_strP, _strG);

    calloc.free(_strP);
    calloc.free(_strG);
  }
}
