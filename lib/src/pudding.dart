import 'package:flutter/material.dart';
import 'package:flutter_pudding/flutter_pudding.dart';
import 'package:flutter_pudding/src/bean/pudding_elevation.dart';
import 'package:flutter_pudding/src/utils/message_exception.dart';
import 'package:flutter_pudding/src/utils/pudding_type.dart';

///简单示例用法如下:
///
/// ```dart
/// Pudding.create(context,PuddingType.TOAST)..setContent("测试内容")..show();
/// ```
class Pudding {
  Pudding._();

  static BuildContext? _context;

  static PuddingType? _puddingType;

  static String? _content;

  static int? _maxLines;

  static Color? _backgroundColor;

  static PuddingElevation? _puddingElevation;

  static TextStyle? _textStyle;

  static Widget? _contentView;

  ///先调用create(xx)，然后在调用setter方法，最后再调用show()
  /// * [context]：BuildContext
  /// * [type]：可选参数，不传默认是：PuddingType.DEFAULT
  static Pudding create(BuildContext context, {PuddingType? type}) {
    _context = context;
    _puddingType = type ?? PuddingType.DEFAULT;
    //reset data
    _maxLines = 1;
    _backgroundColor = null;
    _puddingElevation = null;
    _textStyle = null;
    return Pudding._();
  }

  ///标题
  void setTitle() {
    if (_puddingType == PuddingType.TOAST) {
      throw UnsupportedOperationException(
          "'setTitle' method does not support type 'PuddingType.TOAST'.");
    }
  }

  ///内容
  void setContent(String content) {
    _content = content;
  }

  ///文本最大显示的行数
  void setMaxLines(int maxLines) {
    _maxLines = maxLines;
    if (_puddingType == PuddingType.DEFAULT && maxLines > 3) {
      throw UnsupportedOperationException(
          "setMaxLines method, PuddingType.DEFAULT type, 'maxLines' must be less than or equal to 3");
    }
  }

  ///设置阴影相关主题
  void setElevation(PuddingElevation puddingElevation) {
    _puddingElevation = puddingElevation;
  }

  ///背景色
  void setBackgroundColor(Color backgroundColor) {
    _backgroundColor = backgroundColor;
  }

  ///文本内容的样式
  void setTextStyle(TextStyle textStyle) {
    _textStyle = textStyle;
  }

  ///传入一个自定义视图：
  ///* 如果contentView不为空，setTitle()/setContent()/setMaxLines()/setTextStyle()自动失效
  ///
  ///* 如果从外部传入contentView，
  ///那么不再需要调用：setTitle()/setContent()/setMaxLines()/setTextStyle()
  void setContentView(Widget contentView) {
    _contentView = contentView;
  }

  ///根据类型显示消息
  void show() {
    if (null == _context) {
      throw NullPointException("BuildContext == null");
    }
    switch (_puddingType) {
      case PuddingType.TOAST:
        Toast.makeText(_context!,
                content: _content,
                textStyle: _textStyle,
                maxLines: _maxLines,
                backgroundColor: _backgroundColor,
                puddingElevation: _puddingElevation,
                contentView: _contentView,
                duration: Toast.LENGTH_SHORT)
            .show();
        break;
      case PuddingType.DIALOG:
        break;
      case PuddingType.LOADING:
        break;
      default:
        PuddingDefault.makeText(_context!,
                content: _content,
                textStyle: _textStyle,
                maxLines: _maxLines,
                backgroundColor: _backgroundColor,
                contentView: _contentView,
                puddingElevation: _puddingElevation,
                duration: Toast.LENGTH_SHORT)
            .show();
        break;
    }
  }
}
