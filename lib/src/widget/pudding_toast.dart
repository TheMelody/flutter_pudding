import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pudding/src/bean/pudding_elevation.dart';
import 'package:flutter_pudding/src/utils/message_exception.dart';

///Toast消息,不遮挡后面视图的触摸点击
///示例一:
/// ```dart
/// Toast.makeText(context,content:"测试默认布局的Toast消息",duration:LENGTH_SHORT).show();
/// ```
/// 示例二:
/// ```dart
/// Toast.makeText(context,contentView:Card(
///      child: Padding(
///          padding: EdgeInsets.all(8),
///          child: RichText(
///              text: TextSpan(
///                  text: "自定义布局的Toast消息",
///                  style: TextStyle(
///                        color: Colors.green,
///                      )),
///              maxLines: 1,
///              overflow: TextOverflow.ellipsis)),
///      color: Colors.black,
///    ),duration:LENGTH_SHORT).show();
/// ```
class Toast {
  ///用于插入内容到屏幕上
  static OverlayEntry? _overlayEntry;

  ///长消息
  static const Duration LENGTH_LONG = const Duration(milliseconds: 3500);

  ///短消息
  static const Duration LENGTH_SHORT = const Duration(milliseconds: 2000);

  ///显示view的透明度动画控制器，时长
  static const Duration _SHOW_TOAST_ANIM_DURATION =
      const Duration(milliseconds: 200);

  ///隐藏view的透明度动画控制器，时长
  static const Duration _HIDE_TOAST_DURATION =
      const Duration(milliseconds: 150);

  //平移动画控制器，时长
  static const Duration _ALIGN_SHOW_TOAST_DURATION =
      const Duration(milliseconds: 200);

  ///开启一个新toast的当前时间，用于对比是否已经展示了足够时间
  static DateTime? _startedTime;

  ///BuildContext
  static BuildContext? _context;

  ///消息内容
  static String? _content;

  ///消息显示时长
  static Duration? _duration;

  ///消息内容背景色
  static Color? _backgroundColor;

  ///消息内容距离屏幕底部的距离（主要是为了适配系统键盘弹出的场景）
  static double? _bottomOffset;

  ///文本的Style
  static TextStyle? _textStyle;

  ///文本最大行数
  static int? _maxLines;

  ///供外部传入一个widget
  static Widget? _customView;

  ///阴影相关主题
  static PuddingElevation? _puddingElevation;

  ///Alpha动画[控制器]
  static AnimationController? _alphaAnimationController;

  ///Translate动画[控制器]
  static AnimationController? _offsetAnimationController;

  ///Alpha动画
  static Animation<double>? _opacityShow;

  ///曲线动画
  static CurvedAnimation? _offsetCurvedAnimation;

  ///平移动画
  static Animation<double>? _offsetAnim;

  static OverlayState? _overlayState;

  Toast._();

  ///初始化动画
  static OverlayState _initAnimation(OverlayState? overlayState) {
    if (null == overlayState) {
      throw NullPointException("OverLayState == null");
    }
    //Alpha动画[控制器]
    if (null == _alphaAnimationController) {
      _alphaAnimationController = AnimationController(
          vsync: overlayState, duration: _SHOW_TOAST_ANIM_DURATION);
    }
    //Translate动画[控制器]
    if (null == _offsetAnimationController) {
      _offsetAnimationController = AnimationController(
        vsync: overlayState,
        duration: _ALIGN_SHOW_TOAST_DURATION,
      );
    }
    //Alpha动画
    if (null == _opacityShow) {
      _opacityShow =
          Tween(begin: 0.0, end: 1.0).animate(_alphaAnimationController!);
    }
    //曲线动画
    if (null == _offsetCurvedAnimation) {
      _offsetCurvedAnimation = CurvedAnimation(
          parent: _offsetAnimationController!, curve: Curves.fastOutSlowIn);
    }
    //平移动画
    if (null == _offsetAnim) {
      _offsetAnim =
          Tween(begin: 25.0, end: 0.0).animate(_offsetCurvedAnimation!);
    }
    return overlayState;
  }

  ///默认layout
  static Widget _defaultToastLayout(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          //配置阴影主题
          elevation: _puddingElevation?.elevation ?? 2.0,
          shadowColor: _puddingElevation?.shadowColor ?? Colors.black45,
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor ?? Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              shape: BoxShape.rectangle,
            ),
            padding: EdgeInsets.all(8),
            child: RichText(
                text: TextSpan(
                    text: _content ?? "",
                    style: _textStyle ??
                        TextStyle(
                          color: Colors.white,
                        )),
                maxLines: _maxLines ?? 1,
                overflow: TextOverflow.ellipsis),
          ),
        ));
  }

  static Toast makeText(BuildContext context,
      {String? content,
      Duration? duration,
      Color? backgroundColor,
      int? maxLines,
      double? bottomOffset,
      PuddingElevation? puddingElevation,
      TextStyle? textStyle,
      Widget? contentView}) {
    _context = context;
    _content = content;
    _duration = duration;
    _puddingElevation = puddingElevation;
    _bottomOffset = bottomOffset;
    _backgroundColor = backgroundColor;
    _maxLines = maxLines;
    _textStyle = textStyle;
    _customView = contentView ?? _defaultToastLayout(context);
    //初始化相关动画控制并返回OverlayState
    _overlayState = _initAnimation(Overlay.of(context));
    return Toast._();
  }

  void show() async {
    _alphaAnimationController?.reset();
    _offsetAnimationController?.reset();
    //移除现有的overlayEntry
    _overlayEntry?.remove();
    _overlayEntry = null;
    _startedTime = DateTime.now();
    //防止键盘弹出来之后，消息被键盘挡住(键盘弹出来,不加键盘高度,【视图会被键盘遮挡住】)
    double viewInsetBottom = MediaQuery.of(_context!).viewInsets.bottom;
    double bottomOffsetResult =
        _bottomOffset ?? MediaQuery.of(_context!).size.height * 0.1;
    //计算出键盘的高度之后,进行位置设置
    if (viewInsetBottom > 0) {
      bottomOffsetResult = _bottomOffset ??
          MediaQuery.of(_context!).size.height * 0.05 +
              MediaQuery.of(_context!).viewInsets.bottom;
    }
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        bottom: bottomOffsetResult,
        //不影响界面后面的点击
        child: IgnorePointer(
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: AnimatedBuilder(
              animation: _opacityShow!,
              child: _customView,
              builder: (context, childToBuild) {
                return Opacity(
                  opacity: _opacityShow!.value,
                  child: AnimatedBuilder(
                    animation: _offsetAnim!,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _offsetAnim!.value),
                        child: childToBuild,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
    //插入到屏幕上
    _overlayState?.insert(_overlayEntry!);
    //显示动画(alpha： 0->1)
    _alphaAnimationController?.forward();
    //平移动画(translate：0->25)
    _offsetAnimationController?.forward();
    //等待_duration毫秒之后
    await Future.delayed(_duration ?? LENGTH_SHORT);
    if (DateTime.now().difference(_startedTime!).inMilliseconds >=
        (_duration ?? LENGTH_SHORT).inMilliseconds) {
      //执行隐藏动画(alpha： 1->0)
      _alphaAnimationController?.reverse();
      //反转一下做平移动画(translate：25->0)
      _offsetAnimationController?.reverse();
      //等待动画执行
      await Future.delayed(_HIDE_TOAST_DURATION);
      //移除视图
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}
