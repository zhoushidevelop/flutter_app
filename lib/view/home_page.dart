import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshableList();
  }
}

class RefreshableList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RefreshableListState();
  }
}

class RefreshableListState extends State<RefreshableList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => null;
}
