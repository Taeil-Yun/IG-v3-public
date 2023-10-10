import 'package:flutter/material.dart';

class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;
  final bool onState;

  const StatefulWrapper({
    super.key,
    required this.onInit,
    required this.child,
    this.onState = false,
  });

  @override
  State<StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {

  @override
  void initState() {
    super.initState();
    
    if (widget.onState) {
      Future.delayed(Duration.zero, () {
        widget.onInit();
      });
    } else {
      widget.onInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
