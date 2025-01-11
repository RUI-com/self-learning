// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/theme_controller.dart';

class ProfileStat extends StatelessWidget {
  final String label;
  final int count;
  final void Function()? onTap;

  ProfileStat({required this.label, required this.count, this.onTap});
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeController.switchValue.value
                  ? themeController.darkBackground
                  : themeController.lightBackground,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: themeController.switchValue.value
                  ? Colors.grey
                  : themeController.lightBackground,
            ),
          ),
        ],
      ),
    );
  }
}
