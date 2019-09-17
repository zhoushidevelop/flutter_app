import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/colors.dart';
import 'package:flutter_app/config/tag.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/nav_util.dart';
import 'package:flutter_app/view/article_item_view.dart';
import 'package:flutter_app/view/refreshable_list.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            search(val);
          },
          decoration: InputDecoration(
            hintText: '请输入搜索内容...',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                search(_controller.text);
              })
        ],
      ),
      body: RefreshableList(
        [Apis.hotKeys()],
        [''],
        [Tags.hotKey],
        _buildItem,
        showFloating: false,
      ),
    );
  }

  _buildItem(item, index) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '大家都在搜',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            child: Wrap(
              children: item.map<Widget>((val) {
                var color = tagColors[Random().nextInt(tagColors.length - 1)];
                return InkWell(
                  onTap: () {
                    search(val['name']);
                  },
                  child: Text(
                    val['name'],
                    style: TextStyle(fontSize: 16, color: color),
                  ),
                );
              }).toList(),
              spacing: 20,
              runSpacing: 20,
            ),
          ),
        ],
      ),
    );
  }

  void search(String val) {
    if (val.isNotEmpty) {
      NavUtil.navTo(context, SearchResultPage(val));
    } else {
      HintUtil.toast(context, '搜索内容不能为空...');
    }
  }
}

class SearchResultPage extends StatelessWidget {
  final String keyWord;

  SearchResultPage(this.keyWord);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(keyWord),
      ),
      body:
          RefreshableList([Apis.search(keyWord)], ['datas'], [''], _buildItem),
    );
  }

  _buildItem(item, index) {
    return ArticleItemView(item);
  }
}
