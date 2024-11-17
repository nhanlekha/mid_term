import 'package:flutter/material.dart';

class AppBarContainer extends StatefulWidget {
  const AppBarContainer(
      {super.key, this.appBar, required this.child, this.bottomNavigationBar});
  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomNavigationBar;
  @override
  State<AppBarContainer> createState() => _AppBarContainerState();
}

class _AppBarContainerState extends State<AppBarContainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.appBar,
      body: widget.child,
    );
  }
}
