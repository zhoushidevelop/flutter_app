import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';

import 'article_tab_page.dart';

class WeChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArticleTabPage(Apis.wxChapters(), null);
  }
}

