import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_service.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../commons/themes/wpy_theme.dart';

class NewLostAndFoundPostProvider {
  String title = "";
  String content = "";
  String date = "";
  String location = "";
  String phone = "";

  List<File> images = [];

  bool get check =>
      title.isNotEmpty &&
      content.isNotEmpty &&
      date.isNotEmpty &&
      location.isNotEmpty &&
      phone.isNotEmpty;

  void clear() {
    title = "";
    content = "";
    date = "";
    location = "";
    phone = "";
  }
}

class LostAndFoundPostPage extends StatefulWidget {
  @override
  State<LostAndFoundPostPage> createState() => _LostAndFoundPostPageState();
}

class _LostAndFoundPostPageState extends State<LostAndFoundPostPage> {
  //0->失物 1->招领
  final typeNotifier = ValueNotifier(0);
  final categoryNotifier = ValueNotifier('选择分类');
  static const selectTypeText = ['失物', '招领'];
  static const texts = ['招领', '失物'];

  bool tapAble = true;
  bool _showSelectDialog = false;

  void changeType() {
    if (typeNotifier.value == 1) {
      typeNotifier.value = 0;
    } else {
      typeNotifier.value = 1;
    }
  }

  _showLoading() {
    showDialog(context: context, builder: (_) => Loading());
  }

