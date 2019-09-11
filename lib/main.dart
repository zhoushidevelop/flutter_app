import 'package:flutter/material.dart';
import 'view/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '玩Android-Flutter',
      theme: ThemeData(
        primaryColor: Colors.teal,
        backgroundColor: Colors.grey,
        accentColor: Color(0xFF26A69A),
        dividerColor: Colors.blueGrey,
        textTheme: TextTheme(
            body1: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        )),
      ),
      routes: {},
      home: MainPage(),
    );
  }
}


