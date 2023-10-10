import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/colors.dart';

// ignore: must_be_immutable
class SVGBuilder extends StatelessWidget {
  SVGBuilder({
    Key? key,
    required this.image,
    this.byte,
    this.type = SVGType.asset,
    this.matchTextDirection = false,
    this.bundle,
    this.package,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  String image;
  Uint8List? byte;
  bool matchTextDirection;
  AssetBundle? bundle;
  String? package;
  double? width;
  double? height;
  BoxFit fit;
  AlignmentGeometry alignment;
  bool allowDrawingOutsideViewBox;
  Widget Function(BuildContext)? placeholderBuilder;
  Color? color;
  BlendMode colorBlendMode;
  String? semanticsLabel;
  bool excludeFromSemantics;
  SVGType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SVGType.asset:
        return SvgPicture.asset(
          image,
          matchTextDirection: matchTextDirection,
          bundle: bundle,
          package: package,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          placeholderBuilder: placeholderBuilder,
          colorFilter:
              ColorFilter.mode(color ?? ColorConfig().dark(), colorBlendMode),
          semanticsLabel: semanticsLabel,
          excludeFromSemantics: excludeFromSemantics,
        );
      case SVGType.network:
        return SvgPicture.network(
          image,
          matchTextDirection: matchTextDirection,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          placeholderBuilder: placeholderBuilder,
          colorFilter: ColorFilter.mode(color!, colorBlendMode),
          semanticsLabel: semanticsLabel,
          excludeFromSemantics: excludeFromSemantics,
        );
      case SVGType.file:
        return SvgPicture.file(
          File(image),
          matchTextDirection: matchTextDirection,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          placeholderBuilder: placeholderBuilder,
          colorFilter:
              ColorFilter.mode(color ?? ColorConfig().dark(), colorBlendMode),
          semanticsLabel: semanticsLabel,
          excludeFromSemantics: excludeFromSemantics,
        );
      case SVGType.memory:
        return SvgPicture.memory(
          byte!,
          matchTextDirection: matchTextDirection,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          placeholderBuilder: placeholderBuilder,
          colorFilter:
              ColorFilter.mode(color ?? ColorConfig().dark(), colorBlendMode),
          semanticsLabel: semanticsLabel,
          excludeFromSemantics: excludeFromSemantics,
        );
      case SVGType.string:
        return SvgPicture.string(
          image,
          matchTextDirection: matchTextDirection,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          placeholderBuilder: placeholderBuilder,
          colorFilter:
              color != null ? ColorFilter.mode(color!, colorBlendMode) : null,
          semanticsLabel: semanticsLabel,
          excludeFromSemantics: excludeFromSemantics,
        );
    }

    // if (type == SVGType.network) {
    //   return SvgPicture.network(
    //     image,
    //     matchTextDirection: matchTextDirection,
    //     width: width,
    //     height: height,
    //     fit: fit,
    //     alignment: alignment,
    //     allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
    //     placeholderBuilder: placeholderBuilder,
    //     colorFilter: ColorFilter.mode(color!, colorBlendMode),
    //     semanticsLabel: semanticsLabel,
    //     excludeFromSemantics: excludeFromSemantics,
    //   );
    // }
    // return SvgPicture.asset(
    //   image,
    //   matchTextDirection: matchTextDirection,
    //   bundle: bundle,
    //   package: package,
    //   width: width,
    //   height: height,
    //   fit: fit,
    //   alignment: alignment,
    //   allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
    //   placeholderBuilder: placeholderBuilder,
    //   colorFilter: ColorFilter.mode(color ?? ColorConfig().dark(), colorBlendMode),
    //   semanticsLabel: semanticsLabel,
    //   excludeFromSemantics: excludeFromSemantics,
    // );
  }
}

// ignore: must_be_immutable
class SVGStringBuilder extends StatefulWidget {
  SVGStringBuilder({
    Key? key,
    required this.image,
    this.data,
    this.matchTextDirection = false,
    this.bundle,
    this.package,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  String image;
  String? data;
  bool matchTextDirection;
  AssetBundle? bundle;
  String? package;
  double? width;
  double? height;
  BoxFit fit;
  AlignmentGeometry alignment;
  bool allowDrawingOutsideViewBox;
  Widget Function(BuildContext)? placeholderBuilder;
  Color? color;
  BlendMode colorBlendMode;
  String? semanticsLabel;
  bool excludeFromSemantics;

  @override
  State<SVGStringBuilder> createState() => _SVGStringBuilderState();
}

class _SVGStringBuilderState extends State<SVGStringBuilder> {
  String? data;

  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context).loadString(widget.image).then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return data != null
        ? SvgPicture.string(
            widget.data ?? data!,
            matchTextDirection: widget.matchTextDirection,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            alignment: widget.alignment,
            allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
            placeholderBuilder: widget.placeholderBuilder,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, widget.colorBlendMode)
                : null,
            semanticsLabel: widget.semanticsLabel,
            excludeFromSemantics: widget.excludeFromSemantics,
          )
        : Container();
  }
}
