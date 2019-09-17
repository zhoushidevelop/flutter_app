import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/view/article_item_view.dart';
import 'package:flutter_app/view/refreshable_list.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
      ),
      body: RefreshableList(
        [Apis.favorite],
        ['datas'],
        [''],
        _buildItem,
        listenTypes: [SwitchFavorite],
      ),
    );
  }

  _buildItem(item, index) {
    item['collect'] = true;
    return ArticleItemView(
      item,
      isFromFavorite: true,
    );
  }
}
