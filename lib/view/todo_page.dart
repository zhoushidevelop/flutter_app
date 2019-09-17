import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/api.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/utils/hint_util.dart';
import 'package:flutter_app/utils/nav_util.dart';
import 'package:flutter_app/view/refreshable_list.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TodoPageState();
  }
}

class _TodoPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务清单'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              NavUtil.navTo(context, EditTodoPage());
            },
          ),
        ],
      ),
      body: RefreshableList(
        [Apis.todo],
        ['datas'],
        [''],
        _buildItem,
        listenTypes: [Todo, TodoDel],
      ),
    );
  }

  _buildItem(item, index) {
    return InkWell(
      onTap: () {
        NavUtil.navTo(context, EditTodoPage(item: item));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item['title'],
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Text(item['dateStr']),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    item['status'] == 0 ? '未完成' : '已完成',
                    style: TextStyle(
                      color: item['status'] == 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    item['content'],
                    style: TextStyle(fontSize: 16),
                  )),
                  Container(
                    height: 24,
                    width: 24,
                    child: IconButton(
                        icon: Icon(Icons.delete_forever),
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          HintUtil.alert(
                              context, '删除任务', '确定要删除任务【${item['title']}】吗？',
                              () {
                            Apis.todoDelete(item['id']).then((res) {
                              HintUtil.toast(context, '已删除');
                              eventBus.fire(TodoDel());
                            }).catchError((e) {
                              HintUtil.toast(context, e.toString());
                            }).whenComplete(() {
                              NavUtil.pop(context);
                            });
                          }, () {
                            NavUtil.pop(context);
                          });
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTodoPage extends StatefulWidget {
  final item;

  EditTodoPage({Key key, this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditTodoPageState();
  }
}

class _EditTodoPageState extends State<EditTodoPage> {
  final formKey = GlobalKey<FormState>();

  var _title, _content, _dateStr, _status;
  bool _isLoading = false;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  _submit() {
    var currentState = formKey.currentState;
    if (currentState.validate()) {
      currentState.save();
      setState(() {
        _isLoading = true;
      });
    }
    Future future = widget.item == null
        ? Apis.todoAdd(_title, _content, _dateStr)
        : Apis.todoUpdate(
            widget.item['id'], _title, _content, _dateStr, _status.toString());
    future.then((val) {
      HintUtil.toast(context, widget.item == null ? '新增成功' : '编辑成功');
      eventBus.fire(Todo());
      NavUtil.pop(context);
    }).catchError((e) {
      HintUtil.toast(context, e.toString());
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _status = widget.item == null ? 0 : widget.item['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? '新建任务' : '编辑任务'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Form(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      initialValue:
                          widget.item == null ? '' : widget.item['title'],
                      validator: (value) {
                        return value.isEmpty ? '标题不能为空' : null;
                      },
                      onSaved: (val) {
                        _title = val;
                      },
                      decoration: InputDecoration(
                        hintText: '请输入标题',
                        labelText: '标题',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: TextFormField(
                        initialValue:
                            widget.item == null ? '' : widget.item['content'],
                        validator: (value) {
                          return value.isEmpty ? '内容不能为空' : null;
                        },
                        onSaved: (val) {
                          _content = val;
                        },
                        decoration: InputDecoration(
                          hintText: '请输入内容',
                          labelText: '内容',
                        ),
                      ),
                    ),
                    DateTimeField(
                        format: dateFormat,
                        initialValue: widget.item == null
                            ? DateTime.now()
                            : DateTime.parse(widget.item['dateStr']),
                        decoration: InputDecoration(
                          hintText: '请选择完成时间',
                          labelText: '完成时间',
                        ),
                        onSaved: (v) {
                          _dateStr = dateFormat.format(v);
                        },
                        readOnly: true,
                        resetIcon: null,
                        onShowPicker: (context, date) {
                          return showDatePicker(
                              context: context,
                              initialDate: date ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2500));
                        }),
                    getSwitch(),
                    Container(
                      margin: EdgeInsets.all(30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 200,
                          height: 45,
                          child: RaisedButton(
                              textColor: Colors.white,
                              disabledTextColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                              disabledColor: Colors.grey,
                              child: Text(_isLoading ? '提交中...' : '提交'),
                              onPressed: _isLoading ? null : _submit),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              key: formKey,
            ),
          )
        ],
      ),
    );
  }

  getSwitch() {
    if (widget.item == null) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '是否已完成',
              style: TextStyle(fontSize: 13),
            ),
            Switch(
                value: _status == 1,
                onChanged: (val) {
                  setState(() {
                    _status = val ? 1 : 0;
                  });
                }),
          ],
        ),
      );
    }
  }
}
