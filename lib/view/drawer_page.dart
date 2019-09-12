import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/utils/account_util.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/image_util.dart';
import 'package:flutter_app/utils/nav_util.dart';

import 'favorite_page.dart';
import 'login_page.dart';

class DrawerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerState();
  }
}

class DrawerState extends State {
  String _userName = '';
  StreamSubscription loginSubscription;

  @override
  void initState() {
    super.initState();
    loginSubscription = eventBus.on<Login>().listen((data) {
      refreshUser();
    });
    refreshUser();
  }

  void refreshUser() {
    AccountUtil.getUserName().then((name) {
      if (name != null) {
        setState(() {
          _userName = name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (_userName.isEmpty) {
              NavUtil.navTo(context, LoginPage());
            } else {
              HintUtil.toast(context, '你好...$_userName');
            }
          },
          child: Container(
            color: Theme
                .of(context)
                .primaryColor,
            height: 180,
            padding: EdgeInsets.only(top: MediaQuery
                .of(context)
                .padding
                .top),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ImageUtils.getRoundImage('ic_avatar', 40),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Text(
                    _userName.isEmpty ? '还没有登录' : _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              getItem('ic_favorite_not', '收藏夹', () {
                loginOrDirect(FavoritePage());
              }),
              getItem('ic_todo', '任务清单', () {
                loginOrDirect(FavoritePage());
              }),
              getItem('ic_about', '关于', () {
                loginOrDirect(FavoritePage());
              }),
              getlogout(),
            ],
          ),
        )
      ],
    );
  }

  void loginOrDirect(Widget page) {
    if (_userName.isEmpty) {
      HintUtil.toast(context, '请先登录');
      NavUtil.navTo(context, LoginPage());
    } else {
      NavUtil.navTo(context, page);
    }
  }

  getlogout() {
    if (_userName.isEmpty) {
      return Container();
    } else {
      return getItem('ic_logout', '退出登录', () {
        HintUtil.alert(context, '退出登录', '确定要退出吗？', () {
          HintUtil.toast(context, '退出登录成功');
        }, () {
          NavUtil.pop(context);
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    loginSubscription.cancel();
  }
}


getItem(imageName, title, onTap) {
  return ListTile(
    leading: Image.asset(
      ImageUtils.getImagePath(imageName),
      width: 20,
      height: 20,
      color: Colors.black54,
    ),
    title: Text(title),
    onTap: onTap,
  );
}


