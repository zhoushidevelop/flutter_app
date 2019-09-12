import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/config/tag.dart';
import 'package:flutter_app/utils/nav_util.dart';

import 'article_item_view.dart';
import 'home_banner.dart';
import 'refreshable_list.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshableList(
      [
        Apis.banner(),
        Apis.topArticles(),
        Apis.articles,
      ],
      [
        '',
        '',
        'datas',
      ],
      [
        Tags.banner,
        Tags.top,
        Tags.normal,
      ],
      (item, index) {
        if (item is List) {
          return HomeBanner(
            item,
            (item) {
              NavUtil.navToWeb(context, item['url'], item['title']);
            },
          );
        } else {
          switch (item['localTag']) {
            case Tags.top:
              item['isTop'] = true;
              return ArticleItemView(item);
              break;
            case Tags.normal:
              return ArticleItemView(item);
              break;
          }
        }
      },
      listenTypes: [Login, SwitchFavorite],
    );
  }
}