  _submit() async {
    var dataModel = context.read<NewLostAndFoundPostProvider>();
    if (!dataModel.check) {
      ToastProvider.error("请检查内容是否填写完整！");
      return;
    }
    if (categoryNotifier.value == "选择分类") {
      ToastProvider.error("请选择分类！");
      return;
    }
    ToastProvider.running("创建中...");
    _showLoading();
    if (dataModel.images.isNotEmpty) {
      LostAndFoundService.postLostAndFoundPic(
          images: dataModel.images,
          onResult: (images) {
            dataModel.images.clear();
            if (dataModel.check) {
              LostAndFoundService.sendLostAndFoundPost(
                  author: CommonPreferences.lakeNickname.value,
                  type: selectTypeText[typeNotifier.value],
                  category: categoryNotifier.value,
                  title: dataModel.title,
                  text: dataModel.content,
                  yyyymmdd: dataModel.date,
                  yyyymmddhhmmss:
                      "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}",
                  location: dataModel.location,
                  phone: dataModel.phone,
                  images: images,
                  onSuccess: () {
                    ToastProvider.success('发布成功');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  onFailure: (e) {
                    dataModel.clear();
                    ToastProvider.error(e.error.toString());
                    Navigator.pop(context);
                  });
              dataModel.clear();
            }
          },
          onFailure: (e) {
            ToastProvider.error('发送图片失败或图片不合规\n${e.error.toString()}');
          });
    } else {
      LostAndFoundService.sendLostAndFoundPost(
        author: CommonPreferences.lakeNickname.value,
        type: selectTypeText[typeNotifier.value],
        category: categoryNotifier.value,
        title: dataModel.title,
        text: dataModel.content,
        yyyymmdd: dataModel.date,
        yyyymmddhhmmss:
            "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}",
        location: dataModel.location,
        phone: dataModel.phone,
        images: [],
        onSuccess: () {
          ToastProvider.success('发布成功');
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onFailure: (e) {
          dataModel.clear();
          ToastProvider.error(e.error.toString());
          Navigator.pop(context);
        },
      );
      dataModel.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            leading: IconButton(
                padding: EdgeInsets.zero,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(Icons.keyboard_arrow_left,
                    color:WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor), size: 36.r),
                onPressed: () {
                  var dataModel = context.read<NewLostAndFoundPostProvider>();
                  dataModel.clear();
                  Navigator.of(context).pop();
                }),
            title: Text("发布${selectTypeText[typeNotifier.value]}",
                style: TextUtil.base.NotoSansSC.w400.sp(18).label(context)),
            actions: [
              InkWell(
                  onTap: () async {
                    setState(() {
                      changeType();
                    });
                  },
                  child: Container(
                      width: 36.w,
                      height: 36.h,
                      child: Column(children: [
                        SizedBox(height: 11.h),
                        Image.asset("assets/images/post_swap.png"),
                        Text(
                          texts[typeNotifier.value],
                          style: TextUtil.base.NotoSansSC.w400.sp(10).blue89,
                        )
                      ]))),
              SizedBox(width: 10.w)
            ],
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Container(
            padding: EdgeInsets.all(16.r),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              LostAndFoundTitleInputField(),
              LostAndFoundContentInputField(),
              LostAndFoundImagesGridView(),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      SizedBox(height: 27.h),
                      SelectDateField(typeNotifier: typeNotifier),
                      SizedBox(height: 14.h),
                      InputLocationField(typeNotifier: typeNotifier),
                      SizedBox(height: 14.h),
                      InputPhoneField()
                    ],
                  )),
              Container(
                  height: 150.h,
                  alignment: Alignment.center,
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    selectCategoryDialog(context),
                    SelectCategoryButton(),
                    SizedBox(width: 8.w),
                    LostAndFoundPostButton()
                  ]))
            ])));
  }

  TextButton SelectCategoryButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            _showSelectDialog = true;
          });
        },
        child: Text("#  ${categoryNotifier.value}",
            style:
                TextUtil.base.NotoSansSC.w400.sp(14).primaryAction(context)));
  }

  Visibility selectCategoryDialog(BuildContext context) {
    return Visibility(
        visible: _showSelectDialog,
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 30.h, 0, 0),
            padding: EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
            height: 120.h,
            width: 86.w,
            decoration: BoxDecoration(
                color: WpyTheme.of(context)
                    .get(WpyColorKey.primaryBackgroundColor),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3.r),
                      blurRadius: 6.r,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.basicTextColor)
                          .withOpacity(0.25))
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildSelectCategoryOption("生活日用", context),
                buildSelectCategoryOption("数码产品", context),
                buildSelectCategoryOption("钱包卡证", context),
                buildSelectCategoryOption("其他", context)
              ],
            )));
  }

  Widget buildSelectCategoryOption(String option, BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            categoryNotifier.value = option;
            _showSelectDialog = false;
          });
        },
        child: Container(
            child: Text(option,
                style: TextUtil.base.NotoSansSC.w400.sp(12).primary(context))));
  }

  SizedBox LostAndFoundPostButton() {
    return SizedBox(
        width: 63,
        height: 32,
        child: ElevatedButton(
            style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(
                    WpyTheme.of(context).get(WpyColorKey.primaryActionColor)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)))),
            onPressed: () async {
              if (tapAble) {
                tapAble = false;
                await _submit();
                await Future.delayed(Duration(milliseconds: 3000));
                tapAble = true;
              }
            },
            child: Text(
              '发送',
              style: TextUtil.base.NotoSansSC.w400.sp(14).reverse(context),
            )));
  }
}

class LostAndFoundTitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<LostAndFoundTitleInputField> {
  late final ValueNotifier<String> titleCounter;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewLostAndFoundPostProvider>();
    _titleController = TextEditingController(text: dataModel.title);
    titleCounter = ValueNotifier('${dataModel.title.characters.length}/30')
      ..addListener(() {
        dataModel.title = _titleController.text;
      });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Expanded(
        child: TextField(
            buildCounter: null,
            controller: _titleController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            style: TextUtil.base.NotoSansSC.w700.sp(18).h(1.2).label(context),
            minLines: 1,
            maxLines: 10,
            decoration: InputDecoration.collapsed(
                hintStyle:
                    TextUtil.base.NotoSansSC.w700.sp(18).infoText(context),
                hintText: '添加标题'),
            onChanged: (text) {
              titleCounter.value = '${text.characters.length} / 30';
            },
            inputFormatters: [CustomizedLengthTextInputFormatter(30)],
            cursorColor: WpyTheme.of(context).get(WpyColorKey.cursorColor),
            cursorHeight: 20));

    Widget textCounter = ValueListenableBuilder(
        valueListenable: titleCounter,
        builder: (_, String value, __) {
          return Text(value,
              style: TextUtil.base.NotoSansSC.w400.sp(14).infoText(context));
        });

