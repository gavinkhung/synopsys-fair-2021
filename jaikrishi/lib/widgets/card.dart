import 'package:flutter/material.dart';

Widget card(BuildContext context, Widget child) {
  return Container(
    padding: EdgeInsets.all(20),
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color.fromRGBO(196, 243, 220, 1),
          borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(20),
      child: child,
    ),
  );
}
