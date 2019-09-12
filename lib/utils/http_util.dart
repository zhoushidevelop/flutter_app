import 'dart:convert' as convert;

import 'package:flutter_app/utils/account_util.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:http/http.dart' as http;

const BASE_URL = "https://www.wanandroid.com";

String getRequestUrl(path) {
  return '$BASE_URL/$path';
}

getHeader() async {
  Map<String, String> headers = Map();
  String cookie = await AccountUtil.getCookie();
  headers['Cookie'] = cookie;
  return headers;
}

class HttpUtil {
  static Future get(String path) async {
    var url = getRequestUrl(path);
    var headers = await getHeader();
    HintUtil.log('get请求：$url\n请求头：$headers');
    return proceedResponse(url, http.get(url, headers: headers));
  }

  static Future post(String path, {body}) async {
    var url = getRequestUrl(path);
    var headers = await getHeader();
    HintUtil.log('post-请求：$url\n请求头：$headers\n参数：$body');
    return proceedResponse(url, http.post(url, headers: headers, body: body));
  }
}

Future proceedResponse(String url, Future<http.Response> future) {
  future.then((http.Response response) {
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (url.contains('user/login') &&
          response.headers.containsKey('set-cookie')) {
        var cookie = response.headers['set-cookie'];
        HintUtil.log('set-cookie: $cookie');
        saveCookie(cookie);
        return Future.value(jsonResponse);
      } else {
        var msg = '请求失败 ${response.statusCode}';
        HintUtil.log(msg);
        return Future.error(msg);
      }
    }
  }).then((jsonResponse) {
    HintUtil.log('$url json返回如下：\n$jsonResponse');
    if (jsonResponse != null) {
      if (jsonResponse['errorCode'] == 0) {
        return jsonResponse['data'];
      } else {
        var msg = "业务失败：${jsonResponse['errorMsg']}";
        HintUtil.log(msg);
        return Future.error(msg);
      }
    }
  });
}

void saveCookie(String cookie) async {
  await AccountUtil.saveCookie(cookie);
}
