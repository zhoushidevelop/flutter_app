import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/config/event.dart';
import 'package:flutter_app/config/status.dart';
import 'package:flutter_app/config/tag.dart';
import 'package:flutter_app/utils/hint_util.dart';

import 'empty_view.dart';
import 'end_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

// ignore: must_be_immutable
class RefreshableList extends StatefulWidget {
  /// 支持传入多个网络请求 [Future]
  /// 如果最后是分页接口，请传入 [Function]，因为页码在本控件内部维护
  /// 也可以直接传入数据列表
  final List<dynamic> _requests;

  /// 每个接口数据中的列表的 key，根据 key 获取每个接口返回的列表
  final List<String> dataKeys;

  /// 每个接口数据中的tag，方便调用方区分，以实现不同业务
  final List<dynamic> tags;

  /// item 的构建方法，业务方根据 item 中的 [localTag] 判断不同 item
  final Function _buildItem;

  /// 分页接口的初始页码
  final int initPageNo;

  /// 用于判断分页接口是否还有数据的 key
  final pageCountKey;

  /// 是否可以下拉刷新
  final refreshable;

  /// 分隔线
  final Function divider;

  /// 是否显示 FloatingActionButton
  final bool showFloating;

  final List<Type> listenTypes;

  RefreshableList(
    this._requests,
    this.dataKeys,
    this.tags,
    this._buildItem, {
    this.initPageNo = 0,
    this.pageCountKey = 'pageCount',
    this.refreshable = true,
    this.divider,
    this.showFloating = true,
    this.listenTypes,
  });

  RefreshableListState _state = RefreshableListState();

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  void jumpTo(double v) {
    _state.jumpTo(v);
  }

  animateTo(double offset, Duration duration, Curve curve) {
    _state.animateTo(offset, duration, curve);
  }
}