    return Container(
        padding: EdgeInsets.fromLTRB(0, 15.h, 0, 14.h),
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [inputField, SizedBox(width: 3.w), textCounter]),
          Container(
              margin: EdgeInsets.only(top: 16.h),
              color: WpyTheme.of(context).get(WpyColorKey.lightBorderColor),
              height: 1.h)
        ]));
  }
}

class LostAndFoundContentInputField extends StatefulWidget {
  @override
  _LostAndFoundContentInputFieldState createState() =>
      _LostAndFoundContentInputFieldState();
}

class _LostAndFoundContentInputFieldState
    extends State<LostAndFoundContentInputField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    var dataModel =
        Provider.of<NewLostAndFoundPostProvider>(context, listen: false);
    _contentController = TextEditingController(text: dataModel.content);
    contentCounter = ValueNotifier('${dataModel.content.characters.length}/300')
      ..addListener(() {
        dataModel.content = _contentController.text;
      });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
        controller: _contentController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 1,
        maxLines: 100,
        style: TextUtil.base.NotoSansSC.w400.sp(16).h(1.4).label(context),
        decoration: InputDecoration.collapsed(
            hintStyle: TextUtil.base.NotoSansSC.w400.sp(16).infoText(context),
            hintText: '请添加正文'),
        onChanged: (text) {
          contentCounter.value = '${text.characters.length}/300';
        },
        scrollPhysics: NeverScrollableScrollPhysics(),
        inputFormatters: [CustomizedLengthTextInputFormatter(300)],
        cursorColor: WpyTheme.of(context).get(WpyColorKey.profileBackgroundColor));

    Widget bottomTextCounter = ValueListenableBuilder(
        valueListenable: contentCounter,
        builder: (_, String value, __) {
          return Text(value,
              style: TextUtil.base.NotoSansSC.w500.sp(12).infoText(context));
        });

    return Container(
        constraints: BoxConstraints(
            minHeight: WePeiYangApp.screenHeight > 900
                ? WePeiYangApp.screenHeight - 800
                : 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          inputField,
          SizedBox(height: 30.h),
          bottomTextCounter,
          SizedBox(height: 27.h)
        ]));
  }
}

class LostAndFoundImagesGridView extends StatefulWidget {
  @override
  _LostAndFoundImagesGridViewState createState() =>
      _LostAndFoundImagesGridViewState();
}

class _LostAndFoundImagesGridViewState
    extends State<LostAndFoundImagesGridView> {
  static const maxImage = 3;

  loadAssets() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: maxImage -
              context.read<NewLostAndFoundPostProvider>().images.length,
          requestType: RequestType.image,
          themeColor:
              WpyTheme.of(context).get(WpyColorKey.primaryTextButtonColor)),
    );
    if (assets == null) return; // 取消选择图片的情况
    for (int i = 0; i < assets.length; i++) {
      File? file = await assets[i].file;
      if (file == null) {
        ToastProvider.error('选取图片异常，请重新尝试');
        return;
      }
      for (int j = 0; file!.lengthSync() > 2000 * 1024 && j < 10; j++) {
        file = await FlutterNativeImage.compressImage(file.path, quality: 80);
        if (j == 10) {
          ToastProvider.error('您的图片 ${i + 1} 实在太大了，请自行压缩到2MB内再试吧');
          return;
        }
      }
      Provider.of<NewLostAndFoundPostProvider>(context, listen: false)
          .images
          .add(file);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<String?> _showDialog() {
    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                titleTextStyle:
                    TextUtil.base.NotoSansSC.w500.sp(14).label(context),
                title: Text('是否要删除此图片'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop('cancel');
                      },
                      child: Text('取消')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop('ok');
                      },
                      child: Text('确定')),
                ]));
  }

  Widget imgBuilder(index, List<File> data, length, {onTap}) {
    return Stack(fit: StackFit.expand, children: [
      InkWell(
        onTap: () => Navigator.pushNamed(context, FeedbackRouter.localImageView,
            arguments: LocalImageViewPageArgs(data, [], length, index)),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(width: 1.w, color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(8.r))),
          child: ClipRRect(
            child: Image.file(
              data[index],
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
        ),
      ),
      Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
              onTap: onTap,
              child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r)),
                  ),
                  child: Icon(
                    Icons.close,
                    size: MediaQuery.of(context).size.width / 32,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.secondaryBackgroundColor),
                  ))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, //方便右边宽度留白哈哈
      childAspectRatio: 1,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
    );

    return Consumer<NewLostAndFoundPostProvider>(
        builder: (_, data, __) => GridView.builder(
              shrinkWrap: true,
              gridDelegate: gridDelegate,
              itemCount: maxImage == data.images.length
                  ? data.images.length
                  : data.images.length + 1,
              itemBuilder: (_, index) {
                if (index <= 2 && index == data.images.length) {
                  return _ImagePickerWidget(onTap: loadAssets);
                } else {
                  return imgBuilder(index, data.images, data.images.length,
                      onTap: () async {
                    var result = await _showDialog();
                    if (result == 'ok') {
                      data.images.removeAt(index);
                      setState(() {});
                    }
                  });
                }
              },
              physics: NeverScrollableScrollPhysics(),
            ));
  }
}

