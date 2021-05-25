import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pudding/src/bean/pudding_elevation.dart';
import 'package:flutter_pudding/src/utils/message_exception.dart';
import 'package:flutter_pudding/src/widget/pudding_layout_ripple.dart';

///默认的一种消息提示,从屏幕顶部下滑出来,点击消息内容,自动关闭消息
class PuddingDefault {
  ///用于插入内容到屏幕上
  static OverlayEntry? _overlayEntry;

  ///长消息
  static const Duration LENGTH_LONG = const Duration(milliseconds: 3500);

  ///短消息
  static const Duration LENGTH_SHORT = const Duration(milliseconds: 2000);

  ///隐藏view的透明度动画控制器，时长
  static const Duration _HIDE_TOAST_DURATION =
      const Duration(milliseconds: 500);

  //平移动画控制器，时长
  static const Duration _ALIGN_SHOW_TOAST_DURATION =
      const Duration(milliseconds: 560);

  ///开启一个新toast的当前时间，用于对比是否已经展示了足够时间
  static DateTime? _startedTime;

  ///消息内容
  static String? _content;

  ///消息显示时长
  static Duration? _duration;

  ///消息内容背景色
  static Color? _backgroundColor;

  ///文本的Style
  static TextStyle? _textStyle;

  ///阴影相关主题配置
  static PuddingElevation? _puddingElevation;

  ///文本最大行数
  static int? _maxLines;

  ///供外部传入一个widget
  static Widget? _customView;

  ///Translate动画[控制器]
  static AnimationController? _offsetAnimationController;

  ///曲线动画
  static CurvedAnimation? _offsetCurvedAnimation;

  ///平移动画
  static Animation<double>? _offsetAnim;

  static OverlayState? _overlayState;

  PuddingDefault._();

  ///初始化动画
  static OverlayState _initAnimation(BuildContext context,
      OverlayState? overlayState, double statusBarHeight, Size screenSize) {
    if (null == overlayState) {
      throw NullPointException("OverLayState == null");
    }
    //Translate动画[控制器]
    if (null == _offsetAnimationController) {
      _offsetAnimationController = AnimationController(
        vsync: overlayState,
        duration: _ALIGN_SHOW_TOAST_DURATION,
      );
    }
    //曲线动画
    if (null == _offsetCurvedAnimation) {
      _offsetCurvedAnimation = CurvedAnimation(
          parent: _offsetAnimationController!, curve: _CustomCurve());
    }
    //平移动画
    if (null == _offsetAnim) {
      //end不设置为0，因为此时用了回弹的曲线动画，设置为0会出现顶部空白的问题
      double beginValue = -screenSize.height * 0.15 - statusBarHeight;
      if (MediaQuery.of(context).orientation != Orientation.portrait) {
        //处理横屏默认动画开始的位置
        beginValue = -screenSize.width * 0.15 - statusBarHeight;
      }
      _offsetAnim = Tween(begin: beginValue, end: -statusBarHeight)
          .animate(_offsetCurvedAnimation!);
    }
    return overlayState;
  }

  ///默认layout
  static Widget _defaultToastLayout(
      BuildContext context, double statusBarHeight, Size screenSize) {
    double viewInsetTop = MediaQuery.of(context).viewInsets.top;
    double viewWidth = screenSize.width;
    double viewHeight = screenSize.height * 0.15 + statusBarHeight;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      //处理横屏的内容高度
      viewHeight = screenSize.width * 0.15 + statusBarHeight;
    }
    return Material(
      //配置阴影主题
      elevation: _puddingElevation?.elevation ?? 2.0,
      shadowColor: _puddingElevation?.shadowColor ?? Colors.black,
      child: PuddingRippleLayout(
        width: viewWidth,
        height: viewHeight,
        backgroundColor: _backgroundColor ?? Colors.green,
        rippleColor: Colors.black12,
        //避免水波纹扩散太慢看不到按压效果,增加触摸的时候颜色
        touchColor: Colors.black12,
        tapCallback: () {
          _dimiss();
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(
              16, 16 + viewInsetTop + statusBarHeight * 2, 16, 16),
          child: RichText(
              text: TextSpan(
                  text: _content ?? "",
                  style: _textStyle ??
                      TextStyle(
                        color: Colors.white,
                      )),
              maxLines: _maxLines ?? 3,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  static PuddingDefault makeText(BuildContext context,
      {String? content,
      Duration? duration,
      Color? backgroundColor,
      int? maxLines,
      double? bottomOffset,
      TextStyle? textStyle,
      PuddingElevation? puddingElevation,
      Widget? contentView}) {
    _content = content;
    _duration = duration;
    _puddingElevation = puddingElevation;
    _backgroundColor = backgroundColor;
    _maxLines = maxLines;
    _textStyle = textStyle;
    MediaQueryData queryData = MediaQuery.of(context);
    double statusBarHeight = queryData.padding.top;
    _customView = contentView ??
        _defaultToastLayout(context, statusBarHeight, queryData.size);
    _overlayState = _initAnimation(
        context, Overlay.of(context), statusBarHeight, queryData.size);
    return PuddingDefault._();
  }

  void show() async {
    _offsetAnimationController?.reset();
    //移除现有的overlayEntry
    _overlayEntry?.remove();
    _overlayEntry = null;
    _startedTime = DateTime.now();
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        top: 0,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: AnimatedBuilder(
            animation: _offsetAnim!,
            child: _customView,
            builder: (context, childToBuild) {
              return Transform.translate(
                offset: Offset(0, _offsetAnim!.value),
                child: childToBuild,
              );
            },
          ),
        ),
      );
    });
    //插入到屏幕上
    _overlayState?.insert(_overlayEntry!);
    //平移动画(translate：-screenHeight*0.15 , -statusBarHeight)
    _offsetAnimationController?.forward();
    //等待_duration毫秒之后
    await Future.delayed(_duration ?? LENGTH_SHORT);
    if (DateTime.now().difference(_startedTime!).inMilliseconds >=
        (_duration ?? LENGTH_SHORT).inMilliseconds) {
      _dimiss();
    }
  }

  static void _dimiss() async {
    if (null == _overlayEntry) return;
    //反转一下做平移动画(translate：-statusBarHeight , -screenHeight*0.15)
    _offsetAnimationController?.reverse();
    //等待动画执行
    await Future.delayed(_HIDE_TOAST_DURATION);
    //移除视图
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

//自定义一个曲线
class _CustomCurve extends Curve {
  @override
  double transform(double t) {
    t -= 1.0;
    double b = t * t * ((2 + 1) * t + 2) + 1.0;
    return b;
  }
}
