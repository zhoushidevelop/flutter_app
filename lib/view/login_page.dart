import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/utils/account_util.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/nav_util.dart';

import 'regist_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State {
  final formKey = GlobalKey<FormState>();
  var _userName, _password;
  bool _isLoading = false;

  _login() {
    final formState = formKey.currentState;
    if (formState.validate()) {
      formState.save();
      setState(() {
        _isLoading = true;
      });
      Apis.login(_userName, _password).then((result) {
        loginSuccess(result);
      }).catchError((e) {
        HintUtil.toast(context, e.toString());
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Form(
                key: formKey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        validator: (value) {
                          return value.isEmpty ? '用户名不能为空...' : null;
                        },
                        onSaved: (value) {
                          _userName = value;
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: '请输入用户名',
                          labelText: '用户名',
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          validator: (value) {
                            return value.isEmpty ? '密码不能为空...' : null;
                          },
                          onSaved: (value) {
                            _password = value;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.vpn_key),
                            hintText: '请输入密码',
                            labelText: '密码',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            width: 200,
                            height: 45,
                            child: RaisedButton(
                              child: Text(
                                _isLoading ? '登录中...' : '登录',
                              ),
                              onPressed: _isLoading ? null : _login,
                              textColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                              disabledColor: Colors.grey,
                              disabledTextColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          NavUtil.navTo(context, RegisterPage());
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(
                            '还没有账号？点击去注册',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void loginSuccess(result) async {
    await AccountUtil.saveUserName(result['nickname']);
    HintUtil.toast(context, '登录成功');
    eventBus.fire(Login());
    NavUtil.pop(context);
  }
}

