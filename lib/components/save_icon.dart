import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../Theme/color.dart';
import '../controller/theme_controller.dart';

class SaveIcon extends StatefulWidget {
  const SaveIcon({super.key});

  @override
  State<SaveIcon> createState() => _SaveIconState();
}

class _SaveIconState extends State<SaveIcon> {
  bool _isSaved = false;
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          _isSaved = !_isSaved; // تغيير الحالة عند الضغط
        });
      },
      icon: Icon(
        _isSaved
            ? UIcons.solidRounded.bookmark
            : UIcons.regularRounded.bookmark,
        color: _isSaved
            ? buttonc
            : themeController.switchValue.value
                ? themeController.darkBackground
                : themeController.lightBackground,
      ),
    );
  }
}
