// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: 22
        ),
        children: <TextSpan>[
          TextSpan(text: 'NdobaQuizApp', style: TextStyle(fontWeight: FontWeight.w600
              , color: Color.fromARGB(255, 247, 247, 247))),
          TextSpan(text: '.', style: TextStyle(fontWeight: FontWeight.w600
              , color: Colors.red.shade900)),
        ],
      ),
    );
  }
}
