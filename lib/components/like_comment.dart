import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../Theme/color.dart';
import '../controller/theme_controller.dart';

class LikeComment extends StatefulWidget {
  LikeComment({super.key});

  @override
  State<LikeComment> createState() => _LikeCommentState();
}

class _LikeCommentState extends State<LikeComment> {
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
          size: 15,
          _isLiked ? UIcons.solidRounded.heart : UIcons.regularRounded.heart,
          color: _isLiked
              ? buttonb
              : themeController.switchValue.value
                  ? themeController.darkBackground
                  : themeController.lightBackground,
        ));
  }
}
