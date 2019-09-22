import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/colors.dart';
import 'package:flutter_app/config/status.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/nav_util.dart';
import 'package:flutter_app/view/empty_view.dart';
import 'package:flutter_app/view/error_view.dart';
import 'package:flutter_app/view/loading_view.dart';
import 'package:flutter_app/view/refreshable_list.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationPageState();
  }
}

class _NavigationPageState extends State<NavigationPage> {
  List<dynamic> data;
  int _selectIndex = 0;
  Status _status = Status.Loading;
  String _errorMsg;
  RefreshableList rightView;
  List rightItemHeights = [];

  @override
  void initState() {
    super.initState();
    getData();
  }


  void getData() {
    Apis.navigation().then((result) {
      data = result;
      _status = data.length == 0 ? Status.Empty : Status.Success;
      setState(() {

      });
    }).catchError((error) {
      setState(() {
        _status = Status.Error;
        setError(error);
        setState(() {});
      });
    }).whenComplete(() {});
  }

  retry() {
    setState(() {
      _status = Status.Loading;
    });
    getData();
  }

  void setError(error) {
    HintUtil.log('NavigationPage 发生错误：$error');
    if (error is Exception) {
      _errorMsg = error.toString();
    } else if (error is String) {
      _errorMsg = error;
    }
    _errorMsg = error.toString();
  }


  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case Status.Loading:
        return LoadingView();
        break;
      case Status.Error:
        return ErrorView(retry: retry(), error: _errorMsg,);
        break;
      case Status.Empty:
        return EmptyView(retry: retry(),);
        break;
      case Status.Success:
        if (rightView == null) {
          rightView = RefreshableList(
            [data], [''], [''], _buildRightItem, divider: _buildRightDivider,
            refreshable: false,
            showFloating: false,);
        }
        return Row(
          children: <Widget>[
            Container(
              width: 100,
              child: RefreshableList([data], [''], [''], _buildLeftItem),
            ),
            Expanded(child: rightView),
          ],
        );
        break;
    }
  }

  _buildRightItem(item, index) {
    /// 粗略估算item高度
    var factor = item['articles'].length > 8 ? 13 : 30;
    rightItemHeights.add(20 + item['articles'].length * factor);
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(item['name'], style: TextStyle(
              fontSize: 18,
              color: Colors.black
          ),),
          Container(
            decoration: BoxDecoration(
              color: Color(0x6FECEFF6),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            child: Wrap(
              children: item['articles'].map<Widget>((value) {
                var color = tagColors[Random().nextInt(tagColors.length - 1)];
                return InkWell(
                  onTap: () {
                    NavUtil.navToWeb(context, value['link'], value['title']);
                  },
                  child: Text(value['title'],
                    style: TextStyle(fontSize: 16, color: color),),
                );
              }).toList(),
              spacing: 15,
              runSpacing: 15,
            ),
          )
        ],
      ),
    );
  }

  _buildRightDivider(index) {
    return Container(height: 10,);
  }

  _buildLeftItem(item, index) {
    return InkWell(
      onTap: () {
        _selectIndex = index;
        rightView.jumpTo(getJumpHeight(index));
        setState(() {});
      },
      child: Padding(padding: EdgeInsets.all(15),
        child: Center(child: Text(item['name'], style: TextStyle(
            color: index == _selectIndex ? Colors.blue : Colors.black54),),),),
    );
  }

  double getJumpHeight(index) {
    double result = 0.0;
    for (var height in rightItemHeights) {
      result += height;
    }
    return result;
  }
}
