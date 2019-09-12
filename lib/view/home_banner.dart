import 'dart:async';

import 'package:flutter/material.dart';

class HomeBanner extends StatefulWidget {
  final List _bannerList;

  final Function(dynamic item) _onTap;

  HomeBanner(this._bannerList, this._onTap);

  @override
  State<StatefulWidget> createState() {
    return _HomeBannerState();
  }
}

class _HomeBannerState extends State<HomeBanner> {
  PageController _pageController;
  Timer _timer;
  int realIndex = 1;
  int virtualIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: realIndex,
    );
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _pageController.animateToPage(
        realIndex + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            children: _buildBanner(),
            controller: _pageController,
            onPageChanged: _onPageChanged,
          ),
          buildHint(),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    realIndex = index;
    int count = widget._bannerList.length;
    if (index == 0) {
      virtualIndex = count - 1;
      _pageController.jumpToPage(count);
    } else if (index == count + 1) {
      virtualIndex = 0;
      _pageController.jumpToPage(1);
    } else {
      virtualIndex = index - 1;
    }
    setState(() {

    });
  }

  final hintStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  Widget buildHint() {
    var item = widget._bannerList.elementAt(virtualIndex);
    return Container(
      color: Colors.grey,
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(item['title'], style: hintStyle,)),
          Text(
            '${virtualIndex + 1}/${widget._bannerList.length}',
            style: hintStyle,
          ),
        ],
      ),
    );
  }

  _buildBanner() {
    List<Widget> list = [];
    list.add(_buildBannerItem(
        widget._bannerList.elementAt(widget._bannerList.length - 1)));
    list.addAll(widget._bannerList
        .map((item) => _buildBannerItem(item))
        .toList(growable: false));
    list.add(_buildBannerItem(widget._bannerList.elementAt(0)));
    return list;
  }

  Widget _buildBannerItem(elementAt) {
    return GestureDetector(
      onTap: widget._onTap(elementAt),
      child: Image.network(
        elementAt['imagePath'],
        fit: BoxFit.fill,
      ),
    );
  }


}