class RefreshableListState extends State<RefreshableList>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _dataList = List();
  int _pageNo;
  Status _status = Status.Loading;
  MoreStatus _moreStatus = MoreStatus.Init;
  String _errorMsg;
  ScrollController _scrollController = ScrollController();

  ///分页接口下标，默认为最后一个接口
  var pageNoUserIndex;
  bool isMoreEnable = true;
  bool scrollUp = false;
  double lastPixels = 0;
  StreamSubscription streamSubscription;

  Function retry;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }
  }

  animateTo(double offset, Duration duration, Curve curve) {
    _scrollController.animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void initState() {
    super.initState();
    initEventListener();
    setScrollListentr();
    setFloating();
    initData();
  }

  void initData() {
    ///如果请求类别里面传进来得就是个集合，那就直接拿去用
    if (widget._requests[0] is List) {
      _dataList = widget._requests[0];
      _status = _dataList.length > 0 ? Status.Success : Status.Empty;
    }

    ///否则就要进行网络请求
    else {
      getData(isLoadingMore: false);
    }
  }

  void setFloating() {
    if (widget.showFloating) {
      _scrollController.addListener(() {
        bool scrollUpNow = _scrollController.position.pixels < lastPixels;
        lastPixels = _scrollController.position.pixels;
        if (scrollUpNow != scrollUp) {
          setState(() {
            scrollUp = scrollUpNow;
          });
        }
      });
    }
  }

  void setScrollListentr() {
    pageNoUserIndex = widget._requests.length - 1;

    ///判断是否最后一个请求是方法
    isMoreEnable = widget._requests[pageNoUserIndex] is Function;
    if (isMoreEnable) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          ///触发上拉加载更多
          if (_moreStatus == MoreStatus.Init ||
              _moreStatus == MoreStatus.Error) {
            ///当前状态ok就触发加载更多事件
            loadMore();
          }
        }
      });
    }
  }

  ///监听eventbus事件
  void initEventListener() {
    if (widget.listenTypes != null && widget.listenTypes.length > 0) {
      streamSubscription = eventBus.on().listen((event) {
        for (int i = 0; i < widget.listenTypes.length; i++) {
          /// type.toString() 示例：TodoDelete
          /// event.toString() 示例：Instance of 'Todo'
          var type = widget.listenTypes.elementAt(i);
          int index = event.toString().indexOf("'");
          int lastIndex = event.toString().lastIndexOf("'");
          String eventType = event.toString().substring(index + 1, lastIndex);
          if (eventType.compareTo(type.toString()) == 0) {
            getData();
            break;
          }
        }
      });
    }
  }

  /*
  *
  * 接受到eventbus发送事件，刷新数据
  *
  */
  Future getData({bool isLoadingMore = false}) async {
    if (!isLoadingMore) {
      ///下拉刷新
      ///获取控件设置的初始化分页接口的第一条页码参数
      _pageNo = widget.initPageNo;
      Future.wait(getAllFutures()).then((result) {
        setData(

            ///如果能加载更多获取返回的分页数据中的页面字段值,不能为0
            isMoreEnable ? result[pageNoUserIndex][widget.pageCountKey] : 0,
            setResultTags(result),
            false);
      }).catchError((error) {
        setState(() {
          _status = Status.Error;
          setError(error);
        });
      });
    } else {
      widget._requests[pageNoUserIndex](_pageNo).then((result) {
        setData(result[widget.pageCountKey], setMoreResultTag(result), true);
      }).catchError((e) {
        setState(() {
          _moreStatus = MoreStatus.Error;
          setError(e);
        });
      });
    }
  }

  /*
  *刷新数据
  */
  void setData(pageCount, result, isloadMore) {
    setState(() {
      var pageNow = widget.initPageNo == 0 ? _pageNo + 1 : _pageNo;
      _moreStatus = pageNow >= pageCount ? MoreStatus.End : MoreStatus.Init;
      _pageNo++;
      if (isloadMore) {
        _dataList.addAll(result);
      } else {
        _dataList = result;
      }
      if (_dataList.length == 0) {
        _status = Status.Empty;
      } else {
        _status = Status.Success;
      }
    });
  }

  /*
  * 刷新获取全部数据
  */
  Iterable<Future> getAllFutures() {
    var _futures = List<Future<dynamic>>();
    for (int i = 0; i < widget._requests.length; i++) {
      var request;
      if (pageNoUserIndex == i) {
        request = widget._requests[i] is Function
            ? widget._requests[i](_pageNo)
            : widget._requests[i];
      } else {
        request = widget._requests[i];
      }
      _futures.add(request);
    }
    return _futures;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Offstage(
          ///这个值是控制child是否显示得变量  true == gone , false = visable
          offstage: _status != Status.Loading,
          child: LoadingView(),
        ),
        Offstage(
          offstage: _status != Status.Error,
          child: ErrorView(_errorMsg, retry),
        ),
        Offstage(
          offstage: _status != Status.Empty,
          child: EmptyView(retry),
        ),
        Offstage(
          offstage: _status != Status.Success,
          child: getContentView(),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  /*
  *给每个返回的future数据设置一个tag标记 
  */
  setResultTags(List result) {
    var r = List();
    for (int i = 0; i < result.length; i++) {
      var dataKey = widget.dataKeys[i];

      ///通过自定义的data的key来获取返回的数据里面的真实data
      var subList = dataKey.isEmpty ? result[i] : result[i][dataKey];
      var tag = widget.tags[i];

      if (tag == Tags.banner || tag == Tags.hotKey) {
        r.add(subList);
        continue;
      }
      for (var value in subList) {
        value['localTag'] = tag;
        r.add(value);
      }
    }
    return r;
  }

  void loadMore() {
    setState(() {
      _moreStatus = MoreStatus.Loading;
    });
    getData(isLoadingMore: true);
  }

  void setError(error) {
    HintUtil.log('RefreshableList:发生错误$error');
    if (error is Exception) {
      _errorMsg = error.toString();
    } else if (error is String) {
      _errorMsg = error;
    } else {
      _errorMsg = error.toString();
    }
  }

  setMoreResultTag(result) {
    var r = List();
    var dataKey = widget.dataKeys[pageNoUserIndex];
    var list = dataKey.isEmpty ? result : result[dataKey];
    for (var value in list) {
      value['localTag'] = widget.tags[pageNoUserIndex];
      r.add(value);
    }
    return r;
  }

  getContentView() {
    return Scaffold(
      body: getBodyView(),
      floatingActionButton: getFloatingActionButton(),
    );
  }

  getBodyView() {
    if (widget.refreshable) {
      return RefreshIndicator(child: getList(), onRefresh: getData);
    } else {
      return getList();
    }
  }

  getList() {
    return ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (isMoreEnable && index == _dataList.length) {
            switch (_moreStatus) {
              case MoreStatus.Error:
                return ErrorView(_errorMsg, retry);
                break;
              case MoreStatus.Init:
                return Container();
                break;
              case MoreStatus.End:
                return EndView();
                break;
              case MoreStatus.Loading:
                return LoadingView();
                break;
            }
          }
          return widget._buildItem(_dataList.elementAt(index), index);
        },
        separatorBuilder: (BuildContext context, int index) {
          if (widget.divider != null) {
            return widget.divider(index);
          } else {
            return Divider(
              height: 0,
            );
          }
        },
        itemCount: _dataList.length + (isMoreEnable ? 1 : 0));
  }

  getFloatingActionButton() {
    if (widget.showFloating && scrollUp) {
      return FloatingActionButton(
        onPressed: () {
          jumpTo(10);
          jumpTo(0);
          setState(() {
            scrollUp = false;
          });
        },
        tooltip: '回到顶部',
        child: Icon(Icons.arrow_upward),
      );
    } else {
      return null;
    }
  }

  void jumpTo(double i) {
    _scrollController.jumpTo(i);
  }
}
