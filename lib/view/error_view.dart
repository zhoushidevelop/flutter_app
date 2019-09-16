import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String error;
  final Function retry;
  final String defaultErrorMsg = '默认错误说明';

  ErrorView({this.error, this.retry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: retry,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '加载失败 o(╥﹏╥)o',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              getRetryHint(),
              Text((error == null || error.isEmpty) ? defaultErrorMsg : error),
            ],
          ),
        ),
      ),
    );
  }

  getRetryHint() {
    if (retry != null) {
      return Text('点击重试');
    } else {
      return Container;
    }
  }
}
