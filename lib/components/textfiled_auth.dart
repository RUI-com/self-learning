// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../Theme/color.dart';

class TextfiledAuth extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String data;
  final Widget? suffixIcon;

  const TextfiledAuth(
      {super.key,
      required this.controller,
      required this.obscureText,
      required this.data,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.black),
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          hintText: data,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          filled: true,
          fillColor: textfildColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
          suffixIcon: suffixIcon),
    );
  }
}
