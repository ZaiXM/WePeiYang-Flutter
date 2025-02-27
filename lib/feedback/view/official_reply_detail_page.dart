import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/official_comment_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../commons/themes/template/wpy_theme_data.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import 'components/widget/pop_menu_shape.dart';

class OfficialReplyDetailPage extends StatefulWidget {
  final List<Floor> floor;

  OfficialReplyDetailPage(this.floor);

  @override
  _OfficialReplyDetailPageState createState() =>
      _OfficialReplyDetailPageState();
}

class _OfficialReplyDetailPageState extends State<OfficialReplyDetailPage>
    with SingleTickerProviderStateMixin {
  int currentPage = 1;
  List<Floor>? floors;
  Post? post;
  int? rating;
  double _previousOffset = 0;
  final launchKey = GlobalKey<CommentInputFieldState>();
  final imageSelectionKey = GlobalKey<ImageSelectAndViewState>();

  var _refreshController = RefreshController(initialRefresh: false);

  Future<bool> _initPost(int id) async {
    bool success = false;
    await FeedbackService.getPostById(
      id: id,
      onResult: (Post result) {
        success = true;
        post = result;
        rating = post?.rating;
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        success = false;
        return;
      },
    );
    return success;
  }

  _onRefresh() {
    currentPage = 1;
    _getComment(
        onSuccess: (comments) {
          setState(() {
            floors = comments;
          });
          _refreshController.refreshCompleted();
        },
        onFail: () {
          _refreshController.refreshFailed();
        },
        page: 0);
  }

  _onLoading() {
    currentPage++;
    _getComment(
        onSuccess: (comments) {
          if (comments.length == 0) {
            _refreshController.loadNoData();
            currentPage--;
          } else {
            floors?.addAll(comments);
            _refreshController.loadComplete();
          }
        },
        onFail: () {
          _refreshController.loadFailed();
        },
        page: currentPage);
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (context.read<NewFloorProvider>().inputFieldEnabled == true &&
        scrollInfo.metrics.pixels - _previousOffset >= 20) {
      context.read<NewFloorProvider>().clearAndClose();
      _previousOffset = scrollInfo.metrics.pixels;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    context.read<NewFloorProvider>().inputFieldEnabled = false;
    context.read<NewFloorProvider>().replyTo = widget.floor[0].postId;
    floors = widget.floor;
    _initPost(widget.floor[0].postId);
    _getComment(
        onSuccess: (comments) {
          setState(() {
            floors = comments;
          });
        },
        onFail: () {
          ToastProvider.error('获取回复失败');
        },
        page: 0);
  }

  Future<bool> _getComment(
      {required Function(List<Floor>) onSuccess,
      required Function onFail,
      required int page}) async {
    bool success = false;
    await FeedbackService.getOfficialComment(
      id: floors?[0].postId,
      onSuccess: (floor) {
        floors = floor;
        _refreshController.refreshCompleted();
        setState(() {});
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        _refreshController.refreshFailed();
        onFail.call();
      },
    );
    return success;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Widget checkButton = WButton(
      onPressed: () {
        if (CommonPreferences.lakeUid.value.toString() != post?.uid.toString())
          ToastProvider.error("只有帖主能回复哦！");
        else
          // 这里是校务楼层的详情页，所以这里一定是校务楼层的回复
          launchKey.currentState?.send(true);
        setState(() {
          _refreshController.requestRefresh();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0, bottom: 12.0),
        child: SvgPicture.asset('assets/svg_pics/lake_butt_icons/send.svg',
            width: 20),
      ),
    );
    Widget mainList1;
    if (post == null) {
      mainList1 = Loading();
    } else {
      mainList1 = ListView.builder(
        itemCount: floors?.length,
        itemBuilder: (context, index) {
          var data = floors![index];
          return Column(
            children: [
              if (data.sender == 1)
                OfficialReplyCard.reply(
                  tag: post!.department!.name,
                  comment: data,
                  placeAppeared: index,
                  ratings: rating!,
                  ancestorId: widget.floor[0].uid,
                ),
              if (data.sender == 0)
                OfficialReplyCard.reply(
                  comment: data,
                  ratings: rating!,
                  placeAppeared: index,
                  ancestorId: widget.floor[0].postId,
                ),
              Container(
                  width: WePeiYangApp.screenWidth - 60,
                  height: 1,
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.iconAnimationStartColor))
            ],
          );
        },
      );
    }

    Widget mainList = Expanded(
      child: NotificationListener<ScrollNotification>(
        child: SmartRefresher(
          physics: BouncingScrollPhysics(),
          controller: _refreshController,
          header: ClassicHeader(),
          footer: ClassicFooter(),
          enablePullDown: true,
          onRefresh: _onRefresh,
          enablePullUp: true,
          onLoading: _onLoading,
          child: mainList1,
        ),
        onNotification: (ScrollNotification scrollInfo) =>
            _onScrollNotification(scrollInfo),
      ),
    );

    var inputField =
        CommentInputField(postId: floors![0].postId, key: launchKey);

    body = Column(
      children: [
        mainList,
        Consumer<NewFloorProvider>(builder: (BuildContext context, value, _) {
          return AnimatedSize(
            clipBehavior: Clip.antiAlias,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutSine,
            child: Container(
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.iconAnimationStartColor),
                        offset: Offset(0, -1),
                        blurRadius: 2,
                        spreadRadius: 3),
                  ],
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.secondaryBackgroundColor)),
              child: Column(
                children: [
                  Offstage(
                      offstage: !value.inputFieldEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          inputField,
                          SizedBox(height: 4),
                          Row(
                            children: [
                              SizedBox(width: 4),
                              Spacer(),
                              checkButton,
                              SizedBox(width: 16),
                            ],
                          ),
                          SizedBox(height: 10)
                        ],
                      )),
                  Offstage(
                    offstage: value.inputFieldEnabled,
                    child: WButton(
                      onPressed: () {
                        Provider.of<NewFloorProvider>(context, listen: false)
                            .inputFieldOpenAndReplyTo(widget.floor[0].postId);
                        FocusScope.of(context).requestFocus(
                            Provider.of<NewFloorProvider>(context,
                                    listen: false)
                                .focusNode);
                      },
                      child: Container(
                          height: 22,
                          margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('友善回复，真诚沟通',
                                style: TextUtil.base.NotoSansSC.w500
                                    .secondaryInfo(context)
                                    .sp(12)),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryBackgroundColor),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
      ],
    );

    var menuButton = IconButton(
      icon:
          SvgPicture.asset('assets/svg_pics/lake_butt_icons/more_vertical.svg'),
      splashRadius: 20,
      onPressed: () {
        showMenu(
          context: context,

          /// 左侧间隔1000是为了离左面尽可能远，从而使popupMenu贴近右侧屏幕
          /// MediaQuery...top + kToolbarHeight是状态栏 + AppBar的高度
          position: RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
          shape: RacTangle(),
          items: <PopupMenuItem<String>>[
            PopupMenuItem<String>(
              value: '举报',
              child: Center(
                child: Text('举报',
                    style: TextUtil.base.regular
                        .customColor(
                            WpyTheme.of(context).get(WpyColorKey.cursorColor))
                        .sp(13)),
              ),
            ),
          ],
        ).then((value) {
          if (value == "举报") {
            Navigator.pushNamed(context, FeedbackRouter.report,
                arguments: ReportPageArgs(widget.floor[0].id, true));
          }
        });
      },
    );

    var appBar = AppBar(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: WpyTheme.of(context).get(WpyColorKey.defaultActionColor)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [menuButton],
      title: WButton(
        onPressed: () => _refreshController.requestRefresh(),
        child: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Center(
            child: Text(
              '官方回复',
              style: TextUtil.base.NotoSansSC.label(context).w500.sp(18),
            ),
          ),
        ),
      ),
      elevation: 0,
    );

    return PopScope(
      onPopInvoked: (didPop) async {
        context.read<NewFloorProvider>().clearAndClose();
        if (!didPop) Navigator.pop(context);
      },
      canPop: true,
      // onWillPop: () async {
      //   context.read<NewFloorProvider>().clearAndClose();
      //   Navigator.pop(context);
      //   return true;
      // },
      child: Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        appBar: appBar,
        body: body,
      ),
    );
  }
}
