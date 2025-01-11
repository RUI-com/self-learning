// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ButtonProfile extends StatelessWidget {
  final void Function()? onTap;
  final String data;
  const ButtonProfile({super.key, this.onTap, required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          data,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
