// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../Theme/color.dart';

class ButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String data;
  const ButtonAuth({super.key, this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [buttona, buttonb, buttonc, buttond],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          data,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