class _ImagePickerWidget extends StatelessWidget {
  const _ImagePickerWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Image.asset("assets/images/crop_original.png", fit: BoxFit.fill),
    );
  }
}

class SelectDateField extends StatefulWidget {
  final ValueNotifier<int> typeNotifier;

  SelectDateField({required this.typeNotifier});

  @override
  _SelectDateFieldState createState() => _SelectDateFieldState();
}

class _SelectDateFieldState extends State<SelectDateField> {
  static const yyyymmddtexts = ["请填写丢失日期", "请填写拾取日期"];
  DateTime? selectedDate;
  late String yyyymmdd = "";

  @override
  Widget build(BuildContext context) {
    Future<void> _selectDate(BuildContext context) async {
      var dataModel = context.read<NewLostAndFoundPostProvider>();
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2015),
          lastDate: DateTime.now());

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          yyyymmdd =
              "${picked.year}${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}";
          dataModel.date = yyyymmdd;
        });
      }
    }

    return Container(
        width: 195.w,
        height: 36.h,
        decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
            borderRadius: BorderRadius.circular(16.r)),
        child: InkWell(
            onTap: () => _selectDate(context),
            child: Container(
                width: 195.w,
                height: 36.h,
                decoration: BoxDecoration(
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.oldSwitchBarColor),
                    borderRadius: BorderRadius.circular(16.r)),
                child: Stack(children: [
                  Container(
                      width: 17.w,
                      height: 17.h,
                      margin: EdgeInsets.fromLTRB(20.w, 9.5.r, 0, 0),
                      child: selectedDate != null
                          ? Image.asset("assets/images/icon_clock_filled.png",
                              fit: BoxFit.fill)
                          : Image.asset("assets/images/icon_clock.png",
                              fit: BoxFit.fill)),
                  Container(
                      margin: EdgeInsets.fromLTRB(45.w, 10.h, 0, 0),
                      child: selectedDate != null
                          ? Text(
                              "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日",
                              style: TextUtil.base.NotoSansSC.w400
                                  .sp(14)
                                  .primaryAction(context))
                          : Text(yyyymmddtexts[widget.typeNotifier.value],
                              style:
                                  TextUtil.base.NotoSansSC.w400.sp(14).infoText(context)))
                ]))));
  }
}

class InputLocationField extends StatefulWidget {
  final ValueNotifier<int> typeNotifier;

  InputLocationField({required this.typeNotifier});

  @override
  _InputLocationFieldState createState() => _InputLocationFieldState();
}

