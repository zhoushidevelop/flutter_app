import 'package:flutter/material.dart';
import 'package:flutter_app/view/article_tab_page.dart';

class KnowledgePage extends StatelessWidget {
  String title;
  List children;
  int initIndex;

  KnowledgePage(this.title, this.children, {this.initIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ArticleTabPage(
        null,
        children,
        initPos: initIndex,
      ),
    );
  }
}
