import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/other_controller.dart';
import '../../controller/theme_controller.dart';

class ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ButtonStyle? style;

  ProfileButton({required this.label, required this.onTap, this.style});
  final OtherController controllerisFrind = Get.put(OtherController());
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
            color: controllerisFrind.isFriend.value
                ? themeController.switchValue.value
                    ? themeController.darkBackground
                    : themeController.lightBackground
                : Colors.white),
      ),
      style: style,
    );
  }
}
