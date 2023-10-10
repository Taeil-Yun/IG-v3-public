import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:ig-public_v3/costant/colors.dart';

import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ig-publicAppBarTitle extends StatelessWidget {
  /// 
  /// - [title] (optional / String type) : 앱바의 타이틀
  /// 
  /// - [color] (optional / Color type / default = ColorsConfig.defaultAppBarTitleColor) : 앱바의 타이틀 색상
  /// 
  /// - [onWidget] (optional / boolean type / default = false) : 앱바 타이틀을 widget 형태로 사용할 것인지 여부
  ///           (!! [onWidget] property 사용시 [wd] property를 사용하지 않으면 에러처리 !!)
  ///           true = 텍스트 형태의 타이틀이 아닌 widget 형태로 사용
  ///           false = 텍스트 형태의 타이틀로 사용
  /// 
  /// - [wd] (optional / Widget type) : 앱바를 widget 형태로 사용
  /// 
  /// - [fontWeight] (optional / FontWeight type / default = FontWeight.normal) : 앱바 타이틀의 폰트 굵기
  /// 
  /// - [size] (optional / double type / default = 16.0) : 앱바 타이틀의 폰트 사이즈
  /// 
  const ig-publicAppBarTitle({
    Key? key,
    this.title,
    this.color,
    this.onWidget = false,
    this.wd,
    this.fontWeight,
    this.size
  }) : super(key: key);

  final String? title;
  final Color? color;
  final FontWeight? fontWeight;
  final bool onWidget;
  final Widget? wd;
  final double? size;

  @override
  Widget build(BuildContext context) {
    /// [onWidget] 속성을 사용시에 [wd] 속성을 사용안하면 에러가 발생하도록 예외처리
    if (onWidget) {
      try {
        return wd!;
      } on Exception {
        log('Property value [wd] does not exist.\nPlease use the [wd] property when using [onWidget]', name: 'Error');
      }
    }
    return wd ?? CustomTextBuilder(
      text: title ?? '',
      style: TextStyle(
        color: color ?? ColorConfig().dark(),
        fontWeight: fontWeight ?? FontWeight.w700,
        fontSize: size ?? 18.0
      ),
    );
  }
}
