import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavUtil {
  static Future navTo(BuildContext context, Widget page) {
    return Navigator.push(
        context, CupertinoPageRoute(builder: (context) => page));
  }

  static pop(BuildContext context) {
    Navigator.pop(context);
  }
}
