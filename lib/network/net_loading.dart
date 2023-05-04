import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class Loading {
  static show() {
    SmartDialog.showLoading();
  }

  static showInfo(String info) {
    SmartDialog.showToast(info, alignment: Alignment.center);
  }

  static dismiss() {
    SmartDialog.dismiss();
  }
}
