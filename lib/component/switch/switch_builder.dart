import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/enumerated.dart';

// ignore: must_be_immutable
class SwitchBuilder extends StatelessWidget {
  ///
  /// [type] = enum 타입이며, material, cupertino 타입이 존재
  ///
  /// [value] = switch의 상태값
  ///
  /// [onChanged] = switch의 상태값이 변경되면 상태값에게 알려주는 기능
  ///
  /// [activeColor] = switch의 값이 true일 때, background 색상
  ///
  /// [trackColor] = switch의 값이 false일 때, background 색상
  ///
  /// [thumbColor] = switcg의 동그란 버튼 색상
  ///
  /// [dragStartBehavior] = [DragStartDetails]에 전달된 오프셋의 구성
  ///
  SwitchBuilder({
    Key? key,
    required this.type,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  SwitchType type;
  bool value;
  void Function(bool)? onChanged;
  Color? activeColor;
  Color? trackColor;
  Color? thumbColor;
  MaterialStateProperty<Color?>? materialTrackColor;
  MaterialStateProperty<Color?>? materialThumbColor;
  DragStartBehavior dragStartBehavior;

  @override
  Widget build(BuildContext context) {
    if (type == SwitchType.cupertino &&
        (materialTrackColor != null || materialThumbColor != null)) {
      throw Exception(
          '[materialTrackColor] and [materialThumbColor] properties are not available for [SwitchType.cupertino]');
    }
    return SwitchType.cupertino == type
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? ColorConfig().dark(),
            trackColor: trackColor ?? ColorConfig().gray3(),
            thumbColor: thumbColor ?? ColorConfig().white(),
          )
        : Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? ColorConfig().dark(),
            trackColor: materialTrackColor ??
                MaterialStateProperty.all(ColorConfig().gray3()),
            thumbColor: materialThumbColor ??
                MaterialStateProperty.all(ColorConfig().white()),
          );
  }
}
