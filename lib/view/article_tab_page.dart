import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/view/article_item_view.dart';
import 'package:flutter_app/view/empty_view.dart';
import 'package:flutter_app/view/error_view.dart';
import 'package:flutter_app/view/loading_view.dart';
import 'package:flutter_app/view/refreshable_list.dart';

class ArticleTabPage extends StatefulWidget {
  Future api;
  List data;
  int initPos;

  ArticleTabPage(this.api, this.data, {this.initPos = 1});

  @override
  State<StatefulWidget> createState() {
    return _ArticleTabPageState();
  }
}

class _ArticleTabPageState extends State<ArticleTabPage> {
  Future request;
  List data;
  bool isLoading = true;
  bool isEmpty = false;
  bool isError = false;
  String errorInfo = "";

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingView();
    } else if (isError) {
      return ErrorView(
        error: errorInfo,
        retry: retry(),
      );
    } else if (isEmpty) {
      return EmptyView(
        retry: retry(),
      );
    }

    return DefaultTabController(
      length: data.length,
      initialIndex: widget.initPos,
      child: Column(
        key: null,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              tabs: data.map((item) {
                return Tab(
                  text: item['name'],
                );
              }).toList(),
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              labelStyle: TextStyle(fontSize: 18),
              indicatorColor: Colors.white,
              indicatorPadding: EdgeInsets.all(3),
            ),
          ),
          Expanded(
              child: TabBarView(
                  children: data.map((f) {
            return _buildTabBarPage(f);
          }).toList())),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    request = widget.api;
    data = widget.data;
    if (request != null) {
      getData();
    } else if (data != null && data.length > 0) {
      isLoading = false;
      setState(() {});
    } else {
      isLoading = false;
      isError = true;
      errorInfo = '未传入请求或数据！';
      setState(() {});
    }
  }

  void getData() {
    request.then((result) {
      isLoading = false;
      isEmpty = result == null;
      data = result;
      setState(() {});
    }).catchError((error) {
      isLoading = false;
      isError = true;
      setError(error);
      setState(() {});
    });
  }

  retry() {
    if (request != null) {
      setState(() {
        isLoading = true;
      });
      getData();
    }
  }

  void setError(e) {
    if (e is Exception) {
      errorInfo = e.toString();
    } else if (e is String) {
      errorInfo = e;
    }
  }

  Widget _buildTabBarPage(item) {
    return RefreshableList(
      [Apis.chapterArticles(item['id'])],
      ['datas'],
      [''],
      _buildItem,
      initPageNo: 1,
      listenTypes: [Login, SwitchFavorite],
    );
  }

  _buildItem(item, index) {
    return ArticleItemView(item);
  }
}
