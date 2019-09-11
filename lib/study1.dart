import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    title: 'My app', // used by the OS task switcher
    home: new MyButton(),
  ));
}

class TutorialHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            tooltip: "xxxxxxxxxxxxxxxxxxx",
            onPressed: null),
        title: new Text("text title"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.search), tooltip: "search", onPressed: null)
        ],
      ),
      body: new Center(
        child: new Text("hello world"),
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: "add", child: new Icon(Icons.add), onPressed: null),
    );
  }
}

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Counter();
  }
}

class Counter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CounterState();
  }
}

class _CounterState extends State<Counter> {
  int _counter = 0;

  void _increment() {
    setState(() {
      // This call to setState tells the Flutter framework that
      // something has changed in this State, which causes it to rerun
      // the build method below so that the display can reflect the
      // updated values. If we changed _counter without calling
      // setState(), then the build method would not be called again,
      // and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance
    // as done by the _increment method above.
    // The Flutter framework has been optimized to make rerunning
    // build methods fast, so that you can just rebuild anything that
    // needs updating rather than having to individually change
    // instances of widgets.
    return new Row(
      children: <Widget>[
        new RaisedButton(child: new Text("Increment"), onPressed: _increment),
        new Expanded(child: new Text("count : $_counter"))
      ],
    );
  }
}
