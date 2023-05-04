// ignore_for_file: dead_code

import 'dart:io';

//编译方式
enum CompilationMode {
  isDebug,
  isRelease,
}

class NetConfig {
  static String version() {
    if (Platform.isIOS) {
      return '1.0.0';
    } else if (Platform.isAndroid) {
      return '1.0.1';
    } else {
      return '';
    }
  }

  static CompilationMode compilationMode() {
    bool isRelease = false;
    if (isRelease) {
      return CompilationMode.isRelease;
    } else {
      return CompilationMode.isDebug;
    }
  }
}
