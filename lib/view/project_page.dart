import 'package:flutter/widgets.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/view/article_tab_page.dart';

class ProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArticleTabPage(Apis.projectChapters(), null);
  }
}
