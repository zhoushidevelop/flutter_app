import 'package:flutter/material.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/image_util.dart';
import 'package:flutter_app/utils/nav_util.dart';
import 'package:flutter_app/view/wechat_page.dart';

import 'drawer_page.dart';
import 'home_page.dart';
import 'knowledge_tree_page.dart';
import 'navigation_page.dart';
import 'project_page.dart';
import 'search_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State {
  int _selectIndex = 0;

  final _pages = [
    HomePage(),
    WeChatPage(),
    ProjectPage(),
    NavigationPage(),
    KnowledgeTreePage(),
  ];

  final _bottomItems = [
    _Item('首页', 'ic_home'),
    _Item('公众号', 'ic_wechat'),
    _Item('项目', 'ic_project'),
    _Item('网站导航', 'ic_navigation'),
    _Item('知识体系', 'ic_dashboard'),
  ];

  List<BottomNavigationBarItem> bottomItemList;
  PageController _pageController;
  DateTime lastBackTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectIndex,
      keepPage: true,
    );
    if (bottomItemList == null) {
      bottomItemList = _bottomItems
          .map((item) => BottomNavigationBarItem(
              icon: Image.asset(
                ImageUtils.getImagePath(item.icon),
                width: 25,
                height: 25,
                color: Colors.grey,
              ),
              activeIcon: Image.asset(
                ImageUtils.getImagePath(item.icon),
                width: 25,
                height: 25,
                color: Colors.teal,
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                ),
              )))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          drawer: Drawer(
            child: DrawerPage(),
          ),
          appBar: AppBar(
            title: Text(_selectIndex == 0
                ? '玩安卓'
                : _bottomItems.elementAt(_selectIndex).name),
            automaticallyImplyLeading: true,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    NavUtil.navTo(context, SearchPage());
                  })
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: bottomItemList,
            currentIndex: _selectIndex,
            type: BottomNavigationBarType.fixed,
            fixedColor: Theme.of(context).primaryColor,
            onTap: (int index) {
              setState(() {
                _selectIndex = index;
                _pageController.jumpToPage(_selectIndex);
              });
            },
          ),
          body: PageView(
//            children: _pages.children,
            children: IndexedStack(
              index: _selectIndex,
              children: _pages,
            ).children,
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        onWillPop: () {
          DateTime timeNow = DateTime.now();
          if (timeNow.difference(lastBackTime).inSeconds > 1) {
            HintUtil.toast(context, '再按一次退出...');
            lastBackTime = timeNow;
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        });
  }
}



class _Item {
  String name;

  String icon;

  _Item(this.name, this.icon);
}
