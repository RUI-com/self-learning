// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../Theme/color.dart';
import '../controller/theme_controller.dart';

class HeartButton extends StatefulWidget {
  @override
  _HeartButtonState createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool _isLiked = false; // لتخزين الحالة (أعجبني أو لا)
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _isLiked = !_isLiked; // تغيير الحالة عند الضغط
          });
        },
        child: Icon(
          _isLiked ? UIcons.solidRounded.heart : UIcons.regularRounded.heart,
          color: _isLiked
              ? buttonb
              : themeController.switchValue.value
                  ? themeController.darkBackground
                  : themeController.lightBackground,
        ));
  }
}
