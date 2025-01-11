import 'package:flutter/material.dart';

import '../Theme/color.dart';

class InwellAuth extends StatelessWidget {
  final void Function() onTap;
  final String text1;
  final String text2;
  const InwellAuth(
      {super.key,
      required this.onTap,
      required this.text1,
      required this.text2});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(children: [
          TextSpan(
            text: text1,
            style: TextStyle(
              color: texts,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text2,
            style: TextStyle(
              color: texts,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ),
    );
  }
}
