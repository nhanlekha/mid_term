import 'package:flutter/material.dart';

class ItemTextFieldWidget extends StatefulWidget {
  const ItemTextFieldWidget(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      required this.textInputType,
      this.isAbscure = false});
  final TextEditingController textEditingController;
  final String hintText;
  final bool isAbscure;
  final TextInputType textInputType;
  @override
  State<ItemTextFieldWidget> createState() => _ItemTextFieldWidgetState();
}

class _ItemTextFieldWidgetState extends State<ItemTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: TextField(
        obscureText: widget.isAbscure,
        controller: widget.textEditingController,
        keyboardType: widget.textInputType,
        decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            hintText: widget.hintText),
      ),
    );
  }
}
