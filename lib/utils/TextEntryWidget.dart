import 'package:flutter/material.dart';

class TextEntryWidget extends StatelessWidget {
  const TextEntryWidget(
      {super.key,
      required this.myFocusNode,
      required this.controller,
      required this.displaytext,
      required this.trailing_icon,
      required this.simple_icon,
      required this.hidetext});

  final myFocusNode;
  final TextEditingController controller;
  final String displaytext;
  final trailing_icon;
  final simple_icon;
  final bool hidetext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
      child: TextField(
        obscureText: hidetext,
        focusNode: myFocusNode,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
            fontFamily: "WorkSansSemiBold",
            fontSize: 16.0,
            color: Colors.black),
        decoration: InputDecoration(
          icon: simple_icon,
          suffixIcon: trailing_icon,
          border: InputBorder.none,
          hintStyle:
              const TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
          hintText: displaytext,
        ),
      ),
    );
  }
}