class _InputLocationFieldState extends State<InputLocationField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _locationController;
  bool isFilled = false;
  bool isFocused = false;
  FocusNode focusNode = FocusNode();
  static const locationtexts = ['请填写丢失地点', '请填写拾取地点'];

  @override
  void initState() {
    super.initState();
    var dataModel = context.read<NewLostAndFoundPostProvider>();
    _locationController = TextEditingController(text: dataModel.location);
    contentCounter =
        ValueNotifier('${dataModel.location.characters.length}/1000')
          ..addListener(() {
            dataModel.location = _locationController.text;
          });
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
        focusNode: focusNode,
        controller: _locationController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 1,
        style: TextUtil.base.NotoSansSC.w400.sp(14).primaryAction(context),
        decoration: InputDecoration.collapsed(
            hintStyle: TextUtil.base.NotoSansSC.w400.sp(14).infoText(context),
            hintText:
                isFocused ? "" : locationtexts[widget.typeNotifier.value]),
        onChanged: (text) {
          contentCounter.value = '${text.characters.length}/26';
          if (contentCounter.value != '0/26') {
            isFilled = true;
          } else {
            isFilled = false;
          }
        },
        onTap: () {
          setState(() {
            isFocused = true;
          });
        },
        onEditingComplete: () {
          setState(() {
            isFocused = false;
          });
        },
        scrollPhysics: NeverScrollableScrollPhysics(),
        inputFormatters: [CustomizedLengthTextInputFormatter(26)],
        cursorColor: WpyTheme.of(context).get(WpyColorKey.profileBackgroundColor));

    return Container(
        width: 195.w,
        height: 36.h,
        decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
            borderRadius: BorderRadius.circular(16)),
        child: Stack(children: [
          Container(
              width: 17.w,
              height: 17.h,
              margin: EdgeInsets.fromLTRB(20.w, 9.5.h, 0, 0),
              child: !(isFilled || isFocused)
                  ? Image.asset("assets/images/icon_location.png")
                  : Image.asset("assets/images/icon_location_fill.png")),
          Container(
              margin: EdgeInsets.fromLTRB(45.w, 10.h, 0, 0), child: inputField)
        ]));
  }
}

class InputPhoneField extends StatefulWidget {
  @override
  _InputPhoneFieldState createState() => _InputPhoneFieldState();
}

class _InputPhoneFieldState extends State<InputPhoneField> {
  late final ValueNotifier<String> contentCounter;
  late final TextEditingController _phoneController;
  bool isFilled = false;
  bool isFocused = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    var dataModel =
        Provider.of<NewLostAndFoundPostProvider>(context, listen: false);
    1234;
    _phoneController = TextEditingController(text: dataModel.phone);
    contentCounter = ValueNotifier('${dataModel.phone.characters.length}/11')
      ..addListener(() {
        dataModel.phone = _phoneController.text;
      });
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
        focusNode: focusNode,
        controller: _phoneController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 1,
        style: TextUtil.base.NotoSansSC.w400.sp(14).primaryAction(context),
        decoration: InputDecoration.collapsed(
            hintStyle: TextUtil.base.NotoSansSC.w400.sp(14).infoText(context),
            hintText: isFocused ? "" : '请填写联系方式'),
        onChanged: (text) {
          contentCounter.value = '${text.characters.length}/11';
          if (contentCounter.value != '0/11') {
            isFilled = true;
          } else {
            isFilled = false;
          }
        },
        onTap: () {
          setState(() {
            isFocused = true;
          });
        },
        onEditingComplete: () {
          setState(() {
            isFocused = false;
          });
        },
        scrollPhysics: NeverScrollableScrollPhysics(),
        inputFormatters: [CustomizedLengthTextInputFormatter(11)],
        cursorColor: WpyTheme.of(context).get(WpyColorKey.profileBackgroundColor));

    return Container(
        width: 195.w,
        height: 36.h,
        decoration: BoxDecoration(
            color: WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
            borderRadius: BorderRadius.circular(16.r)),
        child: Stack(children: [
          Container(
              width: 17.w,
              height: 17.h,
              margin: EdgeInsets.fromLTRB(20.w, 9.5.h, 0, 0),
              child: !(isFilled || isFocused)
                  ? Image.asset("assets/images/icon_smile_chat.png")
                  : Image.asset("assets/images/icon_smile_chat_fill.png")),
          Container(
              margin: EdgeInsets.fromLTRB(45.w, 10.h, 0, 0), child: inputField)
        ]));
  }
}
